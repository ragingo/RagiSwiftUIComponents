//
//  PictureInPictureButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/15.
//

import SwiftUI

struct PictureInPictureButton: View {
    let isPossible: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: isPossible ? "pip.enter" : "rectangle.on.rectangle.slash.fill")
                .tint(.white)
        }
        .disabled(!isPossible)
    }
}

struct PictureInPictureButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PictureInPictureButton(isPossible: true) {}
            PictureInPictureButton(isPossible: false) {}
        }
        .padding()
        .background(.gray)
    }
}
