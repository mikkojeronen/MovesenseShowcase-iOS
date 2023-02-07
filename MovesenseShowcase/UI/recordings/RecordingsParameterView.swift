//
// RecordingsParameterView.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class RecordingsParameterView: UIView {

    private let parameterLabel: UILabel
    private let parameterTextLabel: UILabel

    init(_ parameter: (String, String)) {
        self.parameterLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 16.0), inColor: .black, lines: 1, text: parameter.0)
        self.parameterTextLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .black, lines: 1, text: parameter.1)
        super.init(frame: CGRect.zero)

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(parameterLabel)
        addSubview(parameterTextLabel)

        parameterLabel.translatesAutoresizingMaskIntoConstraints = false
        parameterTextLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [parameterLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
             parameterLabel.topAnchor.constraint(equalTo: topAnchor),
             parameterLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])

        NSLayoutConstraint.activate(
            [parameterTextLabel.leadingAnchor.constraint(equalTo: parameterLabel.trailingAnchor, constant: 5.0),
             parameterTextLabel.topAnchor.constraint(equalTo: topAnchor),
             parameterTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
             parameterTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
