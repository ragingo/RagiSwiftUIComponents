//
//  InternalVideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import Foundation
import AVFoundation
import Combine

class InternalVideoPlayer: ObservableObject {
    enum Properties {
        case status(value: AVPlayerItem.Status)
    }

    private var asset: AVURLAsset?
    private let player: AVPlayer
    private(set) var playerLayer: AVPlayerLayer
    private var keyValueObservations: [NSKeyValueObservation] = []

    @MainActor let properties = PassthroughSubject<Properties, Never>()

    init() {
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: self.player)
    }

    func open(url: URL) async {
        let asset = AVURLAsset(url: url)
        self.asset = asset

        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)

        observeProperties()
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

    func videoSize() async -> CGSize? {
        guard let asset else { return nil }

        if let tracks = try? await asset.load(.tracks) {
            if let videoTrack = tracks.first(where: { $0.mediaType == .video }) {
                return try? await videoTrack.load(.naturalSize)
            }
        }

        return nil
    }

    private func observeProperties() {
        addObservingTarget {
            player.currentItem?.observe(\.status) { [weak self] playerItem, _ in
                self?.properties.send(.status(value: playerItem.status))
            }
        }
    }

    private func addObservingTarget(closure: () -> NSKeyValueObservation?) {
        if let kvo = closure() {
            keyValueObservations += [kvo]
        }
    }
}
