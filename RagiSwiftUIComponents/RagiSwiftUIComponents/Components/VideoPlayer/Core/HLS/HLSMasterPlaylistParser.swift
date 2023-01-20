//
//  HLSMasterPlaylistParser.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/20.
//

import Foundation

struct ParsedMasterPlaylist {
    var tags: [any HLSPlaylistTagProtocol]
    var urls: [URL]
}

// 参考資料: https://datatracker.ietf.org/doc/html/rfc8216
// 参考実装: https://github.com/videolan/vlc/blob/master/modules/demux/hls/playlist/Parser.cpp
struct HLSMasterPlaylistParser {
    private let m3u8LineIterator: Array<String>.Iterator

    init(m3u8Content: String) {
        self.m3u8LineIterator = m3u8Content
            .split(separator: "\n")
            .map { String($0) }
            .makeIterator()
    }

    func parse() throws -> ParsedMasterPlaylist {
        var iterator = m3u8LineIterator
        var tags: [any HLSPlaylistTagProtocol] = []
        var urls: [URL] = []
        var lastTag: (any HLSPlaylistTagProtocol)?

        guard let format = iterator.next(), format == "#EXTM3U" else {
             throw HLSMasterPlaylistInvalidFormat()
         }

        while let line = iterator.next() {
            if line.first == "#" {
                let startIndex = line.index(after: line.startIndex)

                guard let separatorIndex = line.firstIndex(of: ":") else {
                    let name = String(line[startIndex...])
                    if let tag = parseTag(name: name) {
                        tags.append(tag)
                        lastTag = tag
                    }
                    continue
                }

                let name = String(line[startIndex..<separatorIndex])
                let value = String(line[line.index(after: separatorIndex)...])
                if let tag = parseTag(name: name, value: value) {
                    tags.append(tag)
                    lastTag = tag
                }
            } else {
                if case .EXT_X_STREAM_INF = lastTag?.type {
                    if let url = URL(string: line) {
                        urls.append(url)
                    }
                }
            }
        }

        return .init(tags: tags, urls: urls)
    }

    private func parseTag(name: String) -> (any HLSPlaylistTagProtocol)? {
        guard let type = HLSPlaylistTagType(rawValue: name) else {
            return nil
        }
        return HLSPlaylistTag(type: type)
    }

    private func parseTag(name: String, value: String) -> (any HLSPlaylistTagProtocol)? {
        guard let type = HLSPlaylistTagType(rawValue: name) else {
            return nil
        }

        assert(type.isSingleValue || type.isAttributesValue)

        if type.isSingleValue {
            return HLSPlaylistSingleValueTag(type: type, value: value)
        }

        return HLSPlaylistAttributesTag(type: type, rawValue: value)
    }
}
