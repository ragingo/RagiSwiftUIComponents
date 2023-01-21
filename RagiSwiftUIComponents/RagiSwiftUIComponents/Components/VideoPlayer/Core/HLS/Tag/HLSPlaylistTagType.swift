//
//  HLSPlaylistTagType.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/20.
//

import Foundation

enum HLSPlaylistTagType: String {
    case EXT_X_DISCONTINUITY = "EXT-X-DISCONTINUITY"
    case EXT_X_ENDLIST = "EXT-X-ENDLIST"
    case EXT_X_I_FRAMES_ONLY = "EXT-X-I-FRAMES-ONLY"

    case EXT_X_VERSION = "EXT-X-VERSION"
    case EXT_X_BYTERANGE = "EXT-X-BYTERANGE"
    case EXT_X_PROGRAM_DATE_TIME = "EXT-X-PROGRAM-DATE-TIME"
    case EXT_X_TARGETDURATION = "EXT-X-TARGETDURATION"
    case EXT_X_MEDIA_SEQUENCE = "EXT-X-MEDIA-SEQUENCE"
    case EXT_X_DISCONTINUITY_SEQUENCE = "EXT-X-DISCONTINUITY-SEQUENCE"
    case EXT_X_PLAYLIST_TYPE = "EXT-X-PLAYLIST-TYPE"

    case EXT_X_KEY = "EXT-X-KEY"
    case EXT_X_MAP = "EXT-X-MAP"
    case EXT_X_MEDIA = "EXT-X-MEDIA"
    case EXT_X_START = "EXT-X-START"
    case EXT_X_STREAM_INF = "EXT-X-STREAM-INF"
    case EXT_X_SESSION_KEY = "EXT-X-SESSION-KEY"
    case EXTINF = "EXTINF"
}

extension HLSPlaylistTagType {
    var isSingleValue: Bool {
        // MEMO: Xcode のデフォルトのインデント...直したい
        switch self {
        case .EXT_X_VERSION,
                .EXT_X_BYTERANGE,
                .EXT_X_PROGRAM_DATE_TIME,
                .EXT_X_TARGETDURATION,
                .EXT_X_MEDIA_SEQUENCE,
                .EXT_X_DISCONTINUITY_SEQUENCE,
                .EXT_X_PLAYLIST_TYPE:
            return true
        default:
            return false
        }
    }

    var isAttributesValue: Bool {
        switch self {
        case .EXT_X_KEY,
                .EXT_X_MAP,
                .EXT_X_MEDIA,
                .EXT_X_START,
                .EXT_X_STREAM_INF,
                .EXT_X_SESSION_KEY,
                .EXTINF:
            return true
        default:
            return false
        }
    }
}
