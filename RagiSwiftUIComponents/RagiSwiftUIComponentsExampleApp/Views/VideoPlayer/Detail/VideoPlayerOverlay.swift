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
                playerCommand: $playerCommand,
                isPictureInPicturePossible: $isPictureInPicturePossible,
                isPictureInPictureEnabled: $isPictureInPictureEnabled,
                isSliderHandleDragging: $isSliderHandleDragging,
                sliderValue: $sliderValue,
                closedCaptionLanguages: $closedCaptionLanguages,
                audioTracks: $audioTracks
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
