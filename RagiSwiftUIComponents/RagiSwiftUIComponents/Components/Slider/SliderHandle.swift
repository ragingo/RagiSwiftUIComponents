//
//  SliderHandle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/29.
//

import SwiftUI

public struct SliderHandle<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
    }
}

struct SliderHandle_Previews: PreviewProvider {
    static var previews: some View {
        SliderHandle {
            Circle()
                .fill(.white)
                .shadow(radius: 10)
        }
        .frame(width: 50, height: 50)
    }
}
