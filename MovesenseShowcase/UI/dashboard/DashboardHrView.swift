//
// DashboardHrView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DashboardHrView: UIView {

    private let hrLabel: UILabel
    private let bpmLabel: UILabel

    var hrValue: Int? = nil {
        didSet {
            guard let hrValue = hrValue else {
                hrLabel.text = "000"
                return
            }

            hrLabel.text = String(format: "%3d", arguments: [hrValue])
        }
    }

    init(labelSize: CGFloat) {
        self.hrLabel = UILabel(with: UIFont.monospacedDigitSystemFont(ofSize: labelSize, weight: .regular),
                               inColor: UIColor.titleTextBlack, lines: 1, text: "000")
        self.bpmLabel = UILabel(with: UIFont.systemFont(ofSize: 12.0, weight: .medium),
                                inColor: UIColor.titleTextBlack, lines: 1, text: "bpm")
        super.init(frame: CGRect.zero)

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func layoutView() {
        addSubview(hrLabel)
        addSubview(bpmLabel)

        hrLabel.translatesAutoresizingMaskIntoConstraints = false
        bpmLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [hrLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
             hrLabel.topAnchor.constraint(equalTo: topAnchor),
             hrLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [bpmLabel.leadingAnchor.constraint(equalTo: hrLabel.trailingAnchor, constant: 6.0),
             bpmLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
             bpmLabel.firstBaselineAnchor.constraint(equalTo: hrLabel.firstBaselineAnchor)])
    }
}
