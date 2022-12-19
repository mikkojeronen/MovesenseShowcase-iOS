//
// MoreItemTableViewCell.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class MoreItemTableViewCell: UITableViewCell {

    private let moreLabel: UILabel
    private let moreIcon: UIImageView

    let moreItem: () -> UIViewController

    init(title: String, item: @escaping () -> UIViewController) {
        self.moreLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                                 inColor: UIColor.titleTextBlack, lines: 1, text: title)
        self.moreIcon = UIImageView(image: UIImage(named: "icon_arrow_right_red_gradient"))
        self.moreItem = item
        super.init(style: .default, reuseIdentifier: "MoreItemTableViewCell")

        moreIcon.contentMode = .scaleAspectFit

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layoutView() {
        contentView.addSubview(moreLabel)
        contentView.addSubview(moreIcon)

        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        moreIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [moreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             moreLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
             moreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [moreIcon.leadingAnchor.constraint(greaterThanOrEqualTo: moreLabel.trailingAnchor),
             moreIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
             moreIcon.centerYAnchor.constraint(equalTo: moreLabel.centerYAnchor)])

        let heightConstraint = moreLabel.heightAnchor.constraint(equalToConstant: 44.0)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }
}
