//
//  VideoPlayer.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import SwiftUI

public struct VideoPlayer: View {
    private var player = InternalVideoPlayer()

    private let url: URL
    private let autoPlay: Bool

    public init(url: URL, autoPlay: Bool = true) {
        self.url = url
        self.autoPlay = autoPlay
    }

    public var body: some View {
        VideoSurfaceView(playerLayer: player.playerLayer)
            .onAppear {
                Task {
                    await player.execute(command: .open(url: url))
                    if autoPlay {
                        await player.execute(command: .play)
                    }
                }
            }
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayer(
            url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        )
    }
}
