//
//  HLSPlaylistAttribute.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/22.
//

import Foundation

struct HLSPlaylistAttribute {
    let name: String
    let value: String

    var intValue: Int? {
        if value.starts(with: "0x") || value.starts(with: "0X") {
            return Int(value.dropFirst(2), radix: 16)
        }
        return Int(value)
    }

    var int64Value: Int64? {
        if value.starts(with: "0x") || value.starts(with: "0X") {
            return Int64(value.dropFirst(2), radix: 16)
        }
        return Int64(value)
    }
}
