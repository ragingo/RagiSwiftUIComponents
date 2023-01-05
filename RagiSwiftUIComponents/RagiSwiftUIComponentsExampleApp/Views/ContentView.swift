//
//  ContentView.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2022/12/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                makeLink(
                    icon: { Image(systemName: "creditcard.fill") },
                    destination: { CardDebugView() },
                    description: "Card の動作確認用画面"
                )
                makeLink(
                    icon: { Image(systemName: "play.rectangle.fill") },
                    destination: { VideoPlayerDebugView() },
                    description: "VideoPlayer の動作確認用画面"
                )
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func makeLink(
        @ViewBuilder icon: @escaping () -> some View,
        @ViewBuilder destination: @escaping () -> some View,
        description: String
    ) -> some View {
        let destination = destination()
        let title = String(describing: type(of: destination))

        NavigationLink(
            destination: {
                destination
                    .navigationTitle(title)
            },
            label: {
                icon()

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title2)

                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
