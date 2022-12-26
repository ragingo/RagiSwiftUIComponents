//
//  Card.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
/// https://mui.com/material-ui/react-card/
/// https://mui.com/material-ui/api/card/
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
        content()
            .background(cardStyle.background)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(cardStyle.borderColor ?? .gray)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
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
                            title: { Text("title") },
                            subheader: { Text("subheader") },
                            avator: { Image(systemName: "star") },
                            action: { Image(systemName: "pencil") }
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
                .cardStyle(CardCustomStyle(
                    background: { Color.blue.blur(radius: 4) },
                    borderColor: .red
                ))
                .padding()
            }
        }
    }
}
