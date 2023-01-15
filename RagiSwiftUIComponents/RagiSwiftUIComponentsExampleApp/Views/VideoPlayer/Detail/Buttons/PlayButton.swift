//
//  PlayButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/15.
//

import SwiftUI

struct PlayButton: View {
    let isPlaying: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .tint(.white)
        }
    }
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PlayButton(isPlaying: true) {}
            PlayButton(isPlaying: false) {}
        }
        .padding()
        .background(.gray)
    }
}
