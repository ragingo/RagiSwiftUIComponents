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

    let selectedVideo: Video

    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(
                url: selectedVideo.url,
                autoPlay: autoPlay,
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
                    isPictureInPictureEnabled: $isPictureInPictureEnabled
                )
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
