//
// AppInfoViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {

    private enum Constants {
        static let updateDateFormat: String = "MMM dd, YYYY"
    }

    private let appNameLabel: UILabel
    private let appVersionLabel: UILabel
    private let appUpdatedLabel: UILabel
    private let appCompanyLabel: UILabel
    private let appCompatibilityLabel: UILabel
    private let checkUpdatesButton: ActionButton

    init() {
        self.appNameLabel = UILabel.init(with: UIFont.systemFont(ofSize: 17, weight: .semibold),
                                         inColor: UIColor.titleTextBlack, lines: 1,
                                         text: NSLocalizedString("APP_INFO_APP_NAME_TITLE", comment: ""))
        self.appVersionLabel = UILabel.init(with: UIFont.systemFont(ofSize: 16, weight: .light),
                                            inColor: UIColor.titleTextBlack, lines: 1)
        self.appUpdatedLabel = UILabel.init(with: UIFont.systemFont(ofSize: 16, weight: .light),
                                            inColor: UIColor.titleTextBlack, lines: 1)
        self.appCompanyLabel = UILabel.init(with: UIFont.systemFont(ofSize: 16, weight: .light),
                                            inColor: UIColor.titleTextBlack, lines: 2,
                                            text: NSLocalizedString("APP_INFO_APP_COMPANY_TITLE", comment: ""))
        self.appCompatibilityLabel = UILabel.init(with: UIFont.systemFont(ofSize: 16, weight: .light),
                                                  inColor: UIColor.titleTextBlack, lines: 0,
                                                  text: NSLocalizedString("APP_INFO_APP_COMPATIBILITY_TITLE", comment: ""))
        self.checkUpdatesButton = ActionButton()
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        appCompatibilityLabel.textAlignment = .left

        checkUpdatesButton.isHidden = true // For now
        checkUpdatesButton.isEnabled = false
        checkUpdatesButton.setTitle(NSLocalizedString("APP_INFO_CHECK_UPDATES_BUTTON_TITLE", comment: ""), for: .normal)
        checkUpdatesButton.addTarget(self, action: #selector(checkUpdatesAction), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("APP_INFO_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                                           target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        appVersionLabel.text = NSLocalizedString("APP_INFO_APP_VERSION", comment: "") +
                               "\(Configuration.bundleVersion ?? "n/a") (\(Configuration.bundleBuild ?? "n/a"))"

        appUpdatedLabel.text = NSLocalizedString("APP_INFO_APP_UPDATED", comment: "") + (formattedUpdateDate() ?? "n/a")

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc private func backAction(sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // TODO: Take into use at a later date
    @objc private func checkUpdatesAction(sender: Any) {
        DispatchQueue.global().async {
            guard let appStoreVersion = Configuration.getAppStoreVersion() else { return }

            if appStoreVersion != Configuration.bundleVersion {
                DispatchQueue.main.async {

                }
            }
        }
    }

    private func formattedUpdateDate() -> String? {
        let updateDateFormatted: String?
        if let updateDate = Configuration.getUpdateDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constants.updateDateFormat
            updateDateFormatted = dateFormatter.string(from: updateDate)
        } else {
            updateDateFormatted = .none
        }

        return updateDateFormatted
    }

    private func layoutView() {
        view.addSubview(appNameLabel)
        view.addSubview(appVersionLabel)
        view.addSubview(appUpdatedLabel)
        view.addSubview(appCompanyLabel)
        view.addSubview(appCompatibilityLabel)
        view.addSubview(checkUpdatesButton)

        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        appUpdatedLabel.translatesAutoresizingMaskIntoConstraints = false
        appCompanyLabel.translatesAutoresizingMaskIntoConstraints = false
        appCompatibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        checkUpdatesButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
             appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [appCompanyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             appCompanyLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 6.0),
             appCompanyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [appVersionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             appVersionLabel.topAnchor.constraint(equalTo: appCompanyLabel.bottomAnchor, constant: 16.0),
             appVersionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [appUpdatedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             appUpdatedLabel.topAnchor.constraint(equalTo: appVersionLabel.bottomAnchor),
             appUpdatedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [appCompatibilityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             appCompatibilityLabel.topAnchor.constraint(equalTo: appUpdatedLabel.bottomAnchor, constant: 16.0),
             appCompatibilityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [checkUpdatesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             checkUpdatesButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -78.0),
             checkUpdatesButton.heightAnchor.constraint(equalToConstant: 56.0),
             checkUpdatesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60.0)])

        view.layoutIfNeeded()
    }
}
