//
//  VideoQuolity.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/22.
//

import Foundation

public struct VideoQuolity {
    public let bandWidth: Int
    public let resolution: CGSize?

    public init(bandWidth: Int, resolution: CGSize? = nil) {
        self.bandWidth = bandWidth
        self.resolution = resolution
    }

    public init(bandWidth: Int, resolution: String) {
        let values = resolution.split(separator: "x").map { String($0) }
        if values.count != 2 {
            self.init(bandWidth: bandWidth)
            return
        }

        guard let width = Int(values[0]),
              let height = Int(values[1]) else {
            self.init(bandWidth: bandWidth)
            return
        }

        self.init(bandWidth: bandWidth, resolution: CGSize(width: width, height: height))
    }
}

extension VideoQuolity: Identifiable {
    public var id: String {
        "\(bandWidth), \(resolution ?? .zero)"
    }
}

extension VideoQuolity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bandWidth)
    }
}
