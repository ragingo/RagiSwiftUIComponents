//
//  Slider.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/28.
//

import SwiftUI

public struct Slider<Label: View>: View {
    @Environment(\.sliderStyle) var sliderStyle
    @State private var isDragging = false
    @State private var handlePositionX: CGFloat = 0
    private let sliderTrackSpaceName = UUID()
    private var _onValueChanged: ((Double) -> Void)?
    private var _onHandleDragging: ((Bool) -> Void)?

    private var value: Binding<Double>
    private var label: () -> Label

    public init(
        value: Binding<Double> = .constant(0),
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.value = value
        self.label = label
    }

    public init(value: Binding<Double> = .constant(0)) where Label == EmptyView {
        self.init(value: value, label: { EmptyView() })
    }

    public var body: some View {
        GeometryReader { geometry in
            sliderStyle.makeBody(configuration: .init(content: .init(body: .init(
                makeTrackContainer(maxWidth: geometry.size.width)
            ))))
            .onChange(of: handlePositionX) { _ in
                let newValue = handlePositionX / geometry.size.width
                value.wrappedValue = newValue
                _onValueChanged?(newValue)
            }
            .onChange(of: value.wrappedValue) { _ in
                handlePositionX = geometry.size.width * value.wrappedValue
            }
            .onChange(of: isDragging) { _ in
                _onHandleDragging?(isDragging)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    public func onValueChanged(_ action: @escaping (Double) -> Void) -> Self {
        var slider = self
        slider._onValueChanged = action
        return slider
    }

    public func onHandleDragging(_ action: @escaping (Bool) -> Void) -> Self {
        var slider = self
        slider._onHandleDragging = action
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
                isDragging = true
            }
            .onEnded { _ in
                isDragging = false
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
            sliderStyle.makeHandle(configuration: .init(isPressed: isDragging))
                .overlay {
                    label()
                        .opacity(isDragging ? 1.0 : 0.0)
                        .animation(.easeInOut, value: isDragging)
                }
                .position(x: handlePositionX)
        }
    }
}

extension Slider {
    public init() where Label == EmptyView {
        self.init(label: { EmptyView() })
    }
}

struct Slider_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var value1 = 0.0
        @State private var value2 = 0.0
        @State private var label = ""

        var body: some View {
            VStack {
                Text("value1: \(value1)")
                Text("value2: \(value2)")

                Slider(
                    value: $value2,
                    label: {
                        SliderLabel(color: .gray.opacity(0.2), label: $label, font: .system(size: 10))
                            .scaleEffect(2)
                            .offset(y: -32)
                    }
                )
                .onValueChanged {
                    value1 = $0
                }
                .padding(.horizontal, 50)

                Button {
                    value2 = 0
                } label: {
                    Text("reset")
                }
            }
            .onChange(of: value2) { _ in
                label = "\(Int(value2 * 100)) %"
            }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
