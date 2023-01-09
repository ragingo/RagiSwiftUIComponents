//
//  VideoPlayerPictureInPictureCover.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/09.
//

import SwiftUI

struct VideoPlayerPictureInPictureCover: View {
    var body: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Text("Picture in Picture 実行中！")
                    .font(.largeTitle)
            }
    }
}

struct VideoPlayerPictureInPictureCover_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerPictureInPictureCover()
    }
}
