//
//  SliderStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/29.
//

import SwiftUI

public protocol SliderStyle {
    associatedtype ActiveTrack: View
    associatedtype InactiveTrack: View
    associatedtype Handle: View
    associatedtype Body: View

    @ViewBuilder func makeActiveTrack(configuration: SliderTrackConfiguration) -> Self.ActiveTrack
    @ViewBuilder func makeInactiveTrack(configuration: SliderTrackConfiguration) -> Self.InactiveTrack
    @ViewBuilder func makeHandle(configuration: SliderHandleConfiguration) -> Self.Handle
    @ViewBuilder func makeBody(configuration: SliderConfiguration) -> Self.Body
}

public struct SliderTrackConfiguration {
    public struct Content: View {
        public let body: AnyView
    }
    public let content: Content
}

public struct SliderHandleConfiguration {
}

public struct SliderConfiguration {
    public struct Content: View {
        public let body: AnyView
    }
    public let content: Content
}

public struct SliderPlainStyle: SliderStyle {
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
            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
                .shadow(elevation: .level1, cornerRadius: 10)
        }
        .offset(y: Self.trackHeight * 0.5)
    }

    public func makeBody(configuration: SliderConfiguration) -> some View {
        configuration.content
    }
}

extension SliderStyle where Self == SliderPlainStyle {
    public static func plain() -> SliderPlainStyle {
        SliderPlainStyle()
    }
}

struct TypedSliderStyle: SliderStyle {
    typealias Body = AnyView

    let activeTrack: (SliderTrackConfiguration) -> AnyView
    let inactiveTrack: (SliderTrackConfiguration) -> AnyView
    let handle: (SliderHandleConfiguration) -> AnyView
    let body: (SliderConfiguration) -> AnyView

    init<S: SliderStyle>(_ style: S) {
        self.activeTrack = { configuration in
            AnyView(style.makeActiveTrack(configuration: configuration))
        }
        self.inactiveTrack = { configuration in
            AnyView(style.makeInactiveTrack(configuration: configuration))
        }
        self.handle = { configuration in
            AnyView(style.makeHandle(configuration: configuration))
        }
        self.body = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeActiveTrack(configuration: SliderTrackConfiguration) -> AnyView {
        activeTrack(configuration)
    }

    func makeInactiveTrack(configuration: SliderTrackConfiguration) -> AnyView {
        inactiveTrack(configuration)
    }

    func makeHandle(configuration: SliderHandleConfiguration) -> AnyView {
        handle(configuration)
    }

    func makeBody(configuration: SliderConfiguration) -> AnyView {
        body(configuration)
    }
}

private struct SliderStyleKey: EnvironmentKey {
    static let defaultValue = TypedSliderStyle(SliderPlainStyle())
}

extension EnvironmentValues {
    var sliderStyle: TypedSliderStyle {
        get {
            self[SliderStyleKey.self]
        }
        set {
            self[SliderStyleKey.self] = newValue
        }
    }
}

public extension View {
    func sliderStyle<S>(_ style: S) -> some View where S: SliderStyle {
        environment(\.sliderStyle, TypedSliderStyle(style))
    }
}

struct SliderStyle_Previews: PreviewProvider {
    struct DebugSliderStyle: SliderStyle {
        func makeActiveTrack(configuration: SliderTrackConfiguration) -> some View {
            Image(systemName: "box.truck.fill")
                .resizable()
                .frame(height: 50)
                .foregroundColor(.blue)
        }

        func makeInactiveTrack(configuration: SliderTrackConfiguration) -> some View {
            Color.gray
        }

        func makeHandle(configuration: SliderHandleConfiguration) -> some View {
            Image(systemName: "box.truck.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.green)
                .rotation3DEffect(.degrees(-30), axis: (x: 0, y: 0, z: 1))
                .shadow(radius: 4)
        }

        func makeBody(configuration: SliderConfiguration) -> some View {
            configuration.content
        }
    }

    static var previews: some View {
        VStack(spacing: 30) {
            Slider()
                .sliderStyle(.plain())
            Slider()
                .sliderStyle(DebugSliderStyle())
        }
        .padding(20)
    }
}
