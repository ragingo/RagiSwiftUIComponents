//
//  ExpanderStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import SwiftUI

public protocol ExpanderStyle {
    associatedtype Body: View
    typealias Configuration = ExpanderConfiguration

    @ViewBuilder func makeBody(configuration: Configuration) -> Self.Body
}

public struct ExpanderConfiguration {
    public struct Header: View {
        public let body: AnyView
    }
    public struct Content: View {
        public let body: AnyView
    }

    public let isExpanded: Binding<Bool>
    public let header: Header
    public let content: Content
}

public struct ExpanderPlainStyle: ExpanderStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            ExpanderHeader(
                isExpanded: configuration.isExpanded,
                label: {
                    configuration.header
                },
                toggleIcon: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(configuration.isExpanded.wrappedValue ? .degrees(90) : .zero)
                }
            )
            .padding()

            configuration.content
        }
    }
}

extension ExpanderStyle where Self == ExpanderPlainStyle {
    public static func plain() -> ExpanderPlainStyle {
        ExpanderPlainStyle()
    }
}

struct TypedExpanderStyle: ExpanderStyle {
    typealias Body = AnyView

    let body: (ExpanderConfiguration) -> AnyView

    init<S: ExpanderStyle>(_ style: S) {
        self.body = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: ExpanderConfiguration) -> AnyView {
        body(configuration)
    }
}

private struct ExpanderStyleKey: EnvironmentKey {
    static let defaultValue: TypedExpanderStyle = .init(.plain())
}

extension EnvironmentValues {
    var expanderStyle: TypedExpanderStyle {
        get {
            self[ExpanderStyleKey.self]
        }
        set {
            self[ExpanderStyleKey.self] = newValue
        }
    }
}

public extension View {
    func expanderStyle<S>(_ style: S) -> some View where S: ExpanderStyle {
        environment(\.expanderStyle, TypedExpanderStyle(style))
    }
}

struct ExpanderStyle_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var isExpanded = true

        var body: some View {
            VStack {
                Expander(
                    header: { _ in
                        Text("header")
                    },
                    content: { _ in
                        List(0..<10) { item in
                            Text("\(item)")
                        }
                        .listStyle(.plain)
                    }
                )
                .expanderStyle(.plain())

                Spacer()
            }
            .padding()
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
