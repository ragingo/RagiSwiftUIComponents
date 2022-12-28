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

    public var body: some View {
        GeometryReader { geometory in
            SliderTrack(size: .init(width: geometory.size.width, height: 4))
                .overlay {
                    SliderHandle {
                        Circle()
                            .fill(.white)
                            .frame(width: 20, height: 20)
                            .shadow(radius: 4)
                            .position(x: handlePositionX)
                    }
                    .gesture(DragGesture(coordinateSpace: .named(sliderTrackSpaceName))
                        .onChanged { value in
                            let x = min(max(value.location.x, 0), geometory.size.width)
                            handlePositionX = x
                        }
                    )
                }
                .coordinateSpace(name: sliderTrackSpaceName)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct Slider_Previews: PreviewProvider {
    static var previews: some View {
        Slider()
            .padding(50)
    }
}

public struct SliderTrack: View {
    private let color: Color
    private let size: CGSize

    public init(color: Color = Color(uiColor: .systemBlue), size: CGSize) {
        self.color = color
        self.size = size
    }

    public var body: some View {
        Path { path in
            path.addRect(.init(origin: .zero, size: size))
        }
        .fill(color)
    }
}


public struct SliderHandle<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
    }
}
