//
//  Expander.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import SwiftUI

public struct Expander<Header: View, Content: View>: View {
    @Environment(\.expanderStyle) var expanderStyle
    private var isExpanded: Binding<Bool>
    private let header: (Binding<Bool>) -> Header
    private let content: (Binding<Bool>) -> Content

    public init(
        isExpanded: Binding<Bool>,
        header: @escaping (Binding<Bool>) -> Header,
        content: @escaping (Binding<Bool>) -> Content
    ) {
        self.isExpanded = isExpanded
        self.header = header
        self.content = content
    }

    public var body: some View {
        expanderStyle.makeBody(configuration: .init(
            isExpanded: isExpanded,
            header: .init(body: .init(header(isExpanded))),
            content: .init(body: .init(
                content(isExpanded)
                    .frame(minHeight: 0, maxHeight: isExpanded.wrappedValue ? nil : 0)
                    .clipped()
                    .allowsHitTesting(isExpanded.wrappedValue)
            ))
        ))
    }
}

struct Expander_Previews: PreviewProvider {
    struct PreviewView: View {
        @State var isExpanded1 = false
        @State var showAlert1 = false
        @State var selectedItem: Int?

        @State var isExpanded2 = false

        var body: some View {
            VStack(spacing: 8) {
                Expander(
                    isExpanded: $isExpanded1,
                    header: { isExpanded in
                        Text(isExpanded.wrappedValue ? "expanded" : "collapsed")
                    },
                    content: { _ in
                        List(1...100, id: \.self) { item in
                            Button {
                                showAlert1 = true
                                selectedItem = item
                            } label: {
                                Text("\(item)")
                            }
                        }
                        .padding(0)
                    }
                )
                .padding(.horizontal)
                .alert(isPresented: $showAlert1) {
                    .init(title: Text("selectedItem: \(selectedItem ?? -1)"))
                }
                .expanderStyle(.outlined(border: .init(color: .gray, radius: 10, lineWidth: 1)))

                Expander(
                    isExpanded: $isExpanded2,
                    header: { isExpanded in
                        ExpanderHeader(
                            isExpanded: isExpanded,
                            label: {
                                Text(isExpanded.wrappedValue ? "expanded" : "collapsed")
                            },
                            toggleIcon: {
                                Rectangle()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.blue)
                                    .rotationEffect(isExpanded.wrappedValue ? .degrees(360) : .zero)
                            }
                        )
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow)
                        )
                    },
                    content: { _ in
                        ScrollView {
                            LazyVStack {
                                ForEach(1...100, id: \.self) { item in
                                    Text("\(item)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(8)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.gray, lineWidth: 1)
                        )
                    }
                )
                .padding(.horizontal)

                Spacer()
            }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
