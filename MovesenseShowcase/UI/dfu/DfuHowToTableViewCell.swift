//
// DfuHowToTableViewCell.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DfuHowToTableViewCell: UITableViewCell {

    private let stepLabel: UILabel
    private let stepImageView: UIImageView

    private var stepImageBottomConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.stepLabel = UILabel(with: UIFont.systemFont(ofSize: 16), inColor: UIColor.titleTextBlack, lines: 0)
        self.stepImageView = UIImageView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        stepLabel.lineBreakMode = .byWordWrapping

        stepImageView.contentMode = .scaleAspectFill

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView(stepText: String, stepImage: String?) {
        stepLabel.attributedText = NSAttributedString(withLocalizedHTMLString: stepText)

        if let stepImage = stepImage {
            stepImageView.image = UIImage(named: stepImage)
            stepImageBottomConstraint?.constant = -32.0
        } else {
            stepImageView.image = nil
            stepImageBottomConstraint?.constant = 0.0
        }

        layoutIfNeeded()
    }

    private func layoutView() {
        contentView.addSubview(stepLabel)
        contentView.addSubview(stepImageView)

        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
             stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)])

        NSLayoutConstraint.activate(
            [stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             stepImageView.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 16.0),
             stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)])

        stepImageBottomConstraint = stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        stepImageBottomConstraint?.priority = .defaultHigh
        stepImageBottomConstraint?.isActive = true
    }
}
