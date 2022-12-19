//
// TermsViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    private enum Constants {
        static let buttonBorderWidth: CGFloat = 2.0
        static let buttonCornerRadius: CGFloat = 5.0
    }

    private let acceptButton: ActionButton = ActionButton()
    private let moreButton: UIButton = UIButton(type: .system)
    private let buttonContainer: UIView = UIView()
    private let termsTextView: UITextView = UITextView()
    private let displayAcceptAction: Bool

    private var termsAcceptedConstraint: NSLayoutConstraint?

    init(displayAcceptAction: Bool) {
        self.displayAcceptAction = displayAcceptAction
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white
        buttonContainer.backgroundColor = UIColor.white

        acceptButton.addTarget(self, action: #selector(acceptButtonTap(sender:)), for: .touchUpInside)
        acceptButton.setTitle(NSLocalizedString("TERMS_OF_SERVICE_BUTTON_ACCEPT", comment: ""), for: .normal)

        moreButton.addTarget(self, action: #selector(moreButtonTap(sender:)), for: .touchUpInside)
        moreButton.setTitle(NSLocalizedString("TERMS_OF_SERVICE_BUTTON_READ_MORE", comment: ""), for: .normal)
        moreButton.setTitleColor(UIColor.red, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("TERMS_OF_SERVICE_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                                           target: self, action: #selector(backButtonTap))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        let attributedTerms = NSAttributedString(withLocalizedHTMLString: NSLocalizedString("TERMS_OF_SERVICE_TEXT_HTML",
                                                                                            comment: ""))
        termsTextView.isEditable = false
        termsTextView.showsVerticalScrollIndicator = false
        termsTextView.attributedText = attributedTerms

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        termsAcceptedConstraint?.constant = displayAcceptAction ? -buttonContainer.frame.height : 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        termsTextView.setContentOffset(CGPoint.zero, animated: false)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = moreButton.bounds
        gradientLayer.colors = [UIColor.gradientEnd.cgColor, UIColor.gradientStart.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = Constants.buttonCornerRadius

        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = Constants.buttonBorderWidth
        maskLayer.path = UIBezierPath(roundedRect: moreButton.bounds, cornerRadius: Constants.buttonCornerRadius).cgPath
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.fillColor = nil

        gradientLayer.mask = maskLayer

        moreButton.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        moreButton.layer.addSublayer(gradientLayer)
    }

    @objc private func acceptButtonTap(sender: Any) {
        Settings.isTermsAccepted = true
        navigationController?.setViewControllers([TabBarViewController.sharedInstance, OnboardingViewController()],
                                                 animated: true)
    }

    @objc private func backButtonTap(sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func moreButtonTap(sender: Any) {
        if let url = URL(string: "https://www.movesense.com") {
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func layoutView() {
        view.addSubview(termsTextView)
        view.addSubview(buttonContainer)

        buttonContainer.addSubview(acceptButton)
        buttonContainer.addSubview(moreButton)

        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [termsTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10.0),
             termsTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             termsTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0)])

        NSLayoutConstraint.activate(
            [buttonContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
             buttonContainer.topAnchor.constraint(equalTo: termsTextView.bottomAnchor),
             buttonContainer.rightAnchor.constraint(equalTo: view.rightAnchor)])

        NSLayoutConstraint.activate(
            [acceptButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
             acceptButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor, constant: -40.0),
             acceptButton.heightAnchor.constraint(equalToConstant: 56.0),
             acceptButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 32.0)])

        NSLayoutConstraint.activate(
            [moreButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
             moreButton.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor, constant: -40.0),
             moreButton.heightAnchor.constraint(equalToConstant: 56.0),
             moreButton.topAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 10.0),
             moreButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: -32.0)])

        termsAcceptedConstraint = buttonContainer.topAnchor.constraint(equalTo: view.bottomAnchor)
        termsAcceptedConstraint?.isActive = true

        view.layoutIfNeeded()
    }
}
