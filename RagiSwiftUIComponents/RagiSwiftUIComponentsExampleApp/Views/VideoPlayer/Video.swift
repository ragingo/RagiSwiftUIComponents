//
//  Video.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/05.
//

import Foundation

struct Video: Decodable {
    let title: String
    let url: URL
}

extension Video: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(url)
    }
}
