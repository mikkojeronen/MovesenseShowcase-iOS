//
// SensorsTabViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class SensorsTabViewController: UIViewController {

    private let viewModel: SensorsViewModel

    private let scrollView: UIScrollView
    private let stackView: UIStackView
    private let noSensorsView: PlaceholderView

    private var sensorContainers: [SensorsSensorViewController] = []
    private var sensorListButton: UIBarButtonItem?

    init() {
        self.viewModel = SensorsViewModel()
        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.stackView = UIStackView(frame: CGRect.zero)
        self.noSensorsView = PlaceholderView(title: NSLocalizedString("SENSORS_NO_SENSORS_TITLE", comment: ""),
                                             actionTitle: NSLocalizedString("SENSORS_CONNECT_BUTTON_TITLE", comment: ""))

        super.init(nibName: nil, bundle: nil)

        sensorListButton = UIBarButtonItem(image: UIImage(named: "icon_plus"), style: .plain,
                                           target: self, action: #selector(sensorListActivity))

        noSensorsView.actionButton.addTarget(self, action: #selector(connectAction), for: .touchUpInside)

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10

        scrollView.backgroundColor = UIColor.tabPageBackground
        scrollView.showsVerticalScrollIndicator = false

        viewModel.addObserver(self)
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

        navigationItem.title = NSLocalizedString("SENSORS_NAV_TITLE", comment: "")
        navigationItem.rightBarButtonItem = sensorListButton

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)

        viewModel.resetDeviceStates()

        updateSensors()

        viewModel.startDevicesScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.stopDevicesScan()
    }

    @objc private func sensorListActivity() {
        navigationController?.pushViewController(ConnectListViewController(viewModel: OnboardingViewModel()), animated: true)
    }

    @objc private func connectAction() {
        navigationController?.pushViewController(ConnectListViewController(viewModel: OnboardingViewModel()), animated: true)
    }

    @objc private func applicationWillResignActive() {
        viewModel.resetDeviceStates()
        updateSensors()
    }

    @objc private func applicationDidBecomeActive() {
        viewModel.startDevicesScan()
    }

    private func updateSensors() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        children.forEach { $0.removeFromParent() }
        sensorContainers.removeAll()

        sensorContainers = viewModel.previousSensors.map { SensorsSensorViewController(viewModel: $0) }

        sensorContainers.forEach {
            addChild($0)
            $0.didMove(toParent: self)
        }

        if sensorContainers.isEmpty {
            noSensorsView.isHidden = false
            // Remove autolayout size ambiguity with scroll view
            stackView.addArrangedSubview(UIView(frame: CGRect.zero))
        } else {
            noSensorsView.isHidden = true
            sensorContainers.forEach { stackView.addArrangedSubview($0.view) }
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
             scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

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

extension SensorsTabViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? ObserverEventSensors else { return }

        switch event {
        case .sensorDiscovered: return
        case .sensorAdded(let sensor): sensorAdded(sensor)
        case .sensorRemoved(let sensor): sensorRemoved(sensor)
        case .onError(let error): onError(error)
        }
    }

    func sensorAdded(_ device: SensorsSensorViewModel) {
        DispatchQueue.main.async {
            self.updateSensors()
            // Sensors are inserted to the top, scroll there
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }

    func sensorRemoved(_ device: SensorsSensorViewModel) {
        DispatchQueue.main.async { self.updateSensors() }
    }

    func onError(_ error: Error) {
        // TODO: Display error info to user
    }
}
