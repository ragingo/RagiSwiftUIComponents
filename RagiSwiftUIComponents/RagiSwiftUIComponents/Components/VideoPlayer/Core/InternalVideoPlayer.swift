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

final class InternalVideoPlayer: ObservableObject {
    enum Properties {
        case status(value: AVPlayerItem.Status)
        case duration(value: Double)
        case position(value: Double)
        case seeking(value: Bool)
        case loadedRange(value: (Double, Double))
        case error(value: Error)
    }

    private var asset: AVURLAsset?
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

        let asset = AVURLAsset(url: url)
        self.asset = asset

        let isPlayable = (try? await asset.load(.isPlayable)) ?? false
        if !isPlayable {
            return
        }

        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        playerItem.add(videoOutput)

        keyValueObservations += observeProperties()

        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let interval = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?._properties.send(.position(value: time.seconds))
        }
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
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
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

        let image = CIImage(cvImageBuffer: pixelBuffer)
        var nextInputImage = image

        for filter in filters {
            filter.setValue(nextInputImage, forKey: kCIInputImageKey)
            guard let outputImage = filter.outputImage else { continue }
            nextInputImage = outputImage.cropped(to: nextInputImage.extent)
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
            if self?.player.timeControlStatus == .playing {
                self?.setupDisplayLink()
            }
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
}
