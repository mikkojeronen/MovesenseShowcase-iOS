//
// DashboardValuesView.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class DashboardValuesView: UIView {

    private enum Constants {
        static let labelHeight: CGFloat = 32.5
        static let labelWidth: CGFloat = 103.0
        static let posValueFormat: String = "  %06.2f"
        static let negValueFormat: String = "%07.2f"
    }

    private let xLabel: UILabel
    private let yLabel: UILabel
    private let zLabel: UILabel

    private let xValueContainer: UIView = UIView(frame: CGRect.zero)
    private let yValueContainer: UIView = UIView(frame: CGRect.zero)
    private let zValueContainer: UIView = UIView(frame: CGRect.zero)

    private let xValueLabel: UILabel
    private let yValueLabel: UILabel
    private let zValueLabel: UILabel

    var xValue: CGFloat = 0.0 {
        didSet {
            if xValue != oldValue {
                xValueLabel.text = String(format: xValue < 0.0 ? Constants.negValueFormat : Constants.posValueFormat, xValue)
            }
        }
    }

    var yValue: CGFloat = 0.0 {
        didSet {
            if yValue != oldValue {
                yValueLabel.text = String(format: yValue < 0.0 ? Constants.negValueFormat : Constants.posValueFormat, yValue)
            }
        }
    }

    var zValue: CGFloat = 0.0 {
        didSet {
            if zValue != oldValue {
                zValueLabel.text = String(format: zValue < 0.0 ? Constants.negValueFormat : Constants.posValueFormat, zValue)
            }
        }
    }

    init(xColor: UIColor, yColor: UIColor, zColor: UIColor) {
        self.xLabel = UILabel.init(with: UIFont.systemFont(ofSize: 12), inColor: xColor, lines: 1, text: "x:")
        self.yLabel = UILabel.init(with: UIFont.systemFont(ofSize: 12), inColor: yColor, lines: 1, text: "y:")
        self.zLabel = UILabel.init(with: UIFont.systemFont(ofSize: 12), inColor: zColor, lines: 1, text: "z:")

        self.xValueLabel = UILabel.init(with: UIFont.monospacedDigitSystemFont(ofSize: 27, weight: .regular),
                                        inColor: .black, lines: 1, text: "  000.00")
        self.yValueLabel = UILabel.init(with: UIFont.monospacedDigitSystemFont(ofSize: 27, weight: .regular),
                                        inColor: .black, lines: 1, text: "  000.00")
        self.zValueLabel = UILabel.init(with: UIFont.monospacedDigitSystemFont(ofSize: 27, weight: .regular),
                                        inColor: .black, lines: 1, text: "  000.00")

        super.init(frame: CGRect.zero)

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        xValueLabel.frame = xValueContainer.bounds
        xValueLabel.bounds = xValueContainer.bounds

        yValueLabel.frame = yValueContainer.bounds
        yValueLabel.bounds = yValueContainer.bounds

        zValueLabel.frame = zValueContainer.bounds
        zValueLabel.bounds = zValueContainer.bounds
    }

    private func layoutView() {
        addSubview(xLabel)
        addSubview(yLabel)
        addSubview(zLabel)
        addSubview(xValueContainer)
        addSubview(yValueContainer)
        addSubview(zValueContainer)

        xValueContainer.addSubview(xValueLabel)
        yValueContainer.addSubview(yValueLabel)
        zValueContainer.addSubview(zValueLabel)

        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate(
            [xLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
             xLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [xValueContainer.leadingAnchor.constraint(equalTo: xLabel.trailingAnchor),
             xValueContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
             xValueContainer.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
             xValueContainer.widthAnchor.constraint(equalToConstant: Constants.labelWidth),
             xValueContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5.0)])

        NSLayoutConstraint.activate(
            [yLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -50.0),
             yLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [yValueContainer.leadingAnchor.constraint(equalTo: yLabel.trailingAnchor),
             yValueContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
             yValueContainer.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
             yValueContainer.widthAnchor.constraint(equalToConstant: Constants.labelWidth),
             yValueContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5.0)])

        NSLayoutConstraint.activate(
            [zLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100.0),
             zLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [zValueContainer.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
             zValueContainer.leadingAnchor.constraint(equalTo: zLabel.trailingAnchor),
             zValueContainer.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
             zValueContainer.widthAnchor.constraint(equalToConstant: Constants.labelWidth),
             zValueContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5.0)])
    }
}
