//
//  VideoQuality.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/22.
//

import Foundation

public struct VideoQuality {
    public let bandWidth: Int
    public let resolution: CGSize?

    public init(bandWidth: Int, resolution: CGSize? = nil) {
        self.bandWidth = bandWidth
        self.resolution = resolution
    }
}

extension VideoQuality: Identifiable {
    public var id: String {
        "\(bandWidth), \(resolution ?? .zero)"
    }
}

extension VideoQuality: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bandWidth)
    }
}
