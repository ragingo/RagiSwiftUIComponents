//
//  InternalVideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import Foundation
import AVFoundation

class InternalVideoPlayer {
    private var asset: AVURLAsset?
    private let player: AVPlayer
    private(set) var playerLayer: AVPlayerLayer

    init() {
        self.player = AVPlayer()
        self.playerLayer = AVPlayerLayer(player: self.player)
    }

    func execute(command: PlayCommand) async {
        switch command {
        case .open(let url):
            await onOpen(url: url)
        case .play:
            await onPlay()
        case .pause:
            await onPause()
        case .stop:
            await onPause()
        }
    }

    private func onOpen(url: URL) async {
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
    }

    private func onPlay() async {
        await player.play()
    }

    private func onPause() async {
        await player.pause()
    }

    private func onStop() async {
    }
}

extension InternalVideoPlayer {
    enum PlayCommand {
        case open(url: URL)
        case play
        case pause
        case stop
    }
}
