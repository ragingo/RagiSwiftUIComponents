//
//  HLSPlaylistTag.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/20.
//

import Foundation

struct HLSPlaylistAttribute {
    let name: String
    let value: String
}

protocol HLSPlaylistTagProtocol {
    associatedtype Value
    var type: HLSPlaylistTagType { get set }
    var value: Value { get set }
}

struct HLSPlaylistTag: HLSPlaylistTagProtocol {
    typealias Value = Void
    var type: HLSPlaylistTagType
    var value: Value

    init(type: HLSPlaylistTagType) {
        self.type = type
        self.value = ()
    }
}

struct HLSPlaylistSingleValueTag: HLSPlaylistTagProtocol {
    typealias Value = String
    var type: HLSPlaylistTagType
    var value: Value
}

struct HLSPlaylistAttributesTag: HLSPlaylistTagProtocol {
    typealias Value = [HLSPlaylistAttribute]
    var type: HLSPlaylistTagType
    var value: Value

    init(type: HLSPlaylistTagType, rawValue: String) {
        self.type = type
        self.value = Self.parse(type: type, rawValue: rawValue)
    }

    private static func parse(type: HLSPlaylistTagType, rawValue: String) -> Value {
        var iterator = rawValue.makeIterator()
        var attributes: Value = []

        while true {
            // name
            var name = ""
            while let ch = iterator.next() {
                if ch >= "A" && ch <= "Z" || ch == "-" {
                    name += String(ch)
                } else if ch == "=" {
                    break
                } else {
                    // 想定外の文字が含まれている
                    break
                }
            }

            attributes.append(.init(name: name, value: ""))
        }

        return attributes
    }
}
