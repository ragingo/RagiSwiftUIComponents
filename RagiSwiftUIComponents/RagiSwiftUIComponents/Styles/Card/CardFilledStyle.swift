//
//  CardFilledStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/27.
//

import SwiftUI

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

extension CardStyle where Self == CardFilledStyle {
    public static var filled: CardFilledStyle { .init() }
}
