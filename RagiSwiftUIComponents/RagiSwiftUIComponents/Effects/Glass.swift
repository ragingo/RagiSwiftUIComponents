//
//  Glass.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/28.
//

import SwiftUI

/// https://developer.apple.com/documentation/swiftui/material
public struct GlassModifier: ViewModifier {
    public let material: Material?

    public init(material: Material? = nil) {
        self.material = material
    }

    public func body(content: Content) -> some View {
        ZStack {
            content

            Color.clear
                .background(material ?? .ultraThinMaterial)
        }
    }
}

extension View {
    public func glass(material: Material? = .ultraThinMaterial) -> some View {
        modifier(GlassModifier(material: material))
    }
}

struct Glass_Previews: PreviewProvider {
    struct PreviewView: View {
        let imageURL = URL(string: "https://picsum.photos/id/526/1000/1000")!
        var body: some View {
            ZStack {
                AsyncImage(url: imageURL) {
                    $0.image?.resizable().aspectRatio(contentMode: .fill)
                }
                .glass()

                AsyncImage(url: imageURL) {
                    $0.image?.resizable().aspectRatio(contentMode: .fit)
                }
                .frame(width: 300, height: 300)
            }
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
