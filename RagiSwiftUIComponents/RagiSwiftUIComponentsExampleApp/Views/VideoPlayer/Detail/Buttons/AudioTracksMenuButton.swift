//
//  AudioTracksMenuButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/15.
//

import SwiftUI

struct AudioTracksMenuButton: View {
    let tracks: [(id: String, displayName: String)]
    let onTrackSelected: (_ id: String) -> Void

    @State private var selectedTrackID: String?

    var body: some View {
        Menu {
            if tracks.isEmpty {
                Text("副音声なし")
            }

            ForEach(tracks, id: \.id) { track in
                Button {
                    selectedTrackID = track.id
                    onTrackSelected(track.id)
                } label: {
                    HStack {
                        Text("\(track.displayName) (\(track.id))")
                        if selectedTrackID == track.id {
                            Image(systemName: "checkmark")
                                .tint(.white)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: tracks.isEmpty ? "waveform.circle" : "waveform.circle.fill")
                .tint(.white)
        }
    }
}

struct AudioTracksMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        let tracks = [
            (id: "en", displayName: "英語"),
            (id: "ja", displayName: "日本語"),
        ]
        VStack(spacing: 16) {
            AudioTracksMenuButton(tracks: []) { _ in }
            AudioTracksMenuButton(tracks: tracks.filter { $0.id == "en" }) { _ in }
            AudioTracksMenuButton(tracks: tracks) { _ in }
        }
        .padding()
        .background(.gray)
    }
}
