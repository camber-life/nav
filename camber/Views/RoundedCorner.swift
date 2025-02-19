//
//  RoundedCorner.swift
//  camber
//
//  Created by Roddy Gonzalez on 2/11/25.
//


//
//  RoundedCorner.swift
//  YourApp
//
//  Created by You on 2023-XX-XX.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}