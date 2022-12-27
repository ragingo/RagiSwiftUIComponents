//
//  CardStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/26.
//

import SwiftUI
import UIKit

public protocol CardStyle {
    associatedtype Body: View
    typealias Configuration = CardStyleConfiguration

    @ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body
}

public struct CardStyleConfiguration {
    public struct Content: View {
        public let body: AnyView
    }

    public let content: Content
}

public struct CardPlainStyle: CardStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(Color(uiColor: .systemGray6))
    }
}

struct TypedCardStyle: CardStyle {
    typealias Body = AnyView

    let body: (Configuration) -> AnyView

    init<S: CardStyle>(_ style: S) {
        self.body = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> AnyView {
        body(configuration)
    }
}

private struct CardStyleKey: EnvironmentKey {
    static let defaultValue = TypedCardStyle(CardPlainStyle())
}

extension EnvironmentValues {
    var cardStyle: TypedCardStyle {
        get {
            self[CardStyleKey.self]
        }
        set {
            self[CardStyleKey.self] = newValue
        }
    }
}

public extension View {
    func cardStyle<S>(_ style: S) -> some View where S: CardStyle {
        environment(\.cardStyle, TypedCardStyle(style))
    }
}
