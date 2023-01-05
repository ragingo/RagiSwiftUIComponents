//
//  KVOBuilder.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/04.
//

import Foundation

@resultBuilder
struct KVOBuilder {
    typealias Element = NSKeyValueObservation

    public static func buildBlock(_ components: Element?...) -> [Element?] {
        components
    }

    static func buildFinalResult(_ components: [Element?]) -> [Element] {
        components.compactMap { $0 }
    }
}
