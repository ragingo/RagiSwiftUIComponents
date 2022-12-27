//
//  CardOutlinedStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/27.
//

import SwiftUI

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

extension CardStyle where Self == CardOutlinedStyle {
    public static var outline: CardOutlinedStyle { .init() }
}
