//
//  CardFilledStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/27.
//

import SwiftUI

public struct CardFilledStyle: CardStyle {
    private let background: () -> AnyView

    public init<Background: View>(@ViewBuilder background: @escaping () -> Background) {
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
    }
}

extension CardStyle where Self == CardFilledStyle {
    public static func filled<Background: View>(
        @ViewBuilder background: @escaping () -> Background = { Color(uiColor: .systemGray6) }
    ) -> CardFilledStyle {
        CardFilledStyle(background: background)
    }
}
