//
// RecordingsSectionHeader.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import UIKit

class RecordingsSectionHeader: UIView {

    private let sectionTitleLabel: UILabel
    private let topSeparator: UIView
    private let bottomSeparator: UIView

    init(title: String) {
        self.sectionTitleLabel = UILabel(with: UIFont.systemFont(ofSize: 13),
                                         inColor: UIColor.titleTextBlack.withAlphaComponent(0.6),
                                         lines: 1, text: title)
        self.topSeparator = UIView.separator(color: UIColor.separatorGray)
        self.bottomSeparator = UIView.separator(color: UIColor.separatorGray)
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.white

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(topSeparator)
        addSubview(sectionTitleLabel)
        addSubview(bottomSeparator)

        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [topSeparator.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
             topSeparator.topAnchor.constraint(equalTo: topAnchor),
             topSeparator.trailingAnchor.constraint(greaterThanOrEqualTo: sectionTitleLabel.trailingAnchor)])

        NSLayoutConstraint.activate(
            [sectionTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
             sectionTitleLabel.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 32.0),
             sectionTitleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -8.0)])

        NSLayoutConstraint.activate(
            [bottomSeparator.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
             bottomSeparator.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 8.0),
             bottomSeparator.trailingAnchor.constraint(greaterThanOrEqualTo: sectionTitleLabel.trailingAnchor),
             bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
