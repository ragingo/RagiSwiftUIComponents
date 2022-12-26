//
//  CardActions.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
public struct CardActions<Content: View>: View {
    private let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .padding(8)
    }
}

struct CardActions_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var isLiked = false
        @State private var isExpanded = false

        var body: some View {
            CardActions {
                HStack {
                    likeButton
                    shareButton
                    Spacer()
                    showMoreButton
                }
            }
            .background(.gray.opacity(0.4))
        }

        var likeButton: some View {
            Button {
                withAnimation {
                    isLiked.toggle()
                }
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .scaleEffect(1.2)
            }
            .buttonStyle(.plain)
        }

        var shareButton: some View {
            Button {
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .scaleEffect(1.2)
            }
            .buttonStyle(.plain)
        }

        var showMoreButton: some View {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .scaleEffect(1.2)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .buttonStyle(.plain)
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
