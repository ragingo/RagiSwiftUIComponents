//
//  VideoPlayerDebugView.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/03.
//

import Combine
import SwiftUI
import RagiSwiftUIComponents

struct VideoPlayerDebugView: View {
    private let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    @State private var playerCommand = PassthroughSubject<VideoPlayer.PlayerCommand, Never>()
    @State private var isPictureInPictureEnabled = false
    @State private var isPlaying = false
    @State private var showOverlay = false
    @State private var duration = 0.0
    @State private var position = 0.0
    @State private var isPictureInPictureMode = false
    @State private var isPictureInPicturePossible = false
    @State private var isPictureInPictureActivated = false

    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(
                url: url,
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
            .onPictureInPicturePossible { isPossible in
                isPictureInPicturePossible = isPossible
            }
            .onPictureInPictureActivated { isActivated in
                isPictureInPictureActivated = isActivated
            }
            .onPictureInPictureStarting {
                isPictureInPictureMode = true
            }
            .onPictureInPictureStarted {
                isPictureInPictureMode = true
            }
            .onPictureInPictureStopping {
                isPictureInPictureMode = false
            }
            .onPictureInPictureStopped {
                isPictureInPictureMode = false
            }
            .onAppear {
                playerCommand.send(.open(url: url))
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
                    playerCommand: $playerCommand,
                    isPictureInPicturePossible: $isPictureInPicturePossible,
                    isPictureInPictureEnabled: $isPictureInPictureEnabled
                )
            }
            .overlay {
                if isPictureInPictureMode || isPictureInPictureActivated {
                    Rectangle()
                        .fill(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay {
                            Text("Picture in Picture 実行中！")
                                .font(.largeTitle)
                        }
                }
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
    @Binding var playerCommand: PassthroughSubject<VideoPlayer.PlayerCommand, Never>
    @Binding var isPictureInPicturePossible: Bool
    @Binding var isPictureInPictureEnabled: Bool
    @State private var isIdling = false
    @State private var isSliderHandleDragging = false
    @State private var sliderValue = 0.0 // second(s)
    @State private var presentTask: Task<(), Never>? {
        willSet {
            presentTask?.cancel()
        }
    }

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
                    Text(formatTime(seconds: isSliderHandleDragging ? sliderValue : position))
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
                    loadedRange: .constant((0, 0)),
                    isDragging: $isSliderHandleDragging
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .id(id)
        .background(.black.opacity(0.5))
        .opacity(isPresented ? 1 : 0)
        .onChange(of: isPresented) { _ in
            presentTask = Task {
                if isPresented {
                    isIdling = true
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    if isIdling {
                        isPresented = false
                        isIdling = false
                    }
                }
            }
        }
        .onChange(of: isSliderHandleDragging) { _ in
            position = sliderValue
        }
        .onChange(of: position) { _ in
            isIdling = false
            if !isSliderHandleDragging {
                sliderValue = position
            }
        }
        .onTapGesture {
            presentTask = nil
            isPresented = false
            isIdling = false
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

struct VideoPlayerDebugView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerDebugView()
    }
}
