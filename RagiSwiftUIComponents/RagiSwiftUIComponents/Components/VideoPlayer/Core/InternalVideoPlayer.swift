//
//  InternalVideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import Foundation
import AVFoundation
import Combine

final class InternalVideoPlayer: ObservableObject {
    enum Properties {
        case status(value: AVPlayerItem.Status)
        case duration(value: Double)
        case position(value: Double)
    }

    private var asset: AVURLAsset?
    private let player: AVPlayer
    private(set) var playerLayer: AVPlayerLayer
    private var keyValueObservations: [NSKeyValueObservation] = []
    private var timeObserverToken: Any?
    @MainActor private let _properties = PassthroughSubject<Properties, Never>()

    let pictureInPictureController: PictureInPictureController
    @MainActor var properties: AnyPublisher<Properties, Never> {
        _properties.eraseToAnyPublisher()
    }

    init() {
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: self.player)
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

        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

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

    @KVOBuilder
    private func observeProperties() -> [KVOBuilder.Element] {
        // AVPlayerItem.status
        player.currentItem?.observe(\.status, options: [.initial, .new]) { [weak self] playerItem, change in
            self?._properties.send(.status(value: change.newValue ?? .unknown))
        }
        // AVPlayerItem.duration
        player.currentItem?.observe(\.duration, options: [.initial, .new]) { [weak self] playerItem, change in
            var value = change.newValue?.seconds ?? .zero
            if value.isNaN {
                value = .zero
            }
            self?._properties.send(.duration(value: value))
        }
    }
}
