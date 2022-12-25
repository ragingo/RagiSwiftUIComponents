//
//  Card+Initializers.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/25.
//

import SwiftUI

extension Card {
    public init<
        CardHeader: View,
        CardMedia: View,
        CardContent: View,
        CardActions: View
    >(
        properties: Properties? = nil,
        @ViewBuilder header: @escaping () -> CardHeader,
        @ViewBuilder media: @escaping () -> CardMedia,
        @ViewBuilder content: @escaping () -> CardContent,
        @ViewBuilder actions: @escaping () -> CardActions
    ) where Content == VStack<
        TupleView<(
            CardHeader,
            CardMedia,
            CardContent,
            CardActions
        )>
    > {
        self.init(properties: properties) {
            VStack(spacing: 0) {
                header()
                media()
                content()
                actions()
            }
        }
    }
}
