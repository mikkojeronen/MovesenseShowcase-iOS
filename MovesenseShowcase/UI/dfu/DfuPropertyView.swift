//
// DfuPropertyView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DfuPropertyView: UIView {

    private enum Constants {
        static let keyWidth: CGFloat = 120.0
    }

    private let keyLabel: UILabel
    private let valueLabel: UILabel

    var isEnabled: Bool = true {
        didSet {
            valueLabel.isEnabled = isEnabled
        }
    }

    var value: String = "" {
        didSet {
            valueLabel.text = value
        }
    }

    init(key: String, value: String) {

        self.keyLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                                inColor: UIColor.titleTextBlack, lines: 1,
                                text: key)

        self.valueLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                                  inColor: UIColor.titleTextBlack, lines: 1,
                                  text: value)

        super.init(frame: CGRect.zero)

        keyLabel.textAlignment = .left

        valueLabel.textAlignment = .left

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(keyLabel)
        addSubview(valueLabel)

        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [keyLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
             keyLabel.topAnchor.constraint(equalTo: topAnchor),
             keyLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
             keyLabel.widthAnchor.constraint(equalToConstant: Constants.keyWidth)])

        NSLayoutConstraint.activate(
            [valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
             valueLabel.topAnchor.constraint(equalTo: topAnchor),
             valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
             valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
