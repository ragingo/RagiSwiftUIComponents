//
//  VideoSurfaceView.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import UIKit
import SwiftUI
import AVFoundation

struct VideoSurfaceView: UIViewRepresentable {
    typealias UIViewType = UIView

    let playerLayer: AVPlayerLayer
    @Binding var pictureInPictureEnabled: Bool

    func makeUIView(context: Context) -> UIViewType {
        let pictureInPictureController = PictureInPictureController(playerLayer: playerLayer)
        context.coordinator.pictureInPictureController = pictureInPictureController

        return VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if pictureInPictureEnabled {
            context.coordinator.pictureInPictureController?.start()
        } else {
            context.coordinator.pictureInPictureController?.stop()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject {
         private let parent: VideoSurfaceView
         var pictureInPictureController: PictureInPictureController?

         init(_ parent: VideoSurfaceView) {
             self.parent = parent
             super.init()
         }
     }
}

private final class VideoSurfaceUIView: UIView {
    private let playerLayer: AVPlayerLayer

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(playerLayer: AVPlayerLayer, frame: CGRect) {
        self.playerLayer = playerLayer
        super.init(frame: frame)

        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
