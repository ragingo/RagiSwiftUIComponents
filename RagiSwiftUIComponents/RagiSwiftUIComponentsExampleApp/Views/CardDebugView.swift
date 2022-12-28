//
//  CardDebugView.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2022/12/27.
//

import SwiftUI
import RagiSwiftUIComponents

struct CardDebugView: View {
    private let longText = String(repeating: "Hello, world!", count: 4)
    private let remoteLargeImageURL = URL(string: "https://picsum.photos/id/526/1000/1000")!

    @State private var elevation: Elevation = .level0

    var body: some View {
        TabView {
            makeAllPatterns()
                .tabItem {
                    Text("patterns")
                }
            makeAllStyles()
                .tabItem {
                    Text("styles")
                }
        }
    }

    @ViewBuilder
    private func makeAllPatterns() -> some View {
        ScrollView {
            LazyVStack {
                Card(
                    header: { makeCardHeader(title: Text("title")) }
                )
                Card(
                    header: { makeCardHeader() },
                    media: { makeCardMedia() }
                )
                Card(
                    header: { makeCardHeader() },
                    content: { makeCardContent() }
                )
                Card(
                    header: { makeCardHeader() },
                    actions: { makeCardActions() }
                )
                Card(
                    header: { makeCardHeader() },
                    media: { makeCardMedia() },
                    content: { makeCardContent() },
                    actions: { makeCardActions() }
                )
                Card(
                    header: { makeCardHeader(title: Text("title")) },
                    media: { makeCardMedia() },
                    content: { makeCardContent() },
                    actions: { makeCardActions() }
                )
                Card(
                    header: { makeCardHeader(title: Text("title"), subheader: Text("subheader")) },
                    media: { makeCardMedia() },
                    content: { makeCardContent() },
                    actions: { makeCardActions() }
                )
            }
            .cardStyle(.outline())
            .padding()
        }
    }

    @ViewBuilder
    private func makeAllStyles() -> some View {
        ScrollView {
            LazyVStack {
                heading("plain")
                makeCard()
                    .cardStyle(.plain())

                heading("outline")
                makeCard()
                    .cardStyle(.outline(background: { Color.blue.opacity(0.2) }))

                heading("filled")
                makeCard()
                    .cardStyle(.filled(background: { Color.green.opacity(0.2) }))

                heading("elevated")
                makeCard()
                    .cardStyle(.elevated(elevation: elevation, background: { Color.yellow }))
                    .onTapGesture {
                        elevation = elevation.next
                    }
            }
            .padding()
        }
    }

    private func heading(_ text: String, backgroundColor: Color = .gray.opacity(0.5)) -> some View {
        Text(text).frame(maxWidth: .infinity).background(backgroundColor)
    }

    @ViewBuilder
    private func iif(
        _ condition: @autoclosure @escaping () -> Bool,
        _ trueView: some View,
        _ falseView: some View
    ) -> some View {
        if condition() {
            trueView
        } else {
            falseView
        }
    }

    private func makeCardHeader(title: Text? = nil, subheader: Text? = nil) -> some View {
        CardHeader(
            title: { iif(title != nil, title, EmptyView()) },
            subheader: { iif(subheader != nil, subheader, EmptyView()) },
            avator: {
                Image(systemName: "star")
            },
            action: {
                Button(
                    action: {},
                    label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .frame(width: 48, height: 48)
                    }
                )
                .buttonStyle(.plain)
            }
        )
    }

    private func makeCardMedia() -> some View {
        CardMedia(url: remoteLargeImageURL) { imagePhrase in
            if let image = imagePhrase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100, alignment: .center)
                    .clipped()
            }
        }
    }

    private func makeCardContent() -> some View {
        CardContent {
            VStack {
                Text(longText)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func makeCardActions() -> some View {
        CardActions {
            HStack {
                Image(systemName: "heart")
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func makeCard(title: Text? = nil, subheader: Text? = nil) -> some View {
        Card(
            properties: .init(),
            header: { makeCardHeader(title: title, subheader: subheader) },
            media: { makeCardMedia() },
            content: { makeCardContent() },
            actions: { makeCardActions() }
        )
    }
}

struct CardDebugView_Previews: PreviewProvider {
    static var previews: some View {
        CardDebugView()
    }
}
