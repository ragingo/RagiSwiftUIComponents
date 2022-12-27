//
//  Card.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
/// https://www.figma.com/community/file/1035203688168086460
public struct Card<Content: View>: View {
    @Environment(\.cardStyle) var cardStyle

    public struct Properties {
        public init() {
        }
    }

    private let content: () -> Content
    private let properties: Properties?

    public init(
        properties: Properties? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.properties = properties
    }

    public var body: some View {
        cardStyle.makeBody(configuration: .init(content: .init(body: .init(content()))))
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        let longText = String(repeating: "Hello, world!", count: 5)
        let remoteLargeImageURL = URL(string: "https://picsum.photos/id/526/1000/1000")!

        ScrollView {
            VStack(spacing: 0) {
                Card(
                    properties: .init(),
                    header: {
                        CardHeader(
                            title: {
                                Text("title")
                                    .font(.title2)
                            },
                            subheader: {
                                Text("subheader")
                                    .font(.subheadline)
                            },
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
                    },
                    media: {
                        CardMedia(url: remoteLargeImageURL) { imagePhrase in
                            if let image = imagePhrase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200, alignment: .center)
                                    .clipped()
                            }
                        }
                    },
                    content: {
                        CardContent {
                            VStack {
                                Text(longText)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    },
                    actions: {
                        CardActions {
                            HStack {
                                Image(systemName: "heart")
                                Spacer()
                            }
                        }
                    }
                )
                .cardStyle(.outline())
                .padding()
            }
        }
    }
}
