//
//  HLSPlaylistParser.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/20.
//

import Foundation

struct ParsedPlaylist {
    var tags: [any HLSPlaylistTagProtocol]
}

// 参考資料: https://datatracker.ietf.org/doc/html/rfc8216
// 参考実装: https://github.com/videolan/vlc/blob/master/modules/demux/hls/playlist/Parser.cpp
struct HLSPlaylistParser {
    private let m3u8LineIterator: Array<String>.Iterator

    init(m3u8Content: String) {
        self.m3u8LineIterator = m3u8Content
            .split(separator: "\n")
            .map { String($0) }
            .makeIterator()
    }

    func parse() throws -> ParsedPlaylist {
        var iterator = m3u8LineIterator
        var tags: [any HLSPlaylistTagProtocol] = []

        guard let format = iterator.next(), format == "#EXTM3U" else {
             throw HLSPlaylistInvalidFormat()
         }

        while let line = iterator.next() {
            if line.first == "#" {
                let startIndex = line.index(after: line.startIndex)

                guard let separatorIndex = line.firstIndex(of: ":") else {
                    let name = String(line[startIndex...])
                    if let tag = parseTag(name: name) {
                        tags.append(tag)
                    }
                    continue
                }

                let name = String(line[startIndex..<separatorIndex])
                let value = String(line[line.index(after: separatorIndex)...])
                if let tag = parseTag(name: name, value: value) {
                    tags.append(tag)
                }
            } else {
                if var streamInfoTag = tags[tags.count - 1] as? HLSPlaylistStreamInfoTag {
                    if let url = URL(string: line) {
                        streamInfoTag.url = url
                        tags[tags.count - 1] = streamInfoTag
                    }
                }
            }
        }

        return .init(tags: tags)
    }

    private func parseTag(name: String) -> (any HLSPlaylistTagProtocol)? {
        guard let type = HLSPlaylistTagType(rawValue: name) else {
            return nil
        }
        switch type {
        case .EXT_X_DISCONTINUITY:
            return HLSPlaylistDiscontinuityTag()
        case .EXT_X_ENDLIST:
            return HLSPlaylistEndlistTag()
        case .EXT_X_I_FRAMES_ONLY:
            return HLSPlaylistIFrameOnlyTag()
        default:
            return nil
        }
    }

    private func parseTag(name: String, value: String) -> (any HLSPlaylistTagProtocol)? {
        guard let type = HLSPlaylistTagType(rawValue: name) else {
            return nil
        }

        assert(type.isSingleValue || type.isAttributesValue)

        switch type {
        case .EXT_X_VERSION:
            return HLSPlaylistVersionTag(rawValue: value)
        case .EXT_X_BYTERANGE:
            return HLSPlaylistUnknownSingleValueTag(type: type, rawValue: value)
        case .EXT_X_PROGRAM_DATE_TIME:
            return HLSPlaylistUnknownSingleValueTag(type: type, rawValue: value)
        case .EXT_X_TARGETDURATION:
            return HLSPlaylistUnknownSingleValueTag(type: type, rawValue: value)
        case .EXT_X_MEDIA_SEQUENCE:
            return HLSPlaylistUnknownSingleValueTag(type: type, rawValue: value)
        case .EXT_X_DISCONTINUITY_SEQUENCE:
            return HLSPlaylistUnknownSingleValueTag(type: type, rawValue: value)
        case .EXT_X_PLAYLIST_TYPE:
            return HLSPlaylistUnknownSingleValueTag(type: type, rawValue: value)
        case .EXT_X_KEY:
            return HLSPlaylistUnknownAttributesTag(type: type, rawValue: value)
        case .EXT_X_MAP:
            return HLSPlaylistUnknownAttributesTag(type: type, rawValue: value)
        case .EXT_X_MEDIA:
            return HLSPlaylistUnknownAttributesTag(type: type, rawValue: value)
        case .EXT_X_START:
            return HLSPlaylistUnknownAttributesTag(type: type, rawValue: value)
        case .EXT_X_STREAM_INF:
            return HLSPlaylistStreamInfoTag(rawValue: value)
        case .EXT_X_SESSION_KEY:
            return HLSPlaylistUnknownAttributesTag(type: type, rawValue: value)
        case .EXTINF:
            return HLSPlaylistUnknownAttributesTag(type: type, rawValue: value)
        default:
            return nil
        }
    }
}
