//
//  VideoPlayerOperationLayer.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/09.
//

import SwiftUI
import Combine
import RagiSwiftUIComponents

struct VideoPlayerOperationLayer: View {
    @Binding var isPlaying: Bool
    @Binding var duration: Double
    @Binding var position: Double
    @Binding var isSeeking: Bool
    @Binding var loadedRange: (Double, Double)
    @Binding var playerCommand: PassthroughSubject<VideoPlayer.PlayerCommand, Never>
    @Binding var isPictureInPicturePossible: Bool
    @Binding var isPictureInPictureEnabled: Bool
    @Binding var isSliderHandleDragging: Bool
    @Binding var sliderValue: Double

    var body: some View {
        ZStack {
            baseLayer
            centerItemsLayer
        }
    }

    private var baseLayer: some View {
        VStack {
            HStack {
                Spacer()
                pictureInPictureButton
            }

            Spacer()

            VStack {
                HStack(spacing: 4) {
                    timeText
                    Spacer()
                }

                VideoPlayerSlider(
                    position: $sliderValue,
                    duration: $duration,
                    loadedRange: $loadedRange,
                    isDragging: $isSliderHandleDragging
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var centerItemsLayer: some View {
        HStack {
            playButton
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

    private var pictureInPictureButton: some View {
        Button {
            isPictureInPictureEnabled.toggle()
        } label: {
            Image(systemName: isPictureInPicturePossible ? "pip.enter" : "rectangle.on.rectangle.slash.fill")
                .foregroundColor(.white)
        }
        .disabled(!isPictureInPicturePossible)
    }

    private var timeText: some View {
        HStack(spacing: 4) {
            Text(formatTime(seconds: isSliderHandleDragging || isSeeking ? sliderValue : position))
                .foregroundColor(.white)
            Text("/")
                .foregroundColor(.gray)
            Text(formatTime(seconds: duration))
                .foregroundColor(.gray)
        }
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
