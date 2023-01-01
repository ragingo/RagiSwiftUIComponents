//
//  VideoPlayerSlider.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/01.
//

import SwiftUI

public struct VideoPlayerSlider: View {
    private static let trackHeight: CGFloat = 4
    @State private var isDragging = false
    @State private var handlePositionX: CGFloat = 0
    @State private var rangeStart: CGFloat = 0
    @State private var rangeEnd: CGFloat = 0
    private let sliderTrackSpaceName = UUID()
    private var onValueChanged: ((Double) -> Void)?

    private var position: Binding<Double>
    private var loadedRange: Binding<(Double, Double)>

    public init(
        position: Binding<Double>,
        loadedRange: Binding<(Double, Double)> = .constant((0, 0))
    ) {
        self.position = position
        self.loadedRange = loadedRange
    }

    public var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            makeTrackContainer(maxWidth: width)
                .onChange(of: handlePositionX) { _ in
                    let newValue = handlePositionX / width
                    position.wrappedValue = newValue
                    onValueChanged?(newValue)
                }
                .onChange(of: position.wrappedValue) { _ in
                    handlePositionX = width * position.wrappedValue
                }
                .onAppear {
                    updateBufferTrack(maxWidth: width)
                }
                .onChange(of: loadedRange.0.wrappedValue) { _ in
                    updateBufferTrack(maxWidth: width)
                }
                .onChange(of: loadedRange.1.wrappedValue) { _ in
                    updateBufferTrack(maxWidth: width)
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
            makeBufferTrack()
            makeActiveTrack(maxWidth: maxWidth)
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named(sliderTrackSpaceName))
            .onChanged { value in
                let x = min(max(value.location.x, 0), maxWidth)
                handlePositionX = x
                isDragging = true
            }
            .onEnded { _ in
                isDragging = false
            }
        )
    }

    private func makeInactiveTrack(maxWidth: CGFloat) -> some View {
        SliderTrack(width: .constant(maxWidth))
            .coordinateSpace(name: sliderTrackSpaceName)
            .frame(height: Self.trackHeight)
            .foregroundColor(Color(uiColor: .systemGray6))
    }

    private func makeActiveTrack(maxWidth: CGFloat) -> some View {
        SliderTrack(width: $handlePositionX)
            .frame(height: Self.trackHeight)
            .foregroundColor(Color(uiColor: .systemBlue))
            .overlay {
                SliderHandle {
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .shadow(elevation: .level1, cornerRadius: 10)
                        .background(
                            Circle()
                                .fill(.gray.opacity(0.2))
                                .scaleEffect(2.0)
                                .opacity(isDragging ? 1 : 0)
                                .animation(.default, value: isDragging)
                        )
                }
                .offset(y: Self.trackHeight * 0.5)
                .position(x: handlePositionX)
            }
    }

    private func makeBufferTrack() -> some View {
        SliderTrack(offset: $rangeStart, width: $rangeEnd)
            .frame(height: Self.trackHeight)
            .foregroundColor(Color(uiColor: .systemGreen))
    }

    private func updateBufferTrack(maxWidth: CGFloat) {
        let (start, end) = loadedRange.wrappedValue
        rangeStart = min(max(maxWidth * start, 0), maxWidth)
        rangeEnd = min(max(maxWidth * (end - start), 0), maxWidth)
    }
}

struct VideoPlayerSlider_Previews: PreviewProvider {
    struct PreviewView: View {
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        @State private var position = 0.0
        @State private var range = (0.5, 0.0)

        var body: some View {
            VideoPlayerSlider(position: $position, loadedRange: $range)
                .padding(.horizontal, 50)
                .onReceive(timer) { _ in
                    if range.1 >= 1.0 {
                        range.1 = 0.0
                    }
                    range.1 += 0.2
                }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
