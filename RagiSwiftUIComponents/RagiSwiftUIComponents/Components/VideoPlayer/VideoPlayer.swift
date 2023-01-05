//
//  VideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import SwiftUI
import Combine
import AVFoundation

public struct VideoPlayer: View {
    @StateObject private var player = InternalVideoPlayer()
    private let videoPlayerID = UUID()

    private let isPictureInPictureEnabled: Binding<Bool>
    private let playerCommand: AnyPublisher<PlayerCommand, Never>
    private let url: URL
    private let autoPlay: Bool

    private var durationChanged: ((Double) -> Void)?
    private var positionChanged: ((Double) -> Void)?
    private var seeking: ((Bool) -> Void)?
    private var pictureInPicturePossible: ((Bool) -> Void)?
    private var pictureInPictureActivated: ((Bool) -> Void)?
    private var pictureInPictureStarting: (() -> Void)?
    private var pictureInPictureStarted: (() -> Void)?
    private var pictureInPictureStopping: (() -> Void)?
    private var pictureInPictureStopped: (() -> Void)?
    private var error: ((Error) -> Void)?

    public init(
        url: URL,
        autoPlay: Bool = true,
        playerCommand: AnyPublisher<PlayerCommand, Never>,
        isPictureInPictureEnabled: Binding<Bool> = .constant(false)
    ) {
        self.url = url
        self.autoPlay = autoPlay
        self.playerCommand = playerCommand
        self.isPictureInPictureEnabled = isPictureInPictureEnabled
    }

    public var body: some View {
        VideoSurfaceView(playerLayer: player.playerLayer)
            .id(videoPlayerID)
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .background(.black)
            .border(.white)
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
                    case .seek(let seconds):
                        await player.seek(seconds: seconds)
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
            .onReceive(player.properties) { properties in
                switch properties {
                case .status(let value):
                    onStatusChanged(value: value)
                case .duration(let value):
                    durationChanged?(value)
                case .position(let value):
                    positionChanged?(value)
                case .seeking(let value):
                    seeking?(value)
                case .error(let value):
                    error?(value)
                }
            }
            .onChange(of: isPictureInPictureEnabled.wrappedValue) { isEnabled in
                if isEnabled {
                    player.pictureInPictureController.start()
                } else {
                    player.pictureInPictureController.stop()
                }
            }
            .onReceive(player.pictureInPictureController.properties) { properties in
                switch properties {
                case .isPossible(let value):
                    pictureInPicturePossible?(value)
                case .isActive(let value):
                    pictureInPictureActivated?(value)
                case .starting:
                    pictureInPictureStarting?()
                case .started:
                    pictureInPictureStarted?()
                case .stopping:
                    pictureInPictureStopping?()
                case .stopped:
                    isPictureInPictureEnabled.wrappedValue = false
                    pictureInPictureStopped?()
                }
            }
    }

    public func onDurationChanged(_ perform: @escaping (Double) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.durationChanged = perform
        return videoPlayer
    }

    public func onPositionChanged(_ perform: @escaping (Double) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.positionChanged = perform
        return videoPlayer
    }

    public func onSeeking(_ perform: @escaping (Bool) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.seeking = perform
        return videoPlayer
    }

    public func onPictureInPicturePossible(_ perform: @escaping (Bool) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.pictureInPicturePossible = perform
        return videoPlayer
    }

    public func onPictureInPictureActivated(_ perform: @escaping (Bool) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.pictureInPictureActivated = perform
        return videoPlayer
    }

    public func onPictureInPictureStarting(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.pictureInPictureStarting = perform
        return videoPlayer
    }

    public func onPictureInPictureStarted(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.pictureInPictureStarted = perform
        return videoPlayer
    }

    public func onPictureInPictureStopping(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.pictureInPictureStopping = perform
        return videoPlayer
    }

    public func onPictureInPictureStopped(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.pictureInPictureStopped = perform
        return videoPlayer
    }

    public func onError(_ perform: @escaping (Error) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer.error = perform
        return videoPlayer
    }

    private func onStatusChanged(value: AVPlayerItem.Status) {
        switch value {
        case .unknown:
            break
        case .readyToPlay:
            if autoPlay {
                player.play()
            }
        case .failed:
            break
        @unknown default:
            break
        }
    }
}

extension VideoPlayer {
    public enum PlayerCommand {
        case open(url: URL)
        case play
        case pause
        case stop
        case seek(seconds: Double)
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    struct PreviewView: View {
        private let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        private let playerCommand = PassthroughSubject<VideoPlayer.PlayerCommand, Never>()
        @State private var isPlaying = false

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

                VideoPlayer(url: videoURL, autoPlay: true, playerCommand: playerCommand.eraseToAnyPublisher())
            }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
