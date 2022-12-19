//
// TabBarViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

enum TabBarTabIds {
    static let sensors: Int = 0
    static let dashboard: Int = 1
    static let record: Int = 2
    static let recordings: Int = 3
    static let more: Int = 4
}

class TabBarViewController: UITabBarController {

    private let dashboardTab: DashboardTabViewController = DashboardTabViewController()
    private let sensorsTab: SensorsTabViewController = SensorsTabViewController()
    private let recordTab: UIViewController = UIViewController()
    private let recordingsTab: RecordingsTabViewController = RecordingsTabViewController()
    private let moreTab: MoreViewController = MoreViewController()

    static let sharedInstance: TabBarViewController = TabBarViewController()

    var tabNavigationControllers: [UINavigationController?] {
        guard let viewControllers = viewControllers else { return [] }
        return viewControllers.map { $0 as? UINavigationController }
    }

    var isActiveOperations: Bool {
        return dashboardTab.dashboardViewModel.containers.contains { $0.isOperation }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private init() {
        super.init(nibName: nil, bundle: nil)

        tabBar.tintColor = UIColor.tabTint
        tabBar.barTintColor = UIColor.tabBarTint
        tabBar.isTranslucent = false

        delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let dashboardTabTitle = NSLocalizedString("DASHBOARD_TAB_TITLE", comment: "")
        dashboardTab.tabBarItem = UITabBarItem(title: dashboardTabTitle, image: UIImage(named: "icon_dashboard_tab"), tag: 0)

        let sensorsTabTitle = NSLocalizedString("SENSORS_TAB_TITLE", comment: "")
        sensorsTab.tabBarItem = UITabBarItem(title: sensorsTabTitle, image: UIImage(named: "icon_sensors_tab"), tag: 1)

        let recordTabTitle = NSLocalizedString("RECORD_TAB_TITLE", comment: "")
        recordTab.tabBarItem = UITabBarItem(title: recordTabTitle, image: UIImage(named: "icon_record_tab"), tag: 2)

        let recordingsTabTitle = NSLocalizedString("RECORDINGS_TAB_TITLE", comment: "")
        recordingsTab.tabBarItem = UITabBarItem(title: recordingsTabTitle, image: UIImage(named: "icon_records_tab"), tag: 3)

        let moreTabTitle = NSLocalizedString("MORE_TAB_TITLE", comment: "")
        moreTab.tabBarItem = UITabBarItem(title: moreTabTitle, image: UIImage(named: "icon_more_tab"), tag: 4)

        let controllers = [sensorsTab, dashboardTab, recordTab, recordingsTab, moreTab]
        viewControllers = controllers.map { UINavigationController(rootViewController: $0) }

        selectedIndex = 0

        customizableViewControllers = nil

        Movesense.api.addObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        updateButtonState()
    }

    private func updateButtonState() {
        DispatchQueue.main.async {
            self.recordTab.tabBarItem.isEnabled = self.isActiveOperations
        }
    }
}

extension TabBarViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let navigationController = viewController as? UINavigationController,
              let viewController = navigationController.viewControllers.first else { return false }

        if viewController === recordTab {
            let viewModel = dashboardTab.dashboardViewModel
            let recordViewController = RecordViewController(viewModel: viewModel)
            present(UINavigationController(rootViewController: recordViewController), animated: true)
            return false
        }

        return true
    }
}

extension TabBarViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let event as MovesenseObserverEventApi: handleEventApi(event)
        case let event as MovesenseObserverEventOperation: handleEventOperation(event)
        default: return
        }
    }

    private func handleEventApi(_ event: MovesenseObserverEventApi) {
        switch event {
        case .apiDeviceDiscovered, .apiDeviceConnecting: return
        case .apiDeviceConnected, .apiDeviceDisconnected, .apiError: updateButtonState()
        case .apiDeviceOperationInitiated(_, let operation): handleOperationInit(operation)
        }
    }

    private func handleOperationInit(_ operation: MovesenseOperation?) {
        guard let operation = operation else { return }

        switch operation.operationRequest.method {
        case .subscribe: operation.addObserver(self)
        default: return
        }
    }

    private func handleEventOperation(_ event: MovesenseObserverEventOperation) {
        switch event {
        case .operationEvent: return
        case .operationResponse: updateButtonState()
        case .operationFinished: updateButtonState()
        case .operationError: updateButtonState()
        }
    }
}
