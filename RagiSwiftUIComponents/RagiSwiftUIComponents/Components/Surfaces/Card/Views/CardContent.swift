//
//  CardContent.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
/// https://mui.com/material-ui/react-card/
/// https://mui.com/material-ui/api/card-content/
public struct CardContent<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .padding(16)
    }
}

struct CardContent_Previews: PreviewProvider {
    static var previews: some View {
        CardContent {
            Text("content")
        }
        .background(.gray.opacity(0.4))
    }
}
