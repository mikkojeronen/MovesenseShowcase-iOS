//
// DfuHowToFooterView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DfuHowToFooterView: UIView {

    private let faqLabel: UILabel
    private let topSeparator: UIView
    private let bottomSeparator: UIView

    init() {
        self.faqLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: UIColor.titleTextBlack, lines: 0)
        self.topSeparator = UIView.separator()
        self.bottomSeparator = UIView.separator()
        super.init(frame: CGRect.zero)

        faqLabel.attributedText = NSAttributedString(withLocalizedHTMLString: NSLocalizedString("DFU_HOWTO_FAQ_LABEL",
                                                                                                comment: ""))
        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(faqLabel)
        addSubview(topSeparator)
        addSubview(bottomSeparator)

        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate(
            [topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
             topSeparator.topAnchor.constraint(equalTo: topAnchor),
             topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor)])

        NSLayoutConstraint.activate(
            [faqLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             faqLabel.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 16.0).with(.fittingSizeLevel),
             faqLabel.bottomAnchor.constraint(equalTo: bottomSeparator.topAnchor, constant: -16.0).with(.fittingSizeLevel)])

        NSLayoutConstraint.activate(
            [bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
             bottomSeparator.topAnchor.constraint(equalTo: bottomAnchor),
             bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor)])
    }
}
