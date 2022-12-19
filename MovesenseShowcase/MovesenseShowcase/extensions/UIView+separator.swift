//
// UIView+separator.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

extension UIView {

    static func separator(color: UIColor = UIColor.separatorGray, separatorHeight: CGFloat = 1) -> UIView {
        let view = UIView(frame: CGRect.zero)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color

        NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: separatorHeight / UIScreen.main.scale)]
                                        .map { $0.priority = .defaultHigh; return $0 })
        return view
    }

    static func separator(color: UIColor = UIColor.separatorGray,
                          separatorHeight: CGFloat = 1,
                          leading: CGFloat = 0, trailing: CGFloat = 0,
                          top: CGFloat = 0, bottom: CGFloat = 0) -> UIView {
        let view = UIView(frame: CGRect.zero)

        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: separatorHeight / UIScreen.main.scale)]
                                        .map { $0.priority = .defaultHigh; return $0 })

        if leading != 0 || trailing != 0 || top != 0 || bottom != 0 {
            let outer = UIView(frame: CGRect.zero)

            outer.addSubview(view)

            outer.backgroundColor = UIColor.clear
            outer.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate(
                [view.leadingAnchor.constraint(equalTo: outer.leadingAnchor, constant: leading),
                 view.topAnchor.constraint(equalTo: outer.topAnchor, constant: top),
                 view.trailingAnchor.constraint(equalTo: outer.trailingAnchor, constant: trailing),
                 view.bottomAnchor.constraint(equalTo: outer.bottomAnchor, constant: bottom)]
                    .map { $0.priority = .defaultHigh; return $0 })

            return outer
        } else {
            return view
        }
    }
}
