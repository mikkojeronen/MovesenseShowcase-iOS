//
// UIView+shadows.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

extension UIView {

    func dropShadow(color: UIColor, opacity: Float, radius: Float, offset: CGSize = .zero) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = CGFloat(radius)

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func topShadow(color: UIColor, opacity: Float, radius: Float) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = CGFloat(radius)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: bounds.origin.x, y: -CGFloat(radius / 2.0),
                                                     width: bounds.width,
                                                     height: CGFloat(radius))).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
