//
//  ConnectListViewController.swift
//  MovesenseShowcase
//
//  Copyright © 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class ConnectListViewController: UIViewController {

    private enum Constants {
        static let placeholderWidth: CGFloat = 120.0
    }

    private let viewModel: SensorScanningViewModel
    private let searchContainer: UIView = UIView(frame: CGRect.zero)
    private let searchBar: UISearchBar = UISearchBar(frame: CGRect.zero)
    private let connectView: ActionButtonView = ActionButtonView()
    private let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)

    private var connectConstraint: NSLayoutConstraint?

    init(viewModel: SensorScanningViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        connectView.alpha = 0.0
        connectView.setAction(target: self, action: #selector(handleConnectTap), for: .touchUpInside,
                              actionName: NSLocalizedString("CONNECT_SENSOR", comment: ""))

        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.rowHeight = 99.0
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.delegate = self
        tableView.dataSource = self

        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("CONNECT_SEARCH_PLACEHOLDER_TITLE", comment: "")
        searchBar.barTintColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)

        // Trick to remove the search bar cursor movement to the center from displaying when the search bar gets focus
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(applicationWillResignActive),
                                       name: UIApplication.willResignActiveNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                       name: UIApplication.didBecomeActiveNotification, object: nil)

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("CONNECT_AVAILABLE_SENSOR_DEVICES", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_cross"), style: .plain,
                                                           target: self, action: #selector(handleBackTap))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_plus"), style: .plain,
                                                            target: self, action: #selector(handleAddVirtualDevice))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.blue

        // Enable swipe from left to go back
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

        // Tap on the view will remove focus from the search bar
        view.addTapGesture(tapNumber: 1, cancelTouches: false, target: searchBar, action: #selector(resignFirstResponder))

        tableView.tableHeaderView = searchContainer
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(ConnectTableViewCell.self, forCellReuseIdentifier: "ConnectTableViewCell")

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)

        viewModel.resetDevices()
        tableView.reloadData()

        viewModel.addObserver(self)
        viewModel.startDevicesScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopDevicesScan()
        viewModel.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        connectView.topShadow(color: UIColor.black, opacity: 0.2, radius: 5)

        let placeholderLocation = (tableView.frame.width / 2) - Constants.placeholderWidth / 2
        searchBar.setPositionAdjustment(UIOffset(horizontal: placeholderLocation, vertical: 0), for: .search)
    }

    @objc private func applicationWillResignActive() {
        viewModel.resetDevices()
        tableView.reloadData()

        connectConstraint?.constant = 0.0
        connectView.alpha = 0.0
    }

    @objc private func applicationDidBecomeActive() {
        viewModel.startDevicesScan()
    }

    @objc private func handleBackTap() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleAddVirtualDevice() {
        viewModel.createVirtualDevice()
    }

    @objc private func handleConnectTap() {
        guard let selected = tableView.indexPathForSelectedRow?[1] else { return }

        if let device: DeviceViewModel = viewModel.getInactiveDevicesFiltered(searchBar.text)[safe: selected] {
            viewModel.connectDevice(device.serial)
            navigationController?.popViewController(animated: true)
        } else {
            //TODO: Display error
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        searchBar.tintColor = UIColor.clear
    }

    @objc func keyboardDidShow(_ notification: Notification) {
        searchBar.tintColor = UISearchBar.appearance().tintColor
    }

    private func layoutView() {
        view.addSubview(tableView)
        view.addSubview(connectView)
        searchContainer.addSubview(searchBar)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        connectView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        NSLayoutConstraint.activate(
            [connectView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
             connectView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             connectView.widthAnchor.constraint(equalTo: view.widthAnchor),
             connectView.heightAnchor.constraint(equalToConstant: 125.0)])

        connectConstraint = connectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        connectConstraint?.isActive = true

        NSLayoutConstraint.activate(
            [searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
             searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
             searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
             searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor)])

        NSLayoutConstraint.activate(
            [searchContainer.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
             searchContainer.widthAnchor.constraint(equalTo: tableView.widthAnchor),
             searchContainer.topAnchor.constraint(equalTo: tableView.topAnchor)])

        view.layoutIfNeeded()
    }
}

extension ConnectListViewController: Observer {
    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventSensorScanning else { return }

        switch event {
        case .deviceDiscovered(let device): deviceDiscovered(device)
        default: return
        }
    }

    func deviceDiscovered(_ device: DeviceViewModel) {
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

extension ConnectListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getInactiveDevicesFiltered(searchBar.text).count
    }
}

extension ConnectListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectTableViewCell",
                                                       for: indexPath) as? ConnectTableViewCell else {
            NSLog("Invalid reusable tableview cell in ConnectListViewController.")
            return UITableViewCell()
        }

        if let device = viewModel.getInactiveDevicesFiltered(searchBar.text)[safe: indexPath.item] {
            cell.setupView(serial: device.serial, name: device.name, rssi: device.rssi)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: {
            self.connectConstraint?.constant = -self.connectView.frame.height
            self.connectView.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if self.tableView.numberOfSections >= indexPath.section &&
               self.tableView.numberOfRows(inSection: indexPath.section) >= indexPath.row {
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        })
    }
}

extension ConnectListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
        connectView.alpha = 0.0
        connectConstraint?.constant = 0
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
}
