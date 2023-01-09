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

    private var _onDurationChanged: ((Double) -> Void)?
    private var _onPositionChanged: ((Double) -> Void)?
    private var _onSeeking: ((Bool) -> Void)?
    private var _onLoadedRangeChanged: (((Double, Double)) -> Void)?
    private var _onPictureInPicturePossible: ((Bool) -> Void)?
    private var _onPictureInPictureActivated: ((Bool) -> Void)?
    private var _onPictureInPictureStarting: (() -> Void)?
    private var _onPictureInPictureStarted: (() -> Void)?
    private var _onPictureInPictureStopping: (() -> Void)?
    private var _onPictureInPictureStopped: (() -> Void)?
    private var _onError: ((Error) -> Void)?
    private var _onStatusChanged: ((AVPlayerItem.Status) -> Void)?
    private var _onFinished: (() -> Void)?

    public init(
        playerCommand: AnyPublisher<PlayerCommand, Never>,
        isPictureInPictureEnabled: Binding<Bool> = .constant(false)
    ) {
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
                    case .rate(let value):
                        player.setRate(value: value)
                    }
                }
            }
            .onDisappear {
                player.reset()
            }
            .onReceive(player.properties) { properties in
                switch properties {
                case .status(let value):
                    _onStatusChanged?(value)
                case .duration(let value):
                    _onDurationChanged?(value)
                case .position(let value):
                    _onPositionChanged?(value)
                case .seeking(let value):
                    _onSeeking?(value)
                case .loadedRange(let value):
                    _onLoadedRangeChanged?(value)
                case .error(let value):
                    _onError?(value)
                case .finished:
                    _onFinished?()
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
                    _onPictureInPicturePossible?(value)
                case .isActive(let value):
                    _onPictureInPictureActivated?(value)
                case .starting:
                    _onPictureInPictureStarting?()
                case .started:
                    _onPictureInPictureStarted?()
                case .stopping:
                    _onPictureInPictureStopping?()
                case .stopped:
                    isPictureInPictureEnabled.wrappedValue = false
                    _onPictureInPictureStopped?()
                }
            }
    }

    public func onDurationChanged(_ perform: @escaping (Double) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onDurationChanged = perform
        return videoPlayer
    }

    public func onPositionChanged(_ perform: @escaping (Double) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPositionChanged = perform
        return videoPlayer
    }

    public func onSeeking(_ perform: @escaping (Bool) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onSeeking = perform
        return videoPlayer
    }

    public func onLoadedRangeChanged(_ perform: @escaping ((Double, Double)) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onLoadedRangeChanged = perform
        return videoPlayer
    }

    public func onPictureInPicturePossible(_ perform: @escaping (Bool) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPictureInPicturePossible = perform
        return videoPlayer
    }

    public func onPictureInPictureActivated(_ perform: @escaping (Bool) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPictureInPictureActivated = perform
        return videoPlayer
    }

    public func onPictureInPictureStarting(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPictureInPictureStarting = perform
        return videoPlayer
    }

    public func onPictureInPictureStarted(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPictureInPictureStarted = perform
        return videoPlayer
    }

    public func onPictureInPictureStopping(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPictureInPictureStopping = perform
        return videoPlayer
    }

    public func onPictureInPictureStopped(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onPictureInPictureStopped = perform
        return videoPlayer
    }

    public func onError(_ perform: @escaping (Error) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onError = perform
        return videoPlayer
    }

    public func onStatusChanged(_ perform: @escaping (AVPlayerItem.Status) -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onStatusChanged = perform
        return videoPlayer
    }

    public func onFinished(_ perform: @escaping () -> Void) -> VideoPlayer {
        var videoPlayer = self
        videoPlayer._onFinished = perform
        return videoPlayer
    }
}

extension VideoPlayer {
    public enum PlayerCommand {
        case open(url: URL)
        case play
        case pause
        case stop
        case seek(seconds: Double)
        case rate(value: Float)
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

                VideoPlayer(playerCommand: playerCommand.eraseToAnyPublisher())
            }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
