//
//  HLSPlaylistTag.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/20.
//

import Foundation

protocol HLSPlaylistTagProtocol {
    var type: HLSPlaylistTagType { get }
}

// MARK: - HLSPlaylistTag
protocol HLSPlaylistTag: HLSPlaylistTagProtocol, CustomStringConvertible {
    var type: HLSPlaylistTagType { get }
}

// CustomStringConvertible
extension HLSPlaylistTag {
    var description: String {
        "#\(type.rawValue)"
    }
}

// MARK: - HLSPlaylistSingleValueTag
protocol HLSPlaylistSingleValueTag: HLSPlaylistTagProtocol, CustomStringConvertible {
    associatedtype Value
    var type: HLSPlaylistTagType { get }
    var value: Value { get }

    init(rawValue: String)
}

// CustomStringConvertible
extension HLSPlaylistSingleValueTag {
    var description: String {
        "#\(type.rawValue): \(value)"
    }
}

// MARK: - HLSPlaylistAttributesTag
protocol HLSPlaylistAttributesTag: HLSPlaylistTagProtocol, CustomStringConvertible {
    var type: HLSPlaylistTagType { get }
    var value: [HLSPlaylistAttribute] { get }

    init(rawValue: String)
}

extension HLSPlaylistAttributesTag {
    subscript(_ name: String) -> HLSPlaylistAttribute? {
        value.first(where: { $0.name == name })
    }
}

extension HLSPlaylistAttributesTag {
    var description: String {
        let attributes = value.map { "\($0.name)=\($0.value)" }.joined(separator: ", ")
        return "#\(type.rawValue): [\(attributes)]"
    }
}

extension HLSPlaylistAttributesTag {
    static func parse(type: HLSPlaylistTagType, rawValue: String) -> [HLSPlaylistAttribute] {
        var attributes: [HLSPlaylistAttribute] = []
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

// MARK: - Attribute
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

// MARK: - Tag Structs

struct HLSPlaylistDiscontinuityTag: HLSPlaylistTag {
    let type: HLSPlaylistTagType = .EXT_X_DISCONTINUITY
}

struct HLSPlaylistEndlistTag: HLSPlaylistTag {
    let type: HLSPlaylistTagType = .EXT_X_ENDLIST
}

struct HLSPlaylistIFrameOnlyTag: HLSPlaylistTag {
    let type: HLSPlaylistTagType = .EXT_X_I_FRAMES_ONLY
}

struct HLSPlaylistUnknownSingleValueTag: HLSPlaylistSingleValueTag {
    typealias Value = String

    let type: HLSPlaylistTagType
    let value: Value

    init(rawValue: String) {
        self.type = .unknown
        self.value = rawValue
    }

    init(type: HLSPlaylistTagType, rawValue: String) {
        self.type = type
        self.value = rawValue
    }
}

struct HLSPlaylistUnknownAttributesTag: HLSPlaylistAttributesTag {
    let type: HLSPlaylistTagType
    let value: [HLSPlaylistAttribute]

    init(rawValue: String) {
        self.type = .unknown
        self.value = []
    }

    init(type: HLSPlaylistTagType, rawValue: String) {
        self.type = type
        self.value = Self.parse(type: type, rawValue: rawValue)
    }
}

struct HLSPlaylistVersionTag: HLSPlaylistSingleValueTag {
    typealias Value = Int

    let type: HLSPlaylistTagType = .EXT_X_VERSION
    let value: Value

    init(rawValue: String) {
        self.value = Int(rawValue) ?? 0
    }
}

struct HLSPlaylistStreamInfoTag: HLSPlaylistAttributesTag {
    let type: HLSPlaylistTagType = .EXT_X_STREAM_INF
    let value: [HLSPlaylistAttribute]
    var url: URL?

    var bandWidth: Int? {
        self["BANDWIDTH"]?.intValue
    }

    var resolution: CGSize? {
        guard let rawValue = self["RESOLUTION"]?.value else {
            return nil
        }
        let items = rawValue.split(separator: "x")
        if items.count != 2 {
            return nil
        }
        guard let width = Int(items[0]),
              let height = Int(items[1]) else {
            return nil
        }
        return .init(width: width, height: height)
    }

    init(rawValue: String) {
        self.value = Self.parse(type: type, rawValue: rawValue)
    }
}
