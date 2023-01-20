//
//  InternalVideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import Foundation
import AVFoundation
import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import AsyncAlgorithms

final class InternalVideoPlayer: ObservableObject {
    enum Properties {
        case timeControlStatus(value: AVPlayer.TimeControlStatus?)
        case status(value: AVPlayerItem.Status)
        case duration(value: Double)
        case position(value: Double)
        case seeking(value: Bool)
        case loadedRange(value: (Double, Double))
        case error(value: Error)

        case finished

        case bandwidths(values: [Int])
    }

    private var asset: AVURLAsset?
    private let legibleOutput: AVPlayerItemLegibleOutput
    private let videoOutput: AVPlayerItemVideoOutput
    private let ciContext: CIContext
    private var displayLink: CADisplayLink?
    private let player: AVPlayer
    private(set) var playerLayer: AVPlayerLayer
    private var keyValueObservations: [NSKeyValueObservation] = []
    private var timeObserverToken: Any?
    @MainActor private let _properties = PassthroughSubject<Properties, Never>()

    var filters: [CIFilter] = []
    let pictureInPictureController: PictureInPictureController
    @MainActor var properties: AnyPublisher<Properties, Never> {
        _properties
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    init() {
        self.legibleOutput = .init(mediaSubtypesForNativeRepresentation: [])
        self.videoOutput = .init()
        self.ciContext = .init(options: [.workingColorSpace : NSNull()])
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer()
        self.pictureInPictureController = PictureInPictureController(playerLayer: self.playerLayer)
    }

    deinit {
        reset()
    }

    func open(url: URL) async {
        reset()
        setupAudio()
        setupDisplayLink()

        if url.pathExtension == "m3u8" {
            do {
                if let m3u8 = try await downloadText(url: url) {
                    let playlist = try HLSMasterPlaylistParser(m3u8Content: m3u8).parse()
                    print(playlist)
                    let bandwidths = try await parseBandwidth(masterPlaylist: playlist)
                    _properties.send(.bandwidths(values: bandwidths))
                }
            } catch {
                print(error)
            }
        }

        let asset = AVURLAsset(url: url)
        self.asset = asset

        let isPlayable = (try? await asset.load(.isPlayable)) ?? false
        if !isPlayable {
            return
        }

        let playerItem = AVPlayerItem(asset: asset)
        playerItem.add(legibleOutput)
        playerItem.add(videoOutput)
        player.replaceCurrentItem(with: playerItem)

        keyValueObservations += observeProperties()
        subscribeNotifications()

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?._properties.send(.position(value: time.seconds))
        }

        setupClosedCaption()

        await changeClosedCaption()
    }

    @MainActor
    func play() {
        player.play()
    }

    @MainActor
    func pause() {
        player.pause()
    }

    func stop() async {
        await seek(seconds: 0)
    }

    var rate: Float {
        get { player.rate }
        set { player.rate = newValue }
    }

    func audioTracks() async -> [(id: String, displayName: String)] {
        guard let asset else {
            return []
        }
        guard let audibleGroup = try? await asset.loadMediaSelectionGroup(for: .audible) else {
            return []
        }
        return audibleGroup.options
            .compactMap {
                guard let locale = $0.locale else {
                    return nil
                }
                return (id: locale.identifier, displayName: $0.displayName)
            }
    }

    func changeAudioTrack(id: String? = nil) async {
        guard let asset else {
            return
        }
        guard let audibleGroup = try? await asset.loadMediaSelectionGroup(for: .audible) else {
            return
        }
        if let id {
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: audibleGroup.options, with: .init(identifier: id))
            if let option = options.first {
                await player.currentItem?.select(option, in: audibleGroup)
            }
        }
    }

    func closedCaptionLanguages() async -> [(id: String, displayName: String)] {
        guard let asset else {
            return []
        }
        guard let legibleGroup = try? await asset.loadMediaSelectionGroup(for: .legible) else {
            return []
        }
        return legibleGroup.options
            .compactMap {
                guard let locale = $0.locale else {
                    return nil
                }
                return (id: locale.identifier, displayName: $0.displayName)
            }
    }

    func changeClosedCaption(id: String? = nil) async {
        guard let asset else {
            return
        }
        guard let legibleGroup = try? await asset.loadMediaSelectionGroup(for: .legible) else {
            return
        }
        if let id {
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: legibleGroup.options, with: .init(identifier: id))
            if let option = options.first {
                await player.currentItem?.select(option, in: legibleGroup)
            }
        } else {
            await player.currentItem?.select(nil, in: legibleGroup)
        }
    }

    func changeBandwidth(_ value: Int) {
        player.currentItem?.preferredPeakBitRate = Double(value)
    }

    func reset() {
        displayLink?.invalidate()
        displayLink = nil

        // KVO
        keyValueObservations.forEach {
            $0.invalidate()
        }
        keyValueObservations.removeAll()

        if let timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    func seek(seconds: Double) async {
        _properties.send(.seeking(value: true))

        let scale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: seconds, preferredTimescale: scale)

        let isFinished = await player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        if isFinished {
            _properties.send(.seeking(value: false))
        }
    }

    func videoSize() async -> CGSize? {
        guard let asset else { return nil }

        if let tracks = try? await asset.load(.tracks) {
            if let videoTrack = tracks.first(where: { $0.mediaType == .video }) {
                return try? await videoTrack.load(.naturalSize)
            }
        }

        return nil
    }

    private func setupAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print(error)
        }
    }

    private func setupDisplayLink() {
        if displayLink != nil {
            return
        }
        displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLinkUpdated(sender:)))
        displayLink?.preferredFrameRateRange = .init(minimum: 30, maximum: 60, preferred: 60)
        displayLink?.add(to: .main, forMode: .common)
    }

    private func setupClosedCaption() {
        legibleOutput.suppressesPlayerRendering = false
        legibleOutput.textStylingResolution = .sourceAndRulesOnly
        legibleOutput.setDelegate(LegibleOutput(), queue: .main)

        player.currentItem?.textStyleRules = []
        if let textStyleRule = AVTextStyleRule(textMarkupAttributes: [
            // 左端 0% から 右端 100% までの値を指定。字幕の文字列の長さのこともあるので、いい感じに配置される
            kCMTextMarkupAttribute_TextPositionPercentageRelativeToWritingDirection as String: 0.0,
            // 上端 0% から 下端 100% までの値を指定。複数行の可能性もあるので、先頭行基準でいい感じに配置される。
            kCMTextMarkupAttribute_OrthogonalLinePositionPercentageRelativeToWritingDirection as String: 100.0
        ]) {
            player.currentItem?.textStyleRules?.append(textStyleRule)
        }
    }

    @objc private func onDisplayLinkUpdated(sender: CADisplayLink) {
        if filters.isEmpty {
            if playerLayer.player == nil {
                playerLayer.player = player
            }
            return
        }

        let time = videoOutput.itemTime(forHostTime: CACurrentMediaTime())
        if !videoOutput.hasNewPixelBuffer(forItemTime: time) {
            return
        }

        guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            return
        }

        let originalImage = CIImage(cvImageBuffer: pixelBuffer)
        var nextInputImage = originalImage

        filters.forEach { filter in
            let parameters = filter.inputKeys
                .map { key in
                    (key, filter.value(forKey: key))
                }
                .reduce([String: Any]()) { (result, pair) in
                    var result = result
                    result[pair.0] = pair.1
                    return result
                }
            nextInputImage = nextInputImage
                .clampedToExtent()
                .applyingFilter(filter.name, parameters: parameters)
                .cropped(to: nextInputImage.extent)
        }

        guard let cgImage = ciContext.createCGImage(nextInputImage, from: nextInputImage.extent) else {
            return
        }

        playerLayer.contents = cgImage
    }

    @KVOBuilder
    private func observeProperties() -> [KVOBuilder.Element] {
        // AVPlayer.timeControlStatus
        player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, change in
            self?._properties.send(.timeControlStatus(value: self?.player.timeControlStatus))
        }
        // AVPlayerItem.status
        player.currentItem?.observe(\.status, options: [.initial, .new]) { [weak self] playerItem, _ in
            self?._properties.send(.status(value: self?.player.currentItem?.status ?? .unknown))
        }
        // AVPlayerItem.duration
        player.currentItem?.observe(\.duration, options: [.initial, .new]) { [weak self] playerItem, change in
            var value = change.newValue?.seconds ?? .zero
            if value.isNaN {
                value = .zero
            }
            self?._properties.send(.duration(value: value))
        }
        // AVPlayerItem.error
        player.currentItem?.observe(\.error, options: [.new]) { [weak self] playerItem, change in
            if let value = change.newValue, let error = value {
                self?._properties.send(.error(value: error))
            }
        }
        // AVPlayerItem.loadedTimeRanges
        player.currentItem?.observe(\.loadedTimeRanges, options: [.initial, .new]) { [weak self] playerItem, change in
            if let value = change.newValue, let ranges = value as? [CMTimeRange] {
                if ranges.isEmpty {
                    return
                }
                let range = ranges[0]
                var start = floor(range.start.seconds)
                var end = floor(range.end.seconds)
                if start.isNaN {
                    start = .zero
                }
                if end.isNaN {
                    end = .zero
                }
                self?._properties.send(.loadedRange(value: (start, end)))
            }
        }
    }

    private func subscribeNotifications() {
        Notifications.shared.register(.AVPlayerItemDidPlayToEndTime) { [weak self] in
            self?._properties.send(.finished)
        }
    }

    private class Notifications {
        private var cancellables: [AnyCancellable] = []
        static let shared = Notifications()

        private init() {
        }

        deinit {
        }

        func register(_ name: Notification.Name, action: @escaping () -> Void) {
            NotificationCenter.Publisher(center: .default, name: name)
                .sink { _ in
                    action()
                }
                .store(in: &cancellables)
        }
    }

    private class LegibleOutput: NSObject, AVPlayerItemLegibleOutputPushDelegate {
        func legibleOutput(
            _ output: AVPlayerItemLegibleOutput,
            didOutputAttributedStrings strings: [NSAttributedString],
            nativeSampleBuffers nativeSamples: [Any],
            forItemTime itemTime: CMTime
        ) {
            // TODO: 呼ばれない原因を調べる
            print("\(strings.first?.string ?? "")")
        }
    }
}

private func downloadText(url: URL) async throws -> String? {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let response = response as? HTTPURLResponse else {
        return nil
    }

    if ![200].contains(response.statusCode) {
        return nil
    }

    return String(data: data, encoding: .utf8)
}

// 画質(bandwidth)一覧を降順で取得
private func parseBandwidth(masterPlaylist: ParsedMasterPlaylist) async throws -> [Int] {
    guard let regex = try? NSRegularExpression(pattern: #"[:,]?BANDWIDTH=(\d+)(\,|$)"#) else {
        return []
    }

    return []
//    return masterPlaylist.tags
//        .filter {
//            $0.type == .EXT_X_STREAM_INF
//        }
//        .compactMap { inf -> Int? in
//            let inputRange = NSRange(location: 0, length: inf.value.count)
//            guard let result = regex.firstMatch(in: String(inf.value), range: inputRange) else {
//                return nil
//            }
//            let group1 = result.range(at: 1)
//            let value = (inf.value as NSString).substring(with: group1)
//            return Int(value)
//        }
//        .sorted()
}
