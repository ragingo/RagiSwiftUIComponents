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
    private var asset: AVURLAsset?
    private let player: AVPlayer
    private(set) var playerLayer: AVPlayerLayer

    init() {
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: self.player)
    }

    func open(url: URL) async {
        let asset = AVURLAsset(url: url)
        self.asset = asset

        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
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
}
