//
// ActionButtonView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class ActionButtonView: UIView {

    private let actionButton: ActionButton = ActionButton()

    init() {
        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.white

        actionButton.setTitleColor(UIColor.white, for: .normal)

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setAction(target: Any?, action: Selector, for controlEvents: UIControl.Event, actionName: String) {
        actionButton.setTitle(actionName, for: .normal)
        actionButton.addTarget(target, action: action, for: controlEvents)
    }

    private func layoutView() {
        addSubview(actionButton)

        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [actionButton.topAnchor.constraint(equalTo: topAnchor, constant: 23.0),
             actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
             actionButton.widthAnchor.constraint(equalTo: widthAnchor, constant: -46.0),
             actionButton.heightAnchor.constraint(equalToConstant: 56.0)])
    }
}
