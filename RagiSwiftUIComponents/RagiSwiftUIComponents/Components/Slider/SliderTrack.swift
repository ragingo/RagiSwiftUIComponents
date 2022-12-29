//
//  SliderTrack.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/29.
//

import SwiftUI

public struct SliderTrack: View {
    @Binding var width: CGFloat

    public var body: some View {
        Rectangle()
            .frame(width: width)
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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .border(.black)
        .padding()
    }
}
