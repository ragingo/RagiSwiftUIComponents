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
    @Binding var isPictureInPicturePossible: Bool
    @Binding var isPictureInPictureEnabled: Bool
    @Binding var isSliderHandleDragging: Bool
    @Binding var sliderValue: Double
    @Binding var closedCaptionLanguages: [(id: String, displayName: String)]
    @Binding var audioTracks: [(id: String, displayName: String)]
    @Binding var videoQuolities: [VideoQuolity]

    @State private var showSettings = false

    var onPlayButtonTapped: (() -> Void)?
    var onAudioTrackSelected: ((_ id: String) -> Void)?
    var onClosedCaptureLanguageSelected: ((_ id: String?) -> Void)?
    var onPlaybackRateChanged: ((_ rate: Float) -> Void)?
    var onBandwidthSelected: ((Int) -> Void)?

    var body: some View {
        let _ = Self._printChanges()
        VStack {
            commandTray

            Spacer()

            HStack {
                PlayButton(isPlaying: isPlaying) {
                    onPlayButtonTapped?()
                }
            }

            Spacer()

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
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .overlay {
            if showSettings {
                settingsLayer
            }
        }
        .animation(.default, value: showSettings)
        .clipped()
    }

    private var commandTray: some View {
        HStack {
            Spacer()
            VideoQualityMenuButton(items: videoQuolities) { selectedBandwidth in
                onBandwidthSelected?(selectedBandwidth)
            }
            AudioTracksMenuButton(tracks: audioTracks) { selectedTrackID in
                onAudioTrackSelected?(selectedTrackID)
            }
            ClosedCaptionMenuButton(languages: closedCaptionLanguages) { selectedLanguageID in
                onClosedCaptureLanguageSelected?(selectedLanguageID)
            }
            PictureInPictureButton(isPossible: isPictureInPicturePossible) {
                isPictureInPictureEnabled.toggle()
            }
            SettingsButton {
                showSettings = true
            }
        }
    }

    private var settingsLayer: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    SettingsLayerCloseButton {
                        showSettings = false
                    }
                }
                Spacer()
            }

            VStack {
                HStack(spacing: 32) {
                    Text("再生速度")
                        .foregroundColor(.white)
                    PlaybackRateSlider { rate in
                        onPlaybackRateChanged?(rate)
                    }
                }
                Spacer()
            }
            .padding(.trailing, 32)
        }
        .padding(16)
        .background(.black.opacity(0.8))
        .transition(.move(edge: .trailing))
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
                    isPictureInPicturePossible: .constant(true),
                    isPictureInPictureEnabled: .constant(false),
                    isSliderHandleDragging: .constant(false),
                    sliderValue: .constant(0),
                    closedCaptionLanguages: .constant([
                        (id: "en", displayName: "英語"),
                        (id: "ja", displayName: "日本語"),
                    ]),
                    audioTracks: .constant([]),
                    videoQuolities: .constant([
                        .init(bandWidth: 100, resolution: .init(width: 1, height: 1)),
                        .init(bandWidth: 200, resolution: .init(width: 2, height: 2)),
                    ])
                )
            }
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .background(.black.opacity(0.5))
            .padding()
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
