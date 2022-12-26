//
//  CardStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/26.
//

import SwiftUI
import UIKit

public protocol CardStyle {
    var background: AnyView { get }
    var borderColor: Color? { get }
}

public struct CardCustomStyle: CardStyle {
    public var background: AnyView
    public var borderColor: Color?

    public init(
        @ViewBuilder background: @escaping () -> some View = { EmptyView() },
        borderColor: Color? = nil
    ) {
        self.background = AnyView(background())
        self.borderColor = borderColor
    }
}

private struct CardStyleKey: EnvironmentKey {
    static let defaultValue: any CardStyle = CardCustomStyle()
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
