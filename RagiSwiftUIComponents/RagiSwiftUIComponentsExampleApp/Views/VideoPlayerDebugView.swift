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
    private let videoPlayerID = UUID()

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
            VideoPlayer(url: url, autoPlay: false, playerCommand: playerCommand.eraseToAnyPublisher())
                // MEMO: ID がないと、 playerCommand を送った直後に VideoPlayer とその内部で保持しているオブジェクトが破棄されてしまう・・・
                .id(videoPlayerID)
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
