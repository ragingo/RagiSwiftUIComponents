//
//  CardElevatedStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/27.
//

import SwiftUI

public struct CardElevatedStyle: CardStyle {
    private let background: () -> AnyView
    private let elevation: Elevation

    public init<Background: View>(
        elevation: Elevation = .level1,
        @ViewBuilder background: @escaping () -> Background
    ) {
        self.elevation = elevation
        self.background = { AnyView(background()) }
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(background())
            .overlay {
                RoundedRectangle(cornerRadius: CardConstants.borderRadius)
                    .fill(.clear)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: CardConstants.borderRadius)
            )
            .shadow(elevation: elevation, cornerRadius: CardConstants.borderRadius)
    }
}

extension CardStyle where Self == CardElevatedStyle {
    public static func elevated<Background: View>(
        elevation: Elevation = .level1,
        @ViewBuilder background: @escaping () -> Background = { Color(uiColor: .systemGray6) }
    ) -> CardElevatedStyle {
        CardElevatedStyle(elevation: elevation, background: background)
    }
}
