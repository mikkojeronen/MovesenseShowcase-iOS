//
// DashboardTabViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardTabViewController: UIViewController {

    private let viewModel: DashboardViewModel

    private var startEditItem: UIBarButtonItem?
    private var endEditItem: UIBarButtonItem?

    private let scrollView: UIScrollView
    private let stackView: UIStackView
    private let noSensorsView: PlaceholderView

    private var containers: [DashboardContainerViewController]

    var dashboardViewModel: DashboardViewModel {
        return viewModel
    }

    init() {
        self.viewModel = DashboardViewModel()
        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.stackView = UIStackView(frame: CGRect.zero)
        self.noSensorsView = PlaceholderView(title: NSLocalizedString("DASHBOARD_NO_SENSORS_TITLE", comment: ""),
                                             actionTitle: NSLocalizedString("SENSORS_CONNECT_BUTTON_TITLE", comment: ""))

        self.containers = [DashboardContainerViewController]()

        super.init(nibName: nil, bundle: nil)

        // These can only be initialized after self has been constructed
        startEditItem = UIBarButtonItem(image: UIImage(named: "icon_edit"), style: .plain,
                                        target: self, action: #selector(startEditActivity))
        endEditItem = UIBarButtonItem(image: UIImage(named: "icon_cross"), style: .plain,
                                      target: self, action: #selector(endEditActivity))

        startEditItem?.tintColor = UIColor.black
        endEditItem?.tintColor = UIColor.black

        noSensorsView.actionButton.addTarget(self, action: #selector(connectAction), for: .touchUpInside)

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10

        scrollView.backgroundColor = UIColor.tabPageBackground
        scrollView.showsVerticalScrollIndicator = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateDashboard()

        viewModel.addObserver(self)

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("DASHBOARD_NAV_TITLE", comment: "")
        navigationItem.rightBarButtonItem = startEditItem

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (viewModel.isEnabledContainers == false) && viewModel.isActiveDevices {
            startEditActivity()
        } else {
            endEditActivity()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        defer {
            viewModel.isActivelyUsed = true
        }

        if viewModel.isActiveDevices || viewModel.isActivelyUsed { return }

        let buttonTitle = NSLocalizedString("DASHBOARD_WELCOME_BACK_BUTTON_TITLE", comment: "")
        let dismissTitle = NSLocalizedString("DASHBOARD_WELCOME_BACK_DISMISS_TITLE", comment: "")
        PopoverViewController.popoverAction(contentView: WelcomeBackView(),
                                            buttonTitle: buttonTitle,
                                            dismissTitle: dismissTitle) {
            self.connectAction()
        }
    }

    @objc private func connectAction() {
        TabBarViewController.sharedInstance.selectedIndex = TabBarTabIds.sensors
        TabBarViewController.sharedInstance.tabNavigationControllers[safe: TabBarTabIds.sensors]??
            .pushViewController(ConnectListViewController(viewModel: OnboardingViewModel()), animated: true)
    }

    @objc private func startEditActivity() {
        viewModel.isEditMode = true

        containers.forEach { $0.view.isHidden = false }

        navigationItem.setLeftBarButton(endEditItem, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)
    }

    @objc private func endEditActivity() {
        viewModel.isEditMode = false

        // Split devices according to the serial number
        let deviceSplit: [String: [DashboardContainerViewController]] = containers.reduce(into: [:]) { results, container in
            results[container.viewModel.serial, default: [DashboardContainerViewController]()].append(container)
        }

        // If a resource is enabled for a device, display only that, otherwise list all
        deviceSplit.forEach { (_, deviceContainers) in
            if (deviceContainers.contains { $0.viewModel.isEnabled == true }) {
                deviceContainers.forEach { $0.view.isHidden = $0.viewModel.isEnabled == false }
            } else {
                deviceContainers.forEach { $0.view.isHidden = false }
            }
        }

        navigationItem.setRightBarButton(startEditItem, animated: true)
        navigationItem.setLeftBarButton(nil, animated: true)

        navigationItem.title = NSLocalizedString("DASHBOARD_NAV_TITLE", comment: "")
    }

    private func updateDashboard() {
        containers.removeAll { container in
            if (viewModel.containers.contains { $0 == container.viewModel } == false) {
                container.view.removeFromSuperview()
                container.removeFromParent()
                return true
            }

            return false
        }

        viewModel.containers.forEach { viewModel in
            if (containers.contains { $0.viewModel == viewModel } == false) {
                let container = DashboardContainerViewController(viewModel: viewModel)
                containers.append(container)
                addChild(container)
                container.didMove(toParent: self)
                stackView.addArrangedSubview(container.view)
            }
        }

        if containers.isEmpty {
            noSensorsView.isHidden = false
            endEditActivity()
            startEditItem?.isEnabled = false
        } else {
            noSensorsView.isHidden = true
            startEditActivity()
            startEditItem?.isEnabled = true
        }

        view.layoutIfNeeded()
    }

    private func layoutView() {
        view.addSubview(scrollView)
        view.addSubview(noSensorsView)
        scrollView.addSubview(stackView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        noSensorsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
             stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
             stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10.0),
             stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
             stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [noSensorsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             noSensorsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             noSensorsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             noSensorsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension DashboardTabViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventDashboard else { return }

        switch event {
        case .dashboardUpdated: dashboardUpdate()
        case .dashboardError(let error): onError(error)
        }
    }

    func dashboardUpdate() {
        DispatchQueue.main.async { self.updateDashboard() }
    }

    func onError(_ error: Error) {
    }
}
