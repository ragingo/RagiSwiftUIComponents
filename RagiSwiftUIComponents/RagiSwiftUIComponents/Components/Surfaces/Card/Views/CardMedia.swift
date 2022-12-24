//
//  CardMedia.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
/// https://mui.com/material-ui/react-card/
/// https://mui.com/material-ui/api/card-media/
public struct CardMedia<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
    }
}

extension CardMedia {
    public init(assetImageName: String) where Content == Image {
        self.init {
            Image(assetImageName)
                .resizable()
        }
    }

    public init(systemImageName: String) where Content == Image {
        self.init {
            Image(systemName: systemImageName)
                .resizable()
        }
    }

    public init<AsyncImageContent: View>(
        url: URL,
        @ViewBuilder asyncImageContent: @escaping (AsyncImagePhase) -> AsyncImageContent
    ) where Content == AsyncImage<AsyncImageContent> {
        self.init {
            AsyncImage(url: url) {
                asyncImageContent($0)
            }
        }
    }
}

// MARK: - Preview
struct CardMedia_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardMedia(systemImageName: "star")
                .aspectRatio(contentMode: .fill)
                .background(.yellow)
                .frame(width: 300, height: 50, alignment: .top)
                .clipped()
            CardMedia(systemImageName: "star")
                .aspectRatio(contentMode: .fill)
                .background(.green)
                .frame(width: 300, height: 50, alignment: .center)
                .clipped()
            CardMedia(systemImageName: "star")
                .aspectRatio(contentMode: .fill)
                .background(.red)
                .frame(width: 300, height: 50, alignment: .bottom)
                .clipped()
            CardMedia(systemImageName: "star")
                .aspectRatio(contentMode: .fit)
                .background(.blue)
                .frame(width: 300, height: 50, alignment: .leading)
                .background(.black)
                .clipped()
            CardMedia(systemImageName: "star")
                .aspectRatio(contentMode: .fit)
                .background(.blue)
                .frame(width: 300, height: 50, alignment: .center)
                .background(.black)
                .clipped()
            CardMedia(systemImageName: "star")
                .aspectRatio(contentMode: .fit)
                .background(.blue)
                .frame(width: 300, height: 50, alignment: .trailing)
                .background(.black)
                .clipped()

            let remoteLargeImageURL = URL(string: "https://picsum.photos/id/526/1000/1000")!
            CardMedia(url: remoteLargeImageURL) { imagePhrase in
                if let image = imagePhrase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 100, alignment: .top)
                        .background(.black)
                        .clipped()
                } else if imagePhrase.error != nil {
                    Image("exclamationmark.triangle.fill")
                } else {
                    Color.black
                        .overlay {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                }
            }
        }
    }
}
