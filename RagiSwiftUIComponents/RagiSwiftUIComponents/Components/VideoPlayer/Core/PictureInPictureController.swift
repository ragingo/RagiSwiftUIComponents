//
//  PictureInPictureController.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/05.
//

import AVFoundation
import class AVKit.AVPictureInPictureController
import protocol AVKit.AVPictureInPictureControllerDelegate

final class PictureInPictureController: NSObject, AVPictureInPictureControllerDelegate {
    private let playerLayer: AVPlayerLayer
    private var pictureInPictureController: AVPictureInPictureController?

    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
        super.init()

        if AVPictureInPictureController.isPictureInPictureSupported() {
            if let controller = AVPictureInPictureController(playerLayer: playerLayer) {
                self.pictureInPictureController = controller
                controller.canStartPictureInPictureAutomaticallyFromInline = true
                controller.delegate = self
            }
        }
    }

    func start() {
        pictureInPictureController?.startPictureInPicture()
    }

    func stop() {
        pictureInPictureController?.stopPictureInPicture()
    }
}
