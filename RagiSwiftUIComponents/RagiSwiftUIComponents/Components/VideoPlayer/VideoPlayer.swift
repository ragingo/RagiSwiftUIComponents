//
//  VideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import SwiftUI
import Combine

public struct VideoPlayer: View {
    @StateObject private var player = InternalVideoPlayer()

    private let playerCommand: AnyPublisher<PlayerCommand, Never>
    private let url: URL
    private let autoPlay: Bool

    public init(url: URL, autoPlay: Bool = true, playerCommand: AnyPublisher<PlayerCommand, Never>) {
        self.url = url
        self.autoPlay = autoPlay
        self.playerCommand = playerCommand
    }

    public var body: some View {
        VideoSurfaceView(playerLayer: player.playerLayer)
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .onReceive(playerCommand) { command in
                Task {
                    switch command {
                    case .open(let url):
                        await player.open(url: url)
                    case .play:
                        player.play()
                    case .pause:
                        player.pause()
                    case .stop:
                        await player.stop()
                    }
                }
            }
            .onAppear {
                Task {
                    await player.open(url: url)
                    if autoPlay {
                        player.play()
                    }
                }
            }
    }
}

extension VideoPlayer {
    public enum PlayerCommand {
        case open(url: URL)
        case play
        case pause
        case stop
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    struct PreviewView: View {
        private let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        private let playerCommand = PassthroughSubject<VideoPlayer.PlayerCommand, Never>()
        @State private var isPlaying = false
        private let videoPlayerID = UUID()

        var body: some View {
            VStack {
                Button {
                    isPlaying.toggle()
                    if isPlaying {
                        playerCommand.send(.play)
                    } else {
                        playerCommand.send(.pause)
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                }

                VideoPlayer(url: videoURL, autoPlay: false, playerCommand: playerCommand.eraseToAnyPublisher())
                    .id(videoPlayerID)
            }
        }
    }
    static var previews: some View {
        PreviewView()
    }
}
