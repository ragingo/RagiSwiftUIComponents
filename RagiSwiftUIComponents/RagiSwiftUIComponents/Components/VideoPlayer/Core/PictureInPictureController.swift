//
//  PictureInPictureController.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/05.
//

import AVFoundation
import class AVKit.AVPictureInPictureController
import protocol AVKit.AVPictureInPictureControllerDelegate
import Combine

final class PictureInPictureController: NSObject, AVPictureInPictureControllerDelegate {
    enum Properties {
        case isActive(value: Bool)
        case starting
        case started
        case stopping
        case stopped
    }

    private let playerLayer: AVPlayerLayer
    private var pictureInPictureController: AVPictureInPictureController?
    private var keyValueObservations: [NSKeyValueObservation] = []
    @MainActor private let _properties = PassthroughSubject<Properties, Never>()

    @MainActor var properties: AnyPublisher<Properties, Never> {
        _properties.eraseToAnyPublisher()
    }

    init(playerLayer: AVPlayerLayer) {
        self.playerLayer = playerLayer
        super.init()

        if !AVPictureInPictureController.isPictureInPictureSupported() {
            return
        }

        guard let controller = AVPictureInPictureController(playerLayer: playerLayer) else {
            return
        }

        self.pictureInPictureController = controller
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.delegate = self

        keyValueObservations += observeProperties()
    }

    deinit {
        keyValueObservations.forEach {
            $0.invalidate()
        }
        keyValueObservations.removeAll()
    }

    func start() {
        pictureInPictureController?.startPictureInPicture()
    }

    func stop() {
        pictureInPictureController?.stopPictureInPicture()
    }

    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        _properties.send(.starting)
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        _properties.send(.started)
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        _properties.send(.stopping)
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        _properties.send(.stopped)
    }

    @KVOBuilder
    private func observeProperties() -> [KVOBuilder.Element] {
        pictureInPictureController?.observe(\.isPictureInPictureActive) { [weak self] controller, _ in
            self?._properties.send(.isActive(value: controller.isPictureInPictureActive))
        }
    }
}
