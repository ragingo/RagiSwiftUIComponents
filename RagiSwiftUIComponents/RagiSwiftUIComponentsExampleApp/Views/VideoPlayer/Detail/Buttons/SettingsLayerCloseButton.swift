//
//  SettingsLayerCloseButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/15.
//

import SwiftUI

struct SettingsLayerCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle")
                .tint(.white)
        }
    }
}

struct SettingsLayerCloseButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLayerCloseButton {}
    }
}
