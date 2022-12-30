//
//  SliderLabel.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/30.
//

import SwiftUI

public struct SliderLabel: View {
    private let color: Color
    private let label: Binding<String>
    private let font: Font?

    public init(color: Color, label: Binding<String>, font: Font? = nil) {
        self.color = color
        self.label = label
        self.font = font
    }

    public var body: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .foregroundColor(color)
            .rotationEffect(.degrees(180))
            .scaledToFit()
            .overlay {
                Text(label.wrappedValue)
                    .font(font ?? .system(size: 1000))
                    .minimumScaleFactor(0.001)
                    .lineLimit(1)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
    }
}

struct SliderLabel_Previews: PreviewProvider {
    static var previews: some View {
        SliderLabel(
            color: .yellow,
            label: .constant("77")
        )
    }
}
