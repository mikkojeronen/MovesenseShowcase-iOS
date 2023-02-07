//
// OnboardingIntroPageView.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class OnboardingIntroPageView: UIView {

    private let imageView: UIImageView
    private let titleLabel: UILabel
    private let descriptionLabel: UILabel

    init(image: String, title: String, description: String) {
        self.imageView = UIImageView(image: UIImage(named: image))
        self.titleLabel = UILabel(with: UIFont.systemFont(ofSize: 24.0, weight: .bold), inColor: .white,
                                  lines: 1, text: title)
        self.descriptionLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .white, lines: 0)
        super.init(frame: CGRect.zero)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        descriptionLabel.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.alignment = .center

        let attributedDescription = NSMutableAttributedString(string: description)
        attributedDescription.addAttribute(.paragraphStyle, value: paragraphStyle,
                                           range: NSRange(location: 0, length: attributedDescription.length))

        descriptionLabel.attributedText = attributedDescription

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
             imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -122.0),
             imageView.widthAnchor.constraint(equalToConstant: 179.0),
             imageView.heightAnchor.constraint(equalToConstant: 179.0)])

        NSLayoutConstraint.activate(
            [titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32.0)])

        NSLayoutConstraint.activate(
            [descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
             descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0),
             descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -64.0)])
    }
}
