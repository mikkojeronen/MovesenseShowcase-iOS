//
// MoreViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    private let tableView: UITableView

    private let generalLabel: UILabel
    private let generalSeparator: UIView
    private let tableViewCells: [MoreItemTableViewCell]

    init() {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.generalLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0),
                                    inColor: UIColor.titleTextBlack.withAlphaComponent(0.6),
                                    lines: 1, text: NSLocalizedString("MORE_GENERAL_TITLE", comment: ""))
        self.generalSeparator = UIView.separator()

        let releaseCells = [
            MoreItemTableViewCell(title: NSLocalizedString("APP_INFO_NAV_TITLE", comment: ""),
                                  item: { return AppInfoViewController() }),
            MoreItemTableViewCell(title: NSLocalizedString("ABOUT_NAV_TITLE", comment: ""),
                                  item: { return AboutViewController() }),
            MoreItemTableViewCell(title: NSLocalizedString("FAQ_NAV_TITLE", comment: ""),
                                  item: { return FaqViewController() }),
            MoreItemTableViewCell(title: NSLocalizedString("TERMS_OF_SERVICE_NAV_TITLE", comment: ""),
                                  item: { return TermsViewController(displayAcceptAction: false) }),
            MoreItemTableViewCell(title: NSLocalizedString("DFU_RECOVERY_NAV_TITLE", comment: ""),
                                  item: { return DfuRecoveryViewController() }),
            MoreItemTableViewCell(title: NSLocalizedString("ONBOARDING_NAV_TITLE", comment: ""),
                                  item: { return OnboardingIntroViewController(nextViewController: OnboardingViewController()) })]

        #if DEBUG
        self.tableViewCells = releaseCells + [MoreItemTableViewCell(title: "Testing",
                                                                    item: { return TestingViewController() })]
        #else
        self.tableViewCells = releaseCells
        #endif

        super.init(nibName: nil, bundle: nil)

        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func itemAction(_ itemViewController: UIViewController) {
        navigationController?.pushViewController(itemViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("MORE_NAV_TITLE", comment: "")

        tableView.tableHeaderView = generalLabel
        tableView.tableFooterView = UIView()

        tableView.register(MoreItemTableViewCell.self, forCellReuseIdentifier: "MoreItemTableViewCell")

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func layoutView() {
        view.addSubview(tableView)

        generalLabel.addSubview(generalSeparator)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        generalLabel.translatesAutoresizingMaskIntoConstraints = false
        generalSeparator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52.0),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        NSLayoutConstraint.activate(
            [generalLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
             generalLabel.widthAnchor.constraint(equalTo: tableView.widthAnchor),
             generalLabel.topAnchor.constraint(equalTo: tableView.topAnchor)])

        NSLayoutConstraint.activate(
            [generalSeparator.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
             generalSeparator.widthAnchor.constraint(equalTo: tableView.widthAnchor),
             generalSeparator.topAnchor.constraint(equalTo: generalLabel.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension MoreViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCells.count
    }
}

extension MoreViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableViewCells[safe: indexPath.item] else { return UITableViewCell() }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableViewCells[safe: indexPath.item] else { return }

        itemAction(cell.moreItem())

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
