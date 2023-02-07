//
// CALayer+shadow.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

extension CALayer {
    // Defaults chosen to match iOS defaults
    func applySketchShadow(color: UIColor = .black, alpha: CGFloat = 0.0, x: CGFloat = 0.0, y: CGFloat = -3.0,
                           blur: CGFloat = 6.0, spread: CGFloat = 0.0) {
        shadowColor = color.cgColor
        shadowOpacity = Float(alpha)
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
