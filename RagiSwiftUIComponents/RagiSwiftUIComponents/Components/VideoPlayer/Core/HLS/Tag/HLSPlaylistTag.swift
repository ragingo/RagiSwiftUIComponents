//
//  HLSPlaylistTag.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/20.
//

import Foundation

protocol HLSPlaylistTagProtocol {
    associatedtype Value
    var type: HLSPlaylistTagType { get set }
    var value: Value { get set }
}

struct HLSPlaylistTag: HLSPlaylistTagProtocol, CustomStringConvertible {
    typealias Value = Void
    var type: HLSPlaylistTagType
    var value: Value

    init(type: HLSPlaylistTagType) {
        self.type = type
        self.value = ()
    }

    var description: String {
        "#\(type.rawValue)"
    }
}

struct HLSPlaylistSingleValueTag: HLSPlaylistTagProtocol, CustomStringConvertible {
    typealias Value = String
    var type: HLSPlaylistTagType
    var value: Value

    var description: String {
        "#\(type.rawValue): \(value)"
    }
}

struct HLSPlaylistAttributesTag: HLSPlaylistTagProtocol, CustomStringConvertible {
    typealias Value = [HLSPlaylistAttribute]
    var type: HLSPlaylistTagType
    var value: Value

    init(type: HLSPlaylistTagType, rawValue: String) {
        self.type = type
        self.value = Self.parse(type: type, rawValue: rawValue)
    }

    subscript(_ name: String) -> HLSPlaylistAttribute? {
        value.first(where: { $0.name == name })
    }

    var description: String {
        let attributes = value.map { "\($0.name)=\($0.value)" }.joined(separator: ", ")
        return "#\(type.rawValue): [\(attributes)]"
    }

    private static func parse(type: HLSPlaylistTagType, rawValue: String) -> Value {
        var attributes: Value = []
        let lastIndex = rawValue.count - 1
        var i = 0
        let characters = rawValue.map { $0 }

        while i <= lastIndex {
            var name = ""
            while i <= lastIndex {
                let ch = characters[i]
                if Attribute.Name.isValidCharacter(character: ch) {
                    name += String(ch)
                    i += 1
                } else if ch == Attribute.NameValueSeparator {
                    break
                } else {
                    // 想定外の文字
                    i += 1
                }
            }

            var value = ""
            var quoted = false
            while i <= lastIndex {
                let ch = characters[i]
                quoted = ch == "\"" && !quoted

                if ch == Attribute.AttributeSeparator && !quoted {
                    break
                } else if Attribute.Value.isValidCharacter(character: ch, quoted: quoted) {
                    value += String(ch)
                    i += 1
                } else {
                    // 想定外の文字
                    i += 1
                }
            }

            attributes.append(.init(name: name, value: value))
            i += 1
        }

        return attributes
    }
}

private enum Attribute {
    static let NameValueSeparator: Character = "="
    static let AttributeSeparator: Character = ","

    enum Name {
        static func isValidCharacter(character: Character) -> Bool {
            character.isASCIILetterUpper || character == "-"
        }
    }

    enum Value {
        static func isValidCharacter(character: Character, quoted: Bool) -> Bool {
            if quoted {
                return character != "\"" && !character.isNewline
            }
            return character.isASCIIDigit || character.isASCIILetter || character == "-" || character == "."
        }
    }
}
