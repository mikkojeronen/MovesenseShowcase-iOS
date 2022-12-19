//
// WelcomeBackView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class WelcomeBackView: UIView {

    private enum Constants {
        static let titleLabelFont: UIFont = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        static let textLabelFont: UIFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
    }

    private let imageView: UIImageView
    private let titleLabel: UILabel
    private let textLabel: UILabel

    init() {
        self.imageView = UIImageView(image: UIImage(named: "image_movesense_symbol_red"))
        self.titleLabel = UILabel(with: Constants.titleLabelFont,
                                  inColor: .titleTextBlack,
                                  lines: 1, text: NSLocalizedString("DASHBOARD_WELCOME_BACK_TITLE", comment: ""))

        self.textLabel = UILabel(with: Constants.textLabelFont,
                                 inColor: .titleTextBlack,
                                 lines: 0, text: NSLocalizedString("DASHBOARD_WELCOME_BACK_TEXT", comment: ""))

        super.init(frame: CGRect.zero)

        titleLabel.textAlignment = .center
        textLabel.textAlignment = .center

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(textLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
             imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20.0)])

        NSLayoutConstraint.activate(
            [titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             titleLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -32.0),
             titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 40.0)])

        NSLayoutConstraint.activate(
            [textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             textLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -32.0),
             textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0)])
    }
}
