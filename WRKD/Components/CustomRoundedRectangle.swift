//
//  CustomRoundedRectangle.swift
//  WRKD
//
//  Created by Davaughn Williams on 10/20/25.
//

import SwiftUI

struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        let tr = min(min(topRight, height/2), width/2)
        let tl = min(min(topLeft, height/2), width/2)
        let bl = min(min(bottomLeft, height/2), width/2)
        let br = min(min(bottomRight, height/2), width/2)
        
        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.move(to: CGPoint(x: tl, y:0))
        path.addLine(to: CGPoint(x: width - tr, y: 0))
        path.addQuadCurve(to: CGPoint(x: width, y: tr),
                          control: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height - br))
        path.addQuadCurve(to: CGPoint(x: width - br, y: height),
                          control: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: bl, y: height))
        path.addQuadCurve(to: CGPoint(x: 0, y: height - bl),
                          control: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addQuadCurve(to: CGPoint(x: tl, y: 0),
                          control: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    CustomRoundedRectangle()
}
