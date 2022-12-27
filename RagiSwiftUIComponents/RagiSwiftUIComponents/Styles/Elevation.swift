//
//  Elevation.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/27.
//

import Foundation

/// https://m3.material.io/styles/elevation/tokens
public enum Elevation: Int {
    case level0 = 0
    case level1 = 1
    case level2 = 3
    case level3 = 6
    case level4 = 8
    case level5 = 12

    public var next: Elevation {
        switch self {
        case .level0:
            return .level1
        case .level1:
            return .level2
        case .level2:
            return .level3
        case .level3:
            return .level4
        case .level4:
            return .level5
        case .level5:
            return .level0
        }
    }
}
