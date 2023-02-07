//
// DashboardPlotterScaleView.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class DashboardPlotterScaleView: UIView {

    private enum Constants {
        static let scaleLabelWidth: CGFloat = 25.0
    }

    private let scaleView: UIView = UIView(frame: CGRect.zero)
    private let scaleStep: Int
    private let scaleRange: ClosedRange<Int>

    private(set) var isDirty: Bool = false

    var pointsPerUnit: CGFloat = 0.0

    var yTransform: CGFloat = 1.0 {
        didSet(oldValue) {
            guard yTransform > 0.0,
                  yTransform != oldValue else {
                return
            }

            isDirty = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(scaleStep: Int, scaleRange: ClosedRange<Int>) {
        self.scaleStep = scaleStep
        self.scaleRange = scaleRange
        super.init(frame: CGRect.zero)

        layoutView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        createMask()

        guard (scaleRange.upperBound - scaleRange.lowerBound) != 0 else { return }

        scaleView.subviews.forEach { $0.removeFromSuperview() }

        pointsPerUnit = frame.height / CGFloat(scaleRange.upperBound - scaleRange.lowerBound)

        stride(from: scaleRange.lowerBound, through: scaleRange.upperBound, by: scaleStep).forEach { step in
            let scaleLabel = UILabel(with: UIFont.systemFont(ofSize: 8), inColor: UIColor.titleTextBlack, lines: 1,
                                     text: "\(-step)")
            let scaleLineView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 1.0))

            scaleLabel.textAlignment = .right
            scaleLineView.layer.borderColor = UIColor.lightGray.cgColor
            scaleLineView.layer.borderWidth = 1.0

            let yPosition = CGFloat(step) * pointsPerUnit

            scaleView.addSubview(scaleLabel)
            scaleLabel.addSubview(scaleLineView)

            scaleLabel.translatesAutoresizingMaskIntoConstraints = false
            scaleLineView.translatesAutoresizingMaskIntoConstraints = false

            scaleLabel.centerYAnchor.constraint(equalTo: scaleView.centerYAnchor, constant: yPosition).isActive = true
            scaleLabel.widthAnchor.constraint(equalToConstant: Constants.scaleLabelWidth).isActive = true
            scaleLabel.leadingAnchor.constraint(equalTo: scaleView.leadingAnchor).isActive = true

            scaleLineView.centerYAnchor.constraint(equalTo: scaleLabel.centerYAnchor).isActive = true
            scaleLineView.leadingAnchor.constraint(equalTo: scaleLabel.trailingAnchor, constant: 6.0).isActive = true
            scaleLineView.trailingAnchor.constraint(equalTo: scaleView.trailingAnchor).isActive = true
            scaleLineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        }
    }

    // Only call from the main thread
    func refreshScale() {
        isDirty = false

        UIView.animate(withDuration: 0.35) {
            self.scaleView.subviews.forEach { subview in
                subview.transform = CGAffineTransform.identity
                let centeredY = subview.frame.origin.y + ceil(subview.frame.height / 2)
                let yTranslation = self.yTransform * centeredY - centeredY
                subview.transform = CGAffineTransform(translationX: 1.0, y: yTranslation)
            }
        }
    }

    // Create a custom visibility mask for letting the labels to be fully visible when
    // the grid lines are at the borders
    private func createMask() {
        layer.sublayers?.forEach { ($0 as? CAShapeLayer)?.removeFromSuperlayer() }

        let maskPath = CGMutablePath()
        maskPath.move(to: CGPoint(x: 0.0, y: -5.0))
        maskPath.addLine(to: CGPoint(x: Constants.scaleLabelWidth, y: -5.0))
        maskPath.addLine(to: CGPoint(x: Constants.scaleLabelWidth, y: 0.0))
        maskPath.addLine(to: CGPoint(x: bounds.width, y: 0.0))
        maskPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        maskPath.addLine(to: CGPoint(x: Constants.scaleLabelWidth, y: bounds.height))
        maskPath.addLine(to: CGPoint(x: Constants.scaleLabelWidth, y: bounds.height + 5.0))
        maskPath.addLine(to: CGPoint(x: 0.0, y: bounds.height + 5.0))
        maskPath.addLine(to: CGPoint(x: 0.0, y: -5.0))
        maskPath.closeSubpath()

        let mask = CAShapeLayer()
        mask.path = maskPath
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        mask.backgroundColor = UIColor.clear.cgColor

        layer.mask = mask
    }

    private func layoutView() {
        addSubview(scaleView)

        scaleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [scaleView.leadingAnchor.constraint(equalTo: leadingAnchor),
             scaleView.trailingAnchor.constraint(equalTo: trailingAnchor),
             scaleView.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }
}
