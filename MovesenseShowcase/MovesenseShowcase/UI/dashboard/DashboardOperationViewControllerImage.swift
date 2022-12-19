//
// DashboardOperationViewControllerImage.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class DashboardOperationViewControllerImage: UIViewController {

    private let contentImage: UIImageView = UIImageView(image: UIImage(named: "image_sensor"))

    init() {
        super.init(nibName: nil, bundle: nil)

        contentImage.contentMode = .scaleAspectFit
        contentImage.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
    }

    private func layoutView() {
        view.addSubview(contentImage)

        contentImage.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [contentImage.leftAnchor.constraint(equalTo: view.leftAnchor),
             contentImage.topAnchor.constraint(equalTo: view.topAnchor),
             contentImage.rightAnchor.constraint(equalTo: view.rightAnchor),
             contentImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        view.layoutIfNeeded()
    }
}
