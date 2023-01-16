//
//  PlaybackRateSlider.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/16.
//

import SwiftUI
import RagiSwiftUIComponents

struct PlaybackRateSlider: View {
    let onRateValueChanged: (Float) -> Void

    @State private var rateSliderValue = 0.0

    var body: some View {
        RagiSwiftUIComponents.Slider(value: $rateSliderValue)
            .onHandleDragging { isDragging in
                if !isDragging {
                    let rate = Float((rateSliderValue * 100.0 * 5.0).rounded(.down)) / 100.0
                    onRateValueChanged(rate)
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

struct PlaybackRateSlider_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackRateSlider { _ in }
    }
}
