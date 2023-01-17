//
//  CustomVideoPlayer.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/05.
//

import Combine
import SwiftUI
import RagiSwiftUIComponents

struct CustomVideoPlayer: View {
    @AppStorage("CustomVideoPlayer_AutoPlay") var autoPlay = false
    @State private var playerCommand = PassthroughSubject<VideoPlayer.PlayerCommand, Never>()
    @State private var isPictureInPictureEnabled = false
    @State private var isPlaying = false
    @State private var showOverlay = false
    @State private var duration = 0.0
    @State private var position = 0.0
    @State private var isSeeking = false
    @State private var loadedRange = (0.0, 0.0)
    @State private var isPictureInPictureMode = false
    @State private var isPictureInPicturePossible = false
    @State private var error: Error?
    @State private var isErrorDetailExpanded = false
    @State private var closedCaptionLanguages: [(id: String, displayName: String)] = []
    @State private var audioTracks: [(id: String, displayName: String)] = []
    @State private var bandwidths: [Int] = []

    private let overlayID = UUID()

    let selectedVideo: Video

    var body: some View {
        let _ = Self._printChanges()
        VStack(spacing: 0) {
            VideoPlayer(
                playerCommand: playerCommand.eraseToAnyPublisher(),
                isPictureInPictureEnabled: $isPictureInPictureEnabled
            )
            .onDurationChanged { duration in
                self.duration = duration
            }
            .onPositionChanged { position in
                self.position = position
            }
            .onSeeking { isSeeking in
                self.isSeeking = isSeeking
            }
            .onLoadedRangeChanged { loadedRange in
                self.loadedRange = loadedRange
            }
            .onPictureInPicturePossible { isPossible in
                isPictureInPicturePossible = isPossible
            }
            .onPictureInPictureActivated { isActivated in
                isPictureInPictureMode = isActivated
            }
            .onPictureInPictureStarting {
                isPictureInPictureMode = true
            }
            .onError { error in
                self.error = error
            }
            .onTimeControlStatusChanged { status in
                guard let status else { return }
                switch status {
                case .paused:
                    isPlaying = false
                case .playing:
                    isPlaying = true
                case .waitingToPlayAtSpecifiedRate:
                    isPlaying = false
                @unknown default:
                    isPlaying = false
                }
            }
            .onStatusChanged { status in
                switch status {
                case .unknown:
                    isPlaying = false
                case .readyToPlay:
                    isPlaying = true
                    playerCommand.send(.getClosedCaptionLanguages)
                    playerCommand.send(.getAudioTracks)
                case .failed:
                    isPlaying = false
                @unknown default:
                    isPlaying = false
                }
            }
            .onFinished {
                isPlaying = false
                playerCommand.send(.stop)
            }
            .onAudioTracksLoaded {
                audioTracks = $0
            }
            .onClosedCaptionLanguagesLoaded {
                closedCaptionLanguages = $0
            }
            .onBandwidthsLoaded {
                bandwidths = $0
            }
            .onAppear {
                playerCommand.send(.open(url: selectedVideo.url))
                if autoPlay {
                    playerCommand.send(.play)
                }
            }
            .onTapGesture {
                showOverlay.toggle()
            }
            .overlay {
                VideoPlayerOverlay(
                    isPresented: $showOverlay,
                    isPlaying: $isPlaying,
                    duration: $duration,
                    position: $position,
                    isSeeking: $isSeeking,
                    loadedRange: $loadedRange,
                    playerCommand: $playerCommand,
                    isPictureInPicturePossible: $isPictureInPicturePossible,
                    isPictureInPictureEnabled: $isPictureInPictureEnabled,
                    closedCaptionLanguages: $closedCaptionLanguages,
                    audioTracks: $audioTracks,
                    bandwidths: $bandwidths
                )
                .id(overlayID)
            }
            .overlay {
                if isPictureInPictureMode {
                    VideoPlayerPictureInPictureCover()
                }
            }
            .overlay {
                if let error {
                    VideoPlayerErrorLayer(error: error)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct CustomVideoPlayer_Previews: PreviewProvider {
    private static let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!

    static var previews: some View {
        CustomVideoPlayer(selectedVideo: .init(title: "BigBuckBunny", url: url))
    }
}
