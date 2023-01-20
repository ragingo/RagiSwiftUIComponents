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
}
