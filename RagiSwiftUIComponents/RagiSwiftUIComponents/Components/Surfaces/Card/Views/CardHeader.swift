//
//  CardHeader.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
/// https://mui.com/material-ui/react-card/
/// https://mui.com/material-ui/api/card-header/
public struct CardHeader<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
    }
}

struct CardHeader_Previews: PreviewProvider {
    static var previews: some View {
        CardHeader(title: { Text("title") })
    }
}
