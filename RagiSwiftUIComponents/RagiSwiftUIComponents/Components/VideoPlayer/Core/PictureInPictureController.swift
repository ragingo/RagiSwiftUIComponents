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

final class PictureInPictureController: NSObject {
    enum Properties {
        case isActive(value: Bool)
        case isPossible(value: Bool)
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
        // 前後スキップボタンを隠すなら true にする
        controller.requiresLinearPlayback = true
        // 再生/一時停止ボタンを隠すなら controlsStyle を inline にする
        controller.setValue(AVPlayerViewControlsStyle.inline.rawValue, forKey: "controlsStyle")

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

    @KVOBuilder
    private func observeProperties() -> [KVOBuilder.Element] {
        pictureInPictureController?.observe(\.isPictureInPictureActive, options: [.initial, .new]) { [weak self] controller, change in
            self?._properties.send(.isActive(value: change.newValue ?? false))
        }
        pictureInPictureController?.observe(\.isPictureInPicturePossible, options: [.initial, .new]) { [weak self] controller, change in
            self?._properties.send(.isPossible(value: change.newValue ?? false))
        }
    }
}

extension PictureInPictureController: AVPictureInPictureControllerDelegate {
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
}

// macOS 向けの AVPlayerViewControlsStyle を iOS で使いたいから自分で定義
// https://learn.microsoft.com/ja-jp/dotnet/api/avkit.avplayerviewcontrolsstyle?view=xamarin-ios-sdk-12
private enum AVPlayerViewControlsStyle: RawRepresentable {
    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .none
        case 1:
            self = .inline
        case 2:
            self = .floating
        case 3:
            self = .minimal
        default:
            return nil
        }
    }

    case none
    case inline
    case floating
    case minimal
    case `default`

    var rawValue: Int {
        switch self {
        case .none:
            return 0
        case .inline:
            return 1
        case .floating:
            return 2
        case .minimal:
            return 3
        case .default:
            return 1
        }
    }
}
