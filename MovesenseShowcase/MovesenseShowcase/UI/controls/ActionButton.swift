//
// ActionButton.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    private enum Constants {
        static let titleShadowOffset: CGSize = CGSize(width: 1.0, height: 2.0)
        static let buttonCornerRadius: CGFloat = 5.0
    }

    private let gradientLayer: CAGradientLayer = CAGradientLayer()

    init() {
        super.init(frame: CGRect.zero)

        titleLabel?.shadowOffset = Constants.titleShadowOffset

        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.lightGray.withAlphaComponent(0.7), for: .disabled)

        setTitleShadowColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)

        gradientLayer.colors = [UIColor.gradientEnd.cgColor, UIColor.gradientStart.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = Constants.buttonCornerRadius

        // Background to the bottom of the layer stack
        layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }
}
