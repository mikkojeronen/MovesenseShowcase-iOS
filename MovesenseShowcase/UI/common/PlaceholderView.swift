//
// PlaceholderView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class PlaceholderView: UIView {

    private let placeholderImageView: UIImageView
    private let placeholderLabel: UILabel

    let actionButton: ActionButton = ActionButton()

    init(title: String, actionTitle: String?) {
        self.placeholderImageView = UIImageView(image: UIImage(named: "image_placeholder"))
        self.placeholderLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .black, lines: 0, text: title)
        super.init(frame: CGRect.zero)

        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
        } else {
            actionButton.isHidden = true
        }

        placeholderImageView.backgroundColor = UIColor.white
        placeholderImageView.contentMode = .scaleAspectFit

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        addSubview(placeholderImageView)
        addSubview(placeholderLabel)
        addSubview(actionButton)

        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
             placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
             placeholderImageView.widthAnchor.constraint(equalTo: widthAnchor),
             placeholderImageView.heightAnchor.constraint(equalTo: heightAnchor)])

        NSLayoutConstraint.activate(
            [placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
             placeholderLabel.centerYAnchor.constraint(equalTo: placeholderImageView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
             actionButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -78.0),
             actionButton.heightAnchor.constraint(equalToConstant: 56.0),
             actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60.0)])
    }
}
