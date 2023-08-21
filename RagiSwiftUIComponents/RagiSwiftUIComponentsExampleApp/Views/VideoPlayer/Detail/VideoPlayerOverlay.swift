//
//  VideoPlayerOverlay.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/09.
//

import SwiftUI
import Combine
import RagiSwiftUIComponents

struct VideoPlayerOverlay: View {
    @Binding var isPresented: Bool
    @Binding var isPlaying: Bool
    @Binding var duration: Double
    @Binding var position: Double
    @Binding var isSeeking: Bool
    @Binding var loadedRange: (Double, Double)
    @Binding var playerCommand: PassthroughSubject<VideoPlayer.PlayerCommand, Never>
    @Binding var isPictureInPicturePossible: Bool
    @Binding var isPictureInPictureEnabled: Bool
    @Binding var closedCaptionLanguages: [(id: String, displayName: String)]
    @Binding var audioTracks: [(id: String, displayName: String)]
    @Binding var videoQualities: [VideoQuality]
    @State private var isSliderHandleDragging = false
    @State private var sliderValue = 0.0 // second(s)

    private let informationLayerID = UUID()
    private let operationLayerID = UUID()
    private let hudLayerID = UUID()

    var body: some View {
        let _ = Self._printChanges()
        ZStack {
            VideoPlayerInformationLayer()
                .id(informationLayerID)

            VideoPlayerOperationLayer(
                isPlaying: $isPlaying,
                duration: $duration,
                position: $position,
                isSeeking: $isSeeking,
                loadedRange: $loadedRange,
                isPictureInPicturePossible: $isPictureInPicturePossible,
                isPictureInPictureEnabled: $isPictureInPictureEnabled,
                isSliderHandleDragging: $isSliderHandleDragging,
                sliderValue: $sliderValue,
                closedCaptionLanguages: $closedCaptionLanguages,
                audioTracks: $audioTracks,
                videoQualities: $videoQualities,
                onPlayButtonTapped: {
                    playerCommand.send(isPlaying ? .pause : .play)
                },
                onAudioTrackSelected: { id in
                    playerCommand.send(.changeAudioTrack(id: id))
                },
                onClosedCaptureLanguageSelected: { id in
                    playerCommand.send(.showClosedCaption(id: id))
                },
                onPlaybackRateChanged: { rate in
                    playerCommand.send(.rate(value: rate))
                },
                onBandwidthSelected: { bandwidth in
                    playerCommand.send(.changeBandWidth(value: bandwidth))
                }
            )
            .id(operationLayerID)

            VideoPlayerHUDLayer()
                .id(hudLayerID)
        }
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
}
