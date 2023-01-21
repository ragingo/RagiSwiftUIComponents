//
//  Character+Extensions.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2023/01/22.
//

import Foundation

extension Character {
    var isASCIIDigit: Bool {
        self >= "0" && self <= "9"
    }

    var isASCIILetter: Bool {
        isASCIILetterUpper || isASCIILetterLower
    }

    var isASCIILetterUpper: Bool {
        self >= "A" && self <= "Z"
    }

    var isASCIILetterLower: Bool {
        self >= "a" && self <= "z"
    }
}
