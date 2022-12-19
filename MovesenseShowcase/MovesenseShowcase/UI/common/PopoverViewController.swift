//
// PopoverViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    private enum Constants {
        static let buttonTitleFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        static let viewCornerRadius: CGFloat = 4.0
        static let viewShadowAlpha: CGFloat = 0.5
        static let viewShadowBlur: CGFloat = 4.0
        static let viewShadowColor: UIColor = UIColor.black
        static let viewShadowOffsetX: CGFloat = 0.0
        static let viewShadowOffsetY: CGFloat = 2.0
        static let transitionDuration: Double = 0.35
    }

    private let actionButton: ActionButton = ActionButton()
    private let actionButtonAction: () -> Void
    private let dismissButton: UIButton = UIButton(type: .custom)
    private let contentView: UIView
    private let containerView: UIView = UIView()

    private init(contentView: UIView, buttonTitle: String, dismissTitle: String, action: @escaping () -> Void) {
        self.actionButtonAction = action
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)

        actionButton.addTarget(self, action: #selector(confirmationAction), for: .touchUpInside)
        actionButton.titleLabel?.font = Constants.buttonTitleFont
        actionButton.setTitle(buttonTitle, for: .normal)

        dismissButton.setTitle(dismissTitle, for: .normal)
        dismissButton.setTitleColor(.confirmationCancel, for: .normal)
        dismissButton.setTitleColor(UIColor.confirmationCancel.withAlphaComponent(0.5), for: .highlighted)
        dismissButton.titleLabel?.textAlignment = .center
        dismissButton.titleLabel?.font = Constants.buttonTitleFont
        dismissButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)

        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = Constants.viewCornerRadius
        containerView.layer.applySketchShadow(color: Constants.viewShadowColor,
                                              alpha: Constants.viewShadowAlpha,
                                              x: Constants.viewShadowOffsetX,
                                              y: Constants.viewShadowOffsetX,
                                              blur: Constants.viewShadowBlur)
        view.backgroundColor = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        layoutView()
    }

    static func popoverAction(contentView: UIView,
                              buttonTitle: String, dismissTitle: String,
                              action: @escaping () -> Void) {

        let popoverController = PopoverViewController(contentView: contentView, buttonTitle: buttonTitle,
                                                      dismissTitle: dismissTitle, action: action)

        popoverController.modalPresentationStyle = .custom

        let popoverWindow = UIWindow(frame: UIScreen.main.bounds)
        popoverWindow.rootViewController = UIViewController()
        popoverWindow.rootViewController?.view.backgroundColor = UIColor.clear
        popoverWindow.windowLevel = UIWindow.Level.alert + 1
        popoverWindow.makeKeyAndVisible()
        popoverWindow.rootViewController?.present(popoverController, animated: true)

        UIView.animate(withDuration: Constants.transitionDuration) {
            popoverWindow.rootViewController?.view.backgroundColor = UIColor.confirmationBackground
        }
    }

    @objc private func confirmationAction() {
        actionButtonAction()

        dismiss(animated: true)

        UIView.animate(withDuration: Constants.transitionDuration) {
            self.presentingViewController?.view.backgroundColor = UIColor.clear
        }
    }

    @objc private func cancelAction() {
        dismiss(animated: true)

        UIView.animate(withDuration: Constants.transitionDuration) {
            self.presentingViewController?.view.backgroundColor = UIColor.clear
        }
    }

    private func layoutView() {
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        containerView.addSubview(actionButton)
        containerView.addSubview(dismissButton)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32.0),
             containerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [contentView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
             contentView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
             contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
             contentView.bottomAnchor.constraint(equalTo: actionButton.topAnchor)])

        NSLayoutConstraint.activate(
            [actionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
             actionButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -46.0),
             actionButton.heightAnchor.constraint(equalToConstant: 56.0),
             actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -114.0)])

        NSLayoutConstraint.activate(
            [dismissButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
             dismissButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: -40.0),
             dismissButton.heightAnchor.constraint(equalToConstant: 44.0),
             dismissButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 16.0)])
    }
}
