//
//  VideoQualityMenuButton.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/17.
//

import SwiftUI
import RagiSwiftUIComponents

struct VideoQualityMenuButton: View {
    let items: [VideoQuolity]
    let onItemSelected: (Int) -> Void
    @State private var selectedItem: Int?

    var body: some View {
        Menu {
            ForEach(items, id: \.self) { item in
                Button {
                    selectedItem = item.bandWidth
                    onItemSelected(item.bandWidth)
                } label: {
                    HStack {
                        let bandWidth = Double(item.bandWidth) / 1_000_000
                        if let resolution = item.resolution {
                            let size = "\(Int(resolution.width))x\(Int(resolution.height))"
                            Text("\(size) (\(bandWidth, specifier: "%.1f") Mbps)")
                        } else {
                            Text("\(bandWidth, specifier: "%.1f") Mbps")
                        }

                        if selectedItem == item.bandWidth {
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
            VideoQualityMenuButton(items: [.init(bandWidth: 10000, resolution: "1x1")]) { _ in }
        }
        .padding()
        .background(.gray)
    }
}
