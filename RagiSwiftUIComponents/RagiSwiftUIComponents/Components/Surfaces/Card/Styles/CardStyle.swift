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
    }
}

public struct CardOutlinedStyle: CardStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: CardConstants.borderRadius)
                    .strokeBorder(.gray)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: CardConstants.borderRadius)
            )
    }
}

public struct CardFilledStyle: CardStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(.gray)
            .overlay {
                RoundedRectangle(cornerRadius: CardConstants.borderRadius)
                    .fill(.clear)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: CardConstants.borderRadius)
            )
    }
}

private struct CardStyleKey: EnvironmentKey {
    static let defaultValue: any CardStyle = CardPlainStyle()
}

extension EnvironmentValues {
    var cardStyle: any CardStyle {
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
        environment(\.cardStyle, style)
    }
}
