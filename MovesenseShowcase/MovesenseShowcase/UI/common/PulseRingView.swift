//
// PulseRingView.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class PulseRingView: UIView {

    private let shapeLayer: CAShapeLayer = CAShapeLayer()

    private let strokeColor: CGColor
    private let fillColor: CGColor

    init(strokeColor: CGColor, fillColor: CGColor) {
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        super.init(frame: CGRect.zero)

        layer.addSublayer(shapeLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawRing()
    }

    private func drawRing() {
        let halfSize: CGFloat = min(bounds.size.width / 2, bounds.size.height / 2)
        let lineWidth: CGFloat = 1

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat(halfSize - (lineWidth / 2)),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)

        shapeLayer.fillColor = fillColor
        shapeLayer.strokeColor = strokeColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = circlePath.cgPath
    }
}
