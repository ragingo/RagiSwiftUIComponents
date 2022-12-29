//
//  Shadow.swift
//  RagiSwiftUIComponents
//
//  Created by ragingo on 2022/12/27.
//

import SwiftUI

/// 標準の shadow モディファイアの代替品
/// - 標準の shadow モディファイアは CPU 負荷が高く動作がとても重たかったので、それっぽいものを用意
/// - Elevation に対応
public struct ShadowModifier: ViewModifier {
    private let elevation: Elevation
    private let cornerRadius: CGFloat
    private let shadowMetrics: ShadowMetrics

    public init(
        elevation: Elevation,
        cornerRadius: CGFloat
    ) {
        self.elevation = elevation
        self.cornerRadius = cornerRadius
        self.shadowMetrics = ShadowMetrics(elevation: elevation)
    }

    public func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.black.opacity(shadowMetrics.bottomShadowOpacity))
                        .blur(radius: shadowMetrics.bottomShadowRadius)
                        .padding(.init(
                            top: 0,
                            leading: 0,
                            bottom: -shadowMetrics.bottomShadowOffset.y,
                            trailing: -shadowMetrics.bottomShadowOffset.x
                        ))
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.black.opacity(shadowMetrics.topShadowOpacity))
                        .blur(radius: shadowMetrics.topShadowRadius)
                        .padding(.init(
                            top: 0,
                            leading: 0,
                            bottom: -shadowMetrics.topShadowOffset.y,
                            trailing: -shadowMetrics.topShadowOffset.x
                        ))
                }
            }
    }
}

/// 参考実装: https://github.com/material-components/material-components-ios/blob/develop/components/ShadowLayer/src/MDCShadowLayer.m
/// MEMO: android 版は実現方法が全然違うっぽい。
/// https://github.com/material-components/material-components-android/blob/1.7.0/lib/java/com/google/android/material/shape/MaterialShapeDrawable.java
private struct ShadowMetrics {
    let elevation: Elevation

    var topShadowRadius: CGFloat {
        0.889544 * CGFloat(elevation.rawValue) - 0.003791
    }

    var topShadowOffset: CGPoint {
        .zero
    }

    var topShadowOpacity: CGFloat {
        0.08
    }

    var bottomShadowRadius: CGFloat {
        0.666920 * CGFloat(elevation.rawValue) - 0.001648
    }

    var bottomShadowOffset: CGPoint {
        let y = 1.23118 * CGFloat(elevation.rawValue) - 0.03933
        return CGPoint(x: 0, y: y)
    }

    var bottomShadowOpacity: CGFloat {
        0.26
    }
}

extension View {
    public func shadow(elevation: Elevation, cornerRadius: CGFloat) -> some View {
        self.modifier(ShadowModifier(
            elevation: elevation,
            cornerRadius: cornerRadius
        ))
    }
}

struct Shadow_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var elevation: Elevation = .level1

        var body: some View {
            RoundedRectangle(cornerRadius: CardConstants.borderRadius)
                .fill(Color(red: 240/255, green: 240/255, blue: 240/255))
                .shadow(elevation: elevation, cornerRadius: 12)
                .frame(width: 300, height: 300)
        }
    }

    static var previews: some View {
        PreviewView()
    }
}
