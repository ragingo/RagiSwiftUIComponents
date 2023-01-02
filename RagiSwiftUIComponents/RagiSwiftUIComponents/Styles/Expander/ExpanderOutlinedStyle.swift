//
//  ExpanderOutlinedStyle.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import SwiftUI

public struct ExpanderOutlinedStyle: ExpanderStyle {
    public struct Border {
        public let color: Color
        public let radius: CGFloat
        public let lineWidth: CGFloat
    }

    public let border: Border

    public func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 0) {
            ExpanderHeader(
                isExpanded: configuration.isExpanded,
                label: {
                    configuration.header
                },
                toggleIcon: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(configuration.isExpanded.wrappedValue ? .degrees(90) : .zero)
                }
            )
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: border.radius)
                    .strokeBorder(border.color, lineWidth: border.lineWidth)
                    .opacity(configuration.isExpanded.wrappedValue ? 0 : 1)
            )

            Divider()
                .opacity(configuration.isExpanded.wrappedValue ? 1 : 0)

            configuration.content
                .frame(maxWidth: .infinity)
        }
        .overlay(
            RoundedRectangle(cornerRadius: border.radius)
                .strokeBorder(border.color, lineWidth: border.lineWidth)
        )
    }
}

extension ExpanderStyle where Self == ExpanderOutlinedStyle {
    public static func outlined(border: ExpanderOutlinedStyle.Border) -> ExpanderOutlinedStyle {
        .init(border: border)
    }
}

struct ExpanderOutlinedStyle_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var isExpanded = true

        var body: some View {
            VStack {
                Expander(
                    isExpanded: $isExpanded,
                    header: { _ in
                        Text("header")
                    },
                    content: { _ in
                        List(0..<10) { item in
                            Text("\(item)")
                        }
                        .listStyle(.plain)
                    }
                )
                .expanderStyle(.outlined(border: .init(color: .gray, radius: 8, lineWidth: 1)))

                Spacer()
            }
            .padding()
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
