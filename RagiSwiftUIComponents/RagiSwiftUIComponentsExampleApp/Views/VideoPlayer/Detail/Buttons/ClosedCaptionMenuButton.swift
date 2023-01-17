//
//  ClosedCaptionMenuButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/15.
//

import SwiftUI

struct ClosedCaptionMenuButton: View {
    let languages: [(id: String, displayName: String)]
    let onLanguageSelected: (_ id: String?) -> Void

    @State private var selectedID: String?

    var body: some View {
        Menu {
            Button {
                selectedID = nil
                onLanguageSelected(nil)
            } label: {
                HStack {
                    Text("非表示")

                    if selectedID == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                }
            }
            ForEach(languages, id: \.id) { language in
                Button {
                    selectedID = language.id
                    onLanguageSelected(language.id)
                } label: {
                    HStack {
                        Text("\(language.displayName) (\(language.id))")

                        if selectedID == language.id {
                            Image(systemName: "checkmark")
                                .tint(.white)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: selectedID != nil ? "captions.bubble.fill" : "captions.bubble")
                .tint(.white)
        }
    }
}

struct ClosedCaptionMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        let languages = [
            (id: "en", displayName: "英語"),
            (id: "ja", displayName: "日本語"),
        ]
        VStack(spacing: 16) {
            ClosedCaptionMenuButton(languages: []) { _ in }
            ClosedCaptionMenuButton(languages: languages.filter { $0.id == "en" }) { _ in }
            ClosedCaptionMenuButton(languages: languages) { _ in }
        }
        .padding()
        .background(.gray)
    }
}
