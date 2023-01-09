//
//  VideoPlayerErrorLayer.swift
//  RagiSwiftUIComponentsExampleApp
//
//  Created by ragingo on 2023/01/09.
//

import SwiftUI
import RagiSwiftUIComponents

struct VideoPlayerErrorLayer: View {
    let error: Error

    var body: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                ScrollView {
                    Expander(
                        header: { _ in
                            Text("エラー発生！")
                        },
                        content: { _ in
                            Text(error.localizedDescription)
                        }
                    )
                }
            }
    }
}

struct VideoPlayerErrorLayer_Previews: PreviewProvider {
    struct DummyError: Error {}

    static var previews: some View {
        VideoPlayerErrorLayer(error: DummyError())
    }
}
