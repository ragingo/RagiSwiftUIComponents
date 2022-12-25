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
    public struct Properties {
        var backgroundColor: Color?

        public init(backgroundColor: Color? = nil) {
            self.backgroundColor = backgroundColor
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
            .background(properties?.backgroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder()
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
                    properties: .init(backgroundColor: .blue.opacity(0.2)),
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
                .padding()
            }
        }
    }
}
