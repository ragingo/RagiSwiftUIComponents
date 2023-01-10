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

    @State private var showSettings = false
    @State private var showClosedCaption = false
    @State private var rateSliderValue = 0.0

    var body: some View {
        ZStack {
            baseLayer
            centerItemsLayer

            if showSettings {
                settingsLayer
            }
        }
        .animation(.default, value: showSettings)
    }

    private var baseLayer: some View {
        VStack {
            HStack {
                Spacer()
                closedCaptionButton
                pictureInPictureButton
                settingsButton
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

    private var settingsLayer: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    settingsLayerCloseButton
                }
                Spacer()
            }

            VStack {
                HStack(spacing: 32) {
                    Text("再生速度")
                        .foregroundColor(.white)
                    rateSlider
                }
                Spacer()
            }
            .padding(.trailing, 32)
        }
        .padding(16)
        .background(.black.opacity(0.8))
        .transition(.move(edge: .trailing))
    }

    private var rateSlider: some View {
        RagiSwiftUIComponents.Slider(value: $rateSliderValue)
            .onHandleDragging { isDragging in
                if !isDragging {
                    let rate = Float((rateSliderValue * 100.0 * 5.0).rounded(.down)) / 100.0
                    playerCommand.send(.rate(value: rate))
                }
            }
            .sliderStyle(RateSliderStyle())
            .overlay {
                let rate = Float((rateSliderValue * 100.0 * 5.0).rounded(.down)) / 100.0
                Text("x \(rate, specifier: "%.2f")")
                    .foregroundColor(.white)
                    .offset(y: -16)
            }
    }

    private var settingsLayerCloseButton: some View {
        Button {
            showSettings = false
        } label: {
            Image(systemName: "xmark.circle")
                .foregroundColor(.white)
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

    private var closedCaptionButton: some View {
        Button {
            showClosedCaption.toggle()
            playerCommand.send(.showClosedCaption(showClosedCaption))
        } label: {
            Image(systemName: showClosedCaption ? "captions.bubble.fill" : "captions.bubble")
                .foregroundColor(.white)
        }
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

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .foregroundColor(.white)
        }
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

private struct RateSliderStyle: SliderStyle {
    private static let trackHeight: CGFloat = 4

    public func makeActiveTrack(configuration: SliderTrackConfiguration) -> some View {
        configuration.content
            .frame(height: Self.trackHeight)
            .foregroundColor(Color(uiColor: .systemBlue))
    }

    public func makeInactiveTrack(configuration: SliderTrackConfiguration) -> some View {
        configuration.content
            .frame(height: Self.trackHeight)
            .foregroundColor(Color(uiColor: .systemGray6))
    }

    public func makeHandle(configuration: SliderHandleConfiguration) -> some View {
        SliderHandle {
            Image(systemName: "speedometer")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .clipShape(Circle())
                .shadow(elevation: .level1, cornerRadius: 10)
                .background(
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .scaleEffect(2.0)
                        .opacity(configuration.isPressed ? 1 : 0)
                        .animation(.default, value: configuration.isPressed)
                )
        }
        .offset(y: Self.trackHeight * 0.5)
    }

    public func makeBody(configuration: SliderConfiguration) -> some View {
        configuration.content
    }
}

struct VideoPlayerOperationLayer_Previews: PreviewProvider {
    struct PreviewView: View {
        var body: some View {
            VStack {
                VideoPlayerOperationLayer(
                    isPlaying: .constant(false),
                    duration: .constant(120),
                    position: .constant(60),
                    isSeeking: .constant(false),
                    loadedRange: .constant((0, 100)),
                    playerCommand: .constant(.init()),
                    isPictureInPicturePossible: .constant(true),
                    isPictureInPictureEnabled: .constant(false),
                    isSliderHandleDragging: .constant(false),
                    sliderValue: .constant(0)
                )
            }
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .background(.black.opacity(0.5))
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
