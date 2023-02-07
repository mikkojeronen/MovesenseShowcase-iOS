//
// ConfirmationView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class ConfirmationView: UIView {

    private enum Constants {
        static let confirmationTitleLabelFont: UIFont = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        static let confirmationTextLabelFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    }

    private let confirmationImageView: UIImageView
    private let confirmationTitleLabel: UILabel
    private let confirmationTextLabel: UILabel

    init(title: String, text: String? = nil, image: UIImage? = nil) {
        self.confirmationImageView = UIImageView(image: image)
        self.confirmationTitleLabel = UILabel(with: Constants.confirmationTitleLabelFont,
                                              inColor: .titleTextBlack,
                                              lines: 0, text: title)

        self.confirmationTextLabel = UILabel(with: Constants.confirmationTextLabelFont,
                                             inColor: .titleTextBlack,
                                             lines: 0, text: text)

        super.init(frame: CGRect.zero)

        confirmationTitleLabel.textAlignment = .center
        confirmationTextLabel.textAlignment = .center

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(confirmationImageView)
        addSubview(confirmationTitleLabel)
        addSubview(confirmationTextLabel)

        confirmationImageView.translatesAutoresizingMaskIntoConstraints = false
        confirmationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmationTextLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [confirmationImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
             confirmationImageView.bottomAnchor.constraint(equalTo: confirmationTitleLabel.topAnchor, constant: -20.0)])

        NSLayoutConstraint.activate(
            [confirmationTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             confirmationTitleLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -32.0),
             confirmationTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 40.0)])

        NSLayoutConstraint.activate(
            [confirmationTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             confirmationTextLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -32.0),
             confirmationTextLabel.topAnchor.constraint(equalTo: confirmationTitleLabel.bottomAnchor, constant: 32.0)])
    }
}
