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
                autoPlay: false,
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
                    Rectangle()
                        .fill(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay {
                            Text("Picture in Picture 実行中！")
                                .font(.largeTitle)
                        }
                }
            }
            .overlay {
                Rectangle()
                    .fill(LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        ScrollView {
                            Expander(
                                isExpanded: $isErrorDetailExpanded,
                                header: { _ in
                                    Text("エラー発生！")
                                },
                                content: { _ in
                                    Text("\(error?.localizedDescription ?? "")")
                                }
                            )
                        }
                    }
                    .opacity(error != nil ? 1 : 0)
            }

            Spacer()
        }
        .padding()
    }
}

private struct VideoPlayerOverlay: View {
    private let id = UUID()
    @Binding var isPresented: Bool
    @Binding var isPlaying: Bool
    @Binding var duration: Double
    @Binding var position: Double
    @Binding var isSeeking: Bool
    @Binding var loadedRange: (Double, Double)
    @Binding var playerCommand: PassthroughSubject<VideoPlayer.PlayerCommand, Never>
    @Binding var isPictureInPicturePossible: Bool
    @Binding var isPictureInPictureEnabled: Bool
    @State private var isSliderHandleDragging = false
    @State private var sliderValue = 0.0 // second(s)

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()

                    Button {
                        isPictureInPictureEnabled.toggle()
                    } label: {
                        Image(systemName: isPictureInPicturePossible ? "pip.enter" : "rectangle.on.rectangle.slash.fill")
                            .foregroundColor(.white)
                    }
                    .disabled(!isPictureInPicturePossible)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text(formatTime(seconds: isSliderHandleDragging || isSeeking ? sliderValue : position))
                        .foregroundColor(.white)
                    Text("/")
                        .foregroundColor(.gray)
                    Text(formatTime(seconds: duration))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)

            HStack {
                playButton
            }

            VStack {
                Spacer()

                VideoPlayerSlider(
                    position: $sliderValue,
                    duration: $duration,
                    loadedRange: $loadedRange,
                    isDragging: $isSliderHandleDragging
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .id(id)
        .background(.black.opacity(0.5))
        .opacity(isPresented ? 1 : 0)
        .onChange(of: isSliderHandleDragging) { _ in
            if !isSliderHandleDragging {
                playerCommand.send(.seek(seconds: sliderValue))
            }
        }
        .onChange(of: position) { _ in
            if !isSliderHandleDragging && !isSeeking {
                sliderValue = position
            }
        }
        .onTapGesture {
            isPresented = false
        }
    }

    private var playButton: some View {
        Button {
            isPlaying.toggle()
            if isPlaying {
                playerCommand.send(.play)
            } else {
                playerCommand.send(.pause)
            }
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }
}

private func formatTime(seconds: Double) -> String {
    let seconds = Int(seconds)
    let h = seconds / 3600
    let m = seconds % 3600 / 60
    let s = seconds % 3600 % 60

    if h > 0 {
        return String(format: "%03d:%02d:%02d", h, m, s)
    }
    return String(format: "%02d:%02d", m, s)
}

struct CustomVideoPlayer_Previews: PreviewProvider {
    private static let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!

    static var previews: some View {
        CustomVideoPlayer(selectedVideo: .init(title: "BigBuckBunny", url: url))
    }
}