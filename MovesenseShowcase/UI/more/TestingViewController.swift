//
// TestingViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {

    private let resetFirstLaunchButton: ActionButton
    private let resetTermsAcceptedButton: ActionButton
    private let resetWelcomeBackButton: ActionButton

    init() {
        self.resetFirstLaunchButton = ActionButton()
        self.resetTermsAcceptedButton = ActionButton()
        self.resetWelcomeBackButton = ActionButton()
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        resetFirstLaunchButton.setTitle("Reset First Launch", for: .normal)
        resetFirstLaunchButton.addTarget(self, action: #selector(resetFirstLaunchAction), for: .touchUpInside)
        resetFirstLaunchButton.isEnabled = Settings.isFirstLaunch == false

        resetTermsAcceptedButton.setTitle("Reset Terms Accepted", for: .normal)
        resetTermsAcceptedButton.addTarget(self, action: #selector(resetTermsAcceptedAction), for: .touchUpInside)
        resetTermsAcceptedButton.isEnabled = Settings.isTermsAccepted

        resetWelcomeBackButton.setTitle("Reset Welcome Back", for: .normal)
        resetWelcomeBackButton.addTarget(self, action: #selector(resetWelcomeBackAction), for: .touchUpInside)
        resetWelcomeBackButton.isEnabled = Settings.previousDashboardLaunchDate != Date.distantPast
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = "Testing"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                                           target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        resetFirstLaunchButton.isEnabled = Settings.isFirstLaunch == false
        resetTermsAcceptedButton.isEnabled = Settings.isTermsAccepted
        resetWelcomeBackButton.isEnabled = Settings.previousDashboardLaunchDate != Date.distantPast
    }

    @objc private func backAction(sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func resetFirstLaunchAction(sender: Any) {
        Settings.isFirstLaunch = true
        resetFirstLaunchButton.isEnabled = Settings.isFirstLaunch == false
    }

    @objc private func resetTermsAcceptedAction(sender: Any) {
        Settings.isTermsAccepted = false
        resetTermsAcceptedButton.isEnabled = Settings.isTermsAccepted
    }

    @objc private func resetWelcomeBackAction(sender: Any) {
        Settings.previousDashboardLaunchDate = Date.distantPast
        resetWelcomeBackButton.isEnabled = Settings.previousDashboardLaunchDate != Date.distantPast
    }

    private func layoutView() {
        view.addSubview(resetFirstLaunchButton)
        view.addSubview(resetTermsAcceptedButton)
        view.addSubview(resetWelcomeBackButton)

        resetFirstLaunchButton.translatesAutoresizingMaskIntoConstraints = false
        resetTermsAcceptedButton.translatesAutoresizingMaskIntoConstraints = false
        resetWelcomeBackButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [resetFirstLaunchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             resetFirstLaunchButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -78.0),
             resetFirstLaunchButton.heightAnchor.constraint(equalToConstant: 56.0),
             resetFirstLaunchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0)])

        NSLayoutConstraint.activate(
            [resetTermsAcceptedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             resetTermsAcceptedButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -78.0),
             resetTermsAcceptedButton.heightAnchor.constraint(equalToConstant: 56.0),
             resetTermsAcceptedButton.topAnchor.constraint(equalTo: resetFirstLaunchButton.bottomAnchor, constant: 16.0)])

        NSLayoutConstraint.activate(
            [resetWelcomeBackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             resetWelcomeBackButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -78.0),
             resetWelcomeBackButton.heightAnchor.constraint(equalToConstant: 56.0),
             resetWelcomeBackButton.topAnchor.constraint(equalTo: resetTermsAcceptedButton.bottomAnchor, constant: 16.0)])

        view.layoutIfNeeded()
    }
}
