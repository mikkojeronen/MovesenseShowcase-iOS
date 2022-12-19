//
// RecordingsTabViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class RecordingsTabViewController: UIViewController {

    private let viewModel: RecordingsViewModel
    private let tableView: UITableView
    private let selectItem: UIBarButtonItem
    private let actionItem: UIBarButtonItem
    private let trashItem: UIBarButtonItem
    private let flexItem: UIBarButtonItem
    private let noRecordingsView: PlaceholderView

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        self.viewModel = RecordingsViewModel()
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.selectItem = UIBarButtonItem(title: "Select", style: .plain, target: nil, action: nil)
        self.actionItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        self.trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
        self.flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.noRecordingsView = PlaceholderView(title: NSLocalizedString("RECORDINGS_PLACEHOLDER_TITLE", comment: ""),
                                                actionTitle: nil)
        super.init(nibName: nil, bundle: nil)

        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.estimatedRowHeight = 45.0
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = UIColor.separatorGray
        tableView.delegate = self
        tableView.dataSource = self

        selectItem.target = self
        selectItem.action = #selector(selectAction)

        actionItem.target = self
        actionItem.action = #selector(actionAction(sender:))

        trashItem.target = self
        trashItem.action = #selector(trashAction)

        viewModel.addObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("RECORDINGS_NAV_TITLE", comment: "")
        navigationItem.rightBarButtonItem = selectItem

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(RecordingsTableViewCell.self, forCellReuseIdentifier: "RecordsTableViewCell")

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectItem.title = NSLocalizedString("RECORDINGS_NAV_SELECT", comment: "")
        tableView.numberOfSections > 0 ? (selectItem.isEnabled = true) : (selectItem.isEnabled = false)

        tabBarController?.setToolbarItems([flexItem, actionItem, flexItem, trashItem, flexItem], animated: false)

        if let indexPaths = tableView.indexPathsForSelectedRows {
            indexPaths.forEach { tableView.deselectRow(at: $0, animated: false) }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.setToolbarItems(nil, animated: false)
        tabBarController?.navigationController?.setToolbarHidden(true, animated: true)

        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        tableView.visibleCells.forEach { $0.selectionStyle = .none }
    }

    @objc private func selectAction() {
        if tableView.allowsSelection {
            selectItem.title = NSLocalizedString("RECORDINGS_NAV_SELECT", comment: "")
            tableView.visibleCells.forEach { $0.selectionStyle = .none }
            tableView.allowsSelection = false
            tableView.allowsMultipleSelection = false
            tabBarController?.navigationController?.setToolbarHidden(true, animated: true)
        } else {
            selectItem.title = NSLocalizedString("RECORDINGS_NAV_CANCEL", comment: "")
            tableView.visibleCells.forEach { $0.selectionStyle = .default }
            tableView.allowsSelection = true
            tableView.allowsMultipleSelection = true
            tabBarController?.navigationController?.setToolbarHidden(false, animated: true)
        }

        if let indexPaths = tableView.indexPathsForSelectedRows {
            indexPaths.forEach { tableView.deselectRow(at: $0, animated: false) }
        }
    }

    @objc private func actionAction(sender: UIView) {
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }

        // TODO: Might take a long time, implement a progress view and execute in background
        let tempUrls: [URL] = viewModel.tempCopyRecords(indexPaths: indexPaths)

        let activityViewController = UIActivityViewController(
            activityItems: tempUrls,
            applicationActivities: [RecordingsConvertActivity()])

        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.completionWithItemsHandler = { [weak self]
        (activityType: UIActivity.ActivityType?,
         completed: Bool,
         returnedItems: [Any]?,
         activityError: Error?) -> Void in

            self?.viewModel.tempClear()
        }

        present(activityViewController, animated: true)
    }

    @objc private func trashAction() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }

        indexPaths.forEach(viewModel.removeRecord)
    }

    private func layoutView() {
        view.addSubview(tableView)
        view.addSubview(noRecordingsView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        noRecordingsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        NSLayoutConstraint.activate(
            [noRecordingsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             noRecordingsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             noRecordingsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             noRecordingsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension RecordingsTabViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = viewModel.getRecordSectionCount()

        if sectionCount > 0 {
            noRecordingsView.isHidden = true
        } else {
            noRecordingsView.isHidden = false
        }

        return sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRecordCount(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.getRecords()[safe: section]?.section ?? "n/a"
    }
}

extension RecordingsTabViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordsTableViewCell",
                                                       for: indexPath) as? RecordingsTableViewCell,
              let record = viewModel.getRecord(indexPath) else {

            return UITableViewCell(frame: CGRect.zero)
        }

        cell.setupView(viewModel: record) { [weak self] in
            guard let self = self else { return }
            let detailsVC = RecordingsDetailsViewController(viewModel: record, recordingsViewModel: self.viewModel)
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        tableView.allowsSelection ? (cell.selectionStyle = .default) : (cell.selectionStyle = .none)

        CATransaction.commit()

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle = viewModel.getRecords()[safe: section]?.section else {
            return UIView(frame: CGRect.zero)
        }

        return RecordingsSectionHeader(title: sectionTitle)
    }
}

extension RecordingsTabViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? RecorderObserverEvent else { return }

        switch event {
        case .recordsUpdated:
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.tableView.numberOfSections == 0 {
                    self.tabBarController?.navigationController?.setToolbarHidden(true, animated: true)
                    self.selectItem.title = NSLocalizedString("SELECT", comment: "")
                    self.selectItem.isEnabled = false
                }
            }
        default: return
        }
    }
}
