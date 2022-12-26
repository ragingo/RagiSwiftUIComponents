//
//  CardHeader.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

/// https://m3.material.io/components/cards/guidelines
public struct CardHeader<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .padding(.vertical, 12)
            .padding(.leading, 16)
            .padding(.trailing, 4)
    }
}

struct CardHeader_Previews: PreviewProvider {
    struct PreviewView: View {
        var body: some View {
            VStack(spacing: 0) {
                header(title: "Title")
                CardHeader(title: { title })

                Group {
                    header(title: "Title + Subheader")
                    CardHeader(title: { title }, subheader: { subheader })
                    header(title: "Title + Avator")
                    CardHeader(title: { title }, avator: { avator })
                    header(title: "Title + Action")
                    CardHeader(title: { title }, action: { action })
                }

                Group {
                    header(title: "Title + Subheader + Avator")
                    CardHeader(title: { title }, subheader: { subheader }, avator: { avator })
                    header(title: "Title + Subheader + Action")
                    CardHeader(title: { title }, subheader: { subheader }, action: { action })
                }

                Group {
                    header(title: "Title + Subheader + Avator + Action")
                    CardHeader(title: { title }, subheader: { subheader }, avator: { avator }, action: { action })
                }

                Spacer()
            }
        }

        func header(title: String) -> some View {
            Text(title)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .background(.green.opacity(0.2))
        }

        var title: some View {
            Text("title")
                .font(.title2)
        }

        var subheader: some View {
            Text("subheader")
                .font(.subheadline)
        }

        var avator: some View {
            Circle()
                .fill(.orange)
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(.blue)
                }
                .clipShape(Circle())
        }

        var action: some View {
            Button(
                action: {},
                label: {
                    Image(systemName: "ellipsis").rotationEffect(.degrees(90))
                }
            )
            .buttonStyle(.plain)
        }
    }

    static var previews: some View {
        ScrollView {
            PreviewView()
        }
    }
}
