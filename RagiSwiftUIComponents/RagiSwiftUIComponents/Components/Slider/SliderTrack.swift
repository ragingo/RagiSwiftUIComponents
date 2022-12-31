//
//  SliderTrack.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/29.
//

import SwiftUI

public struct SliderTrack: View {
    private var offset: Binding<CGFloat>
    private var width: Binding<CGFloat>

    public init(offset: Binding<CGFloat> = .constant(0), width: Binding<CGFloat>) {
        self.offset = offset
        self.width = width
    }

    public var body: some View {
        Rectangle()
            .offset(x: offset.wrappedValue)
            .frame(width: width.wrappedValue)
    }
}

struct SliderTrack_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            SliderTrack(width: .constant(100))
                .frame(width: 100, height: 8)
                .foregroundColor(.red)
            SliderTrack(width: .constant(200))
                .frame(width: 200, height: 4)
                .foregroundColor(.blue)
            SliderTrack(offset: .constant(100), width: .constant(200))
                .frame(width: 200, height: 4)
                .foregroundColor(.blue)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .border(.black)
        .padding()
    }
}
