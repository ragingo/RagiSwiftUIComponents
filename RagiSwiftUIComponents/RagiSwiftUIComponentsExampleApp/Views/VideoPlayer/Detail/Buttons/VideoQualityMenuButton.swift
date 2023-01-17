//
//  VideoQualityMenuButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/17.
//

import SwiftUI

struct VideoQualityMenuButton: View {
    let items: [Int]
    let onItemSelected: (Int) -> Void
    @State private var selectedItem: Int?

    var body: some View {
        Menu {
            ForEach(items, id: \.self) { item in
                Button {
                    selectedItem = item
                    onItemSelected(item)
                } label: {
                    HStack {
                        Text("\(item)")

                        if selectedItem == item {
                            Image(systemName: "checkmark")
                                .tint(.white)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "display")
                .tint(.white)
        }
        .disabled(items.isEmpty)
    }
}

struct VideoQualityMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            VideoQualityMenuButton(items: []) { _ in }
            VideoQualityMenuButton(items: [100, 200, 300]) { _ in }
        }
        .padding()
        .background(.gray)
    }
}
