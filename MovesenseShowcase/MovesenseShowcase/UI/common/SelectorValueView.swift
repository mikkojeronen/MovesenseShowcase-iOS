//
// SelectorValueView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class SelectorValueView: UIView {

    private let nameLabel: UILabel
    private let valueLabel: UILabel
    private let valueUnit: String?

    var value: NSNumber? {
        didSet {
            guard let stringValue = value?.stringValue else { return }
            valueLabel.text = stringValue + " " + (valueUnit ?? "")
        }
    }

    init(name: String, unit: String? = nil) {
        self.nameLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: .black, lines: 1, text: name)
        self.valueLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: .black, lines: 1)
        self.valueUnit = unit
        super.init(frame: CGRect.zero)

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(nameLabel)
        addSubview(valueLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
             nameLabel.topAnchor.constraint(equalTo: topAnchor),
             nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor),
             valueLabel.topAnchor.constraint(equalTo: topAnchor),
             valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
             valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
