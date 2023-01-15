//
//  SettingsButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/15.
//

import SwiftUI

struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "gearshape.fill")
                .tint(.white)
        }
    }
}

struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsButton {}
                .tint(.white)
        }
        .padding()
        .background(.gray)
    }
}
