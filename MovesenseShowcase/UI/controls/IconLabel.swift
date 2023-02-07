//
// IconLabel.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class IconLabel: UILabel {

    private let iconImageView: UIImageView

    init(labelIcon: UIImage?, labelText: String) {
        self.iconImageView = UIImageView(image: labelIcon)
        super.init(frame: CGRect.zero)

        iconImageView.contentMode = .scaleAspectFit

        text = labelText
        font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        textColor = UIColor.titleTextBlack
        numberOfLines = 0

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        let adjustedRect = CGRect(x: rect.origin.x + iconImageView.bounds.width + 8.0, y: rect.origin.y,
                                  width: rect.width - iconImageView.bounds.width - 8.0, height: rect.height)
        super.drawText(in: adjustedRect)
    }

    private func layoutView() {
        addSubview(iconImageView)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
             iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)])

        NSLayoutConstraint.activate(
            [heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)])
    }
}
