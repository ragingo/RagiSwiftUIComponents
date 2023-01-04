//
//  VideoPlayerDebugView.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/03.
//

import Combine
import SwiftUI
import RagiSwiftUIComponents

struct VideoPlayerDebugView: View {
    private let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    @State private var playerCommand = PassthroughSubject<VideoPlayer.PlayerCommand, Never>()
    @State private var isPlaying = false

    var body: some View {
        VStack {
            Button {
                isPlaying.toggle()
                if isPlaying {
                    playerCommand.send(.play)
                } else {
                    playerCommand.send(.pause)
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }
            VideoPlayer(url: url, autoPlay: true, playerCommand: playerCommand.eraseToAnyPublisher())
                .onAppear {
                    playerCommand.send(.open(url: url))
                }
        }
    }
}

struct VideoPlayerDebugView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerDebugView()
    }
}
