//
//  Slider.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/28.
//

import SwiftUI

public struct Slider: View {
    @State private var handlePositionX: CGFloat = 0
    private let sliderTrackSpaceName = UUID()
    private var onValueChanged: ((Double) -> Void)?

    @Environment(\.sliderStyle) var sliderStyle

    public var body: some View {
        GeometryReader { geometry in
            sliderStyle.makeBody(configuration: .init(content: .init(body: .init(
                makeTrackContainer(maxWidth: geometry.size.width)
            ))))
            .onChange(of: handlePositionX) { _ in
                onValueChanged?(handlePositionX / geometry.size.width)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    public func onValueChanged(_ action: @escaping (Double) -> Void) -> Self {
        var slider = self
        slider.onValueChanged = action
        return slider
    }

    private func makeTrackContainer(maxWidth: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            makeInactiveTrack(maxWidth: maxWidth)
            makeActiveTrack(maxWidth: maxWidth)
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(sliderTrackSpaceName))
            .onChanged { value in
                let x = min(max(value.location.x, 0), maxWidth)
                handlePositionX = x
            }
        )
    }

    private func makeInactiveTrack(maxWidth: CGFloat) -> some View {
        sliderStyle.makeInactiveTrack(configuration: .init(content: .init(body: .init(
            SliderTrack(width: .constant(maxWidth))
        ))))
        .coordinateSpace(name: sliderTrackSpaceName)
    }

    private func makeActiveTrack(maxWidth: CGFloat) -> some View {
        sliderStyle.makeActiveTrack(configuration: .init(content: .init(body: .init(
            SliderTrack(width: $handlePositionX)
        ))))
        .overlay {
            sliderStyle.makeHandle(configuration: .init())
                .position(x: handlePositionX)
        }
    }
}

struct Slider_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var positionRatio = 0.0

        var body: some View {
            VStack {
                Text("\(positionRatio)")

                Slider()
                    .onValueChanged {
                        positionRatio = $0
                    }
                    .padding(.horizontal, 50)
            }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
