//
// DfuTargListViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DfuTargListViewController: UIViewController {

    private enum Constants {
        static let actionViewHeight: CGFloat = 125.0
    }

    private let viewModel: DfuViewModel

    private let placeholderImageView: UIImageView
    private let placeholderLabel: UILabel
    private let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
    private let actionButtonView: ActionButtonView = ActionButtonView()
    private var actionConstraint: NSLayoutConstraint?

    init(viewModel: DfuViewModel) {
        self.viewModel = viewModel
        self.placeholderImageView = UIImageView(image: UIImage(named: "image_placeholder"))
        self.placeholderLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                        inColor: UIColor.titleTextBlack, lines: 1,
                                        text: NSLocalizedString("DFU_TARG_PLACEHOLDER_TITLE", comment: ""))
        super.init(nibName: nil, bundle: nil)

        actionButtonView.alpha = 0.0
        actionButtonView.setAction(target: self, action: #selector(handleActionTap), for: .touchUpInside,
                                   actionName: NSLocalizedString("DFU_TARG_UPDATE_FIRMWARE_TITLE", comment: ""))

        placeholderImageView.contentMode = .scaleAspectFit

        placeholderLabel.textAlignment = .center

        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.rowHeight = 99.0
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.delegate = self
        tableView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)

        view.backgroundColor = UIColor.white

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("DFU_TARG_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_cross"), style: .plain,
                                                           target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.titleTextBlack

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh,
                                                            target: self, action: #selector(refreshAction))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.titleTextBlack

        // Enable swipe from left to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(ConnectTableViewCell.self, forCellReuseIdentifier: "DfuListTableViewCell")

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        tableView.reloadData()

        viewModel.addObserver(self)
        viewModel.resetDfu()
        viewModel.startDevicesScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopDevicesScan()
        viewModel.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButtonView.topShadow(color: UIColor.black, opacity: 0.2, radius: 5)
    }

    @objc private func applicationWillResignActive() {
        viewModel.resetDevices()
        tableView.reloadData()

        actionConstraint?.constant = Constants.actionViewHeight
        actionButtonView.alpha = 0.0
    }

    @objc private func applicationDidBecomeActive() {
        viewModel.resetDfu()
        viewModel.startDevicesScan()
    }

    @objc private func backAction() {
        dismiss(animated: true)
    }

    @objc private func refreshAction() {
        viewModel.resetDevices()
        tableView.reloadData()

        UIView.animate(withDuration: 0.5, animations: {
            self.actionConstraint?.constant = Constants.actionViewHeight
            self.actionButtonView.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.viewModel.startDevicesScan()
        })
    }

    @objc private func handleActionTap() {
        guard let indexPath = tableView.indexPathForSelectedRow,
              let selectedDevice = viewModel.getDiscoveredDevices()[safe: indexPath.item] else { return }

        viewModel.selectedDevice = selectedDevice

        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setViewControllers([DfuProgressViewController(viewModel: viewModel)], animated: true)
    }

    private func layoutView() {
        view.addSubview(tableView)
        view.addSubview(actionButtonView)
        view.addSubview(placeholderImageView)
        placeholderImageView.addSubview(placeholderLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        actionButtonView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        NSLayoutConstraint.activate(
            [actionButtonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
             actionButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             actionButtonView.widthAnchor.constraint(equalTo: view.widthAnchor),
             actionButtonView.heightAnchor.constraint(equalToConstant: Constants.actionViewHeight)])

        NSLayoutConstraint.activate(
            [placeholderImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor),
             placeholderImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             placeholderImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
             placeholderLabel.centerYAnchor.constraint(equalTo: placeholderImageView.centerYAnchor),
             placeholderLabel.widthAnchor.constraint(equalTo: placeholderImageView.widthAnchor, constant: -32.0)])

        actionConstraint = actionButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                    constant: Constants.actionViewHeight)
        actionConstraint?.isActive = true

        view.layoutIfNeeded()
    }
}

extension DfuTargListViewController: Observer {
    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventDfu else { return }

        switch event {
        case .dfuStateChanged(let state): NSLog("DfuTargListViewController::dfuStateChanged(\(state.description))")
        case .dfuDeviceDiscovered(let device): discoveredDevice(device)
        case .dfuUpdateProgress(let part, let totalParts, let progress, let currentSpeed,
                                let avgSpeed): updateProgress(part, totalParts, progress, currentSpeed, avgSpeed)
        case .dfuOnError(let error): NSLog("DfuTargListViewController::dfuOnError(\(error))")
        }
    }

    private func updateProgress(_ part: Int, _ totalParts: Int, _ progress: Int, _ currentSpeed: Double, _ avgSpeed: Double) {
        NSLog("DfuTargListViewController:updateProgress: \(part)/\(totalParts) \(progress) \(currentSpeed) \(avgSpeed)")
    }

    private func discoveredDevice(_ device: DfuDeviceViewModel) {
        NSLog("DfuTargListViewController::discoveredDevice(\(device))")
        DispatchQueue.main.async { [weak self] in
            // Keep selections when a new device is added to the list
            let selections = self?.tableView.indexPathsForSelectedRows
            self?.tableView.reloadData()
            selections?.forEach { selected in
                self?.tableView.selectRow(at: selected, animated: false, scrollPosition: .none)
            }
        }
    }
}

extension DfuTargListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel.getDiscoveredDevices().count

        if rows < 1 {
            placeholderImageView.isHidden = false
        } else {
            placeholderImageView.isHidden = true
        }

        return rows
    }
}

extension DfuTargListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DfuListTableViewCell",
                                                       for: indexPath) as? ConnectTableViewCell else {
            NSLog("Invalid reusable tableview cell in ConnectListViewController.")
            return UITableViewCell()
        }

        if let dfuDevice = viewModel.getDiscoveredDevices()[safe: indexPath.item] {
            cell.setupView(serial: dfuDevice.deviceSerial, name: dfuDevice.deviceName, rssi: dfuDevice.deviceRssi)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: {
            self.actionConstraint?.constant = 0
            self.actionButtonView.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if self.tableView.numberOfSections >= indexPath.section &&
               self.tableView.numberOfRows(inSection: indexPath.section) >= indexPath.row {
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        })
    }
}
