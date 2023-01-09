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
            VideoPlayerInformationLayer()
            VideoPlayerOperationLayer(isPlaying: $isPlaying, duration: $duration, position: $position, isSeeking: $isSeeking, loadedRange: $loadedRange, playerCommand: $playerCommand, isPictureInPicturePossible: $isPictureInPicturePossible, isPictureInPictureEnabled: $isPictureInPictureEnabled, isSliderHandleDragging: $isSliderHandleDragging, sliderValue: $sliderValue)
            VideoPlayerHUDLayer()
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
}
