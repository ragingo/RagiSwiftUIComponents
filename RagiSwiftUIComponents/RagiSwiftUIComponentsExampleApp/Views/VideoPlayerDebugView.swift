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
    @State private var pictureInPictureEnabled = false
    @State private var isPlaying = false
    @State private var showOverlay = false
    @State private var duration = 0.0
    @State private var position = 0.0

    var body: some View {
        VStack(spacing: 0) {
            VideoPlayer(
                url: url,
                autoPlay: false,
                playerCommand: playerCommand.eraseToAnyPublisher(),
                pictureInPictureEnabled: $pictureInPictureEnabled
            )
            .onDurationChanged { duration in
                self.duration = duration
            }
            .onPositionChanged { position in
                self.position = position
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
                    pictureInPictureEnabled: $pictureInPictureEnabled
                )
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
    @Binding var pictureInPictureEnabled: Bool

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
                        pictureInPictureEnabled.toggle()
                    } label: {
                        Image(systemName: "pip.enter")
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Text(formatTime(seconds: position))
                        .foregroundColor(.white)
                    Text("/")
                        .foregroundColor(.gray)
                    Text(formatTime(seconds: duration))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding(16)

            HStack {
                playButton
            }
        }
        .id(id)
        .background(.black.opacity(0.5))
        .opacity(isPresented ? 1 : 0)
        .onChange(of: isPresented) { _ in
            presentTask = Task {
                if isPresented {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    isPresented = false
                }
            }
        }
        .onTapGesture {
            presentTask = nil
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

struct VideoPlayerDebugView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerDebugView()
    }
}
