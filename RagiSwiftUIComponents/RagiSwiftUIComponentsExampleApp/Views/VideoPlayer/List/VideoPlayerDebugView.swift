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
    private static let jsonURL = URL(string: "https://gist.githubusercontent.com/ragingo/99f944df4c9164eae97c63b3b8e2a37d/raw/42d2864f8bc51539be3f578c31d3223954a1192c/videos.json")!

    @State private var videos: [Video] = []
    @State private var selectedVideo: Video?

    var body: some View {
        List(videos, id: \.self) { video in
            NavigationLink(
                destination: {
                    CustomVideoPlayer(selectedVideo: video)
                        .navigationTitle("\(video.title)")
                },
                label: {
                    Text("\(video.title)")
                }
            )
        }
        .onAppear {
            Task {
                var request = URLRequest(url: Self.jsonURL)
                request.httpMethod = "GET"
                request.setValue("RagiSwiftUIComponents-VideoPlayerDebugView", forHTTPHeaderField: "User-Agent")
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(VideosResponse.self, from: data)
                    videos = response.videos
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct VideoPlayerDebugView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerDebugView()
    }
}
