//
//  VideoSurfaceView.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/02.
//

import UIKit
import SwiftUI

struct VideoSurfaceView: UIViewRepresentable {
    typealias UIViewType = UIView

    let playerLayer: CALayer

    func makeUIView(context: Context) -> UIViewType {
        VideoSurfaceUIView(playerLayer: playerLayer, frame: .zero)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

private final class VideoSurfaceUIView: UIView {
    private let playerLayer: CALayer

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(playerLayer: CALayer, frame: CGRect) {
        self.playerLayer = playerLayer
        super.init(frame: frame)

        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
