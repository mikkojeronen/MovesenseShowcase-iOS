//
// DfuViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi
import MovesenseDfu

class DfuViewController: UIViewController {

    private let viewModel: DfuViewModel

    private let scrollView: UIScrollView
    private let stackView: UIStackView

    private let reconnectView: UIView
    private let reconnectLabel: UILabel
    private let reconnectIndicator: UIActivityIndicatorView

    private var dismissBarButtonItem: UIBarButtonItem?

    private let currentFirmwareTitleLabel: UILabel

    private let appNameProperty: DfuPropertyView
    private let appVersionProperty: DfuPropertyView
    private let coreVersionProperty: DfuPropertyView

    private let updateFirmwareTitleLabel: UILabel
    private let selectFirmwareButton: UIButton
    private let resetFirmwareButton: UIButton

    private let instructionsTitleLabel: UILabel
    private let instructionsView: UIView
    private let instructionsLabel: UILabel
    private let instructionsButton: UIButton

    init(sensorViewModel: SensorsSensorViewModel) {
        self.viewModel = DfuViewModel(sensorViewModel: sensorViewModel)

        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.stackView = UIStackView(frame: CGRect.zero)

        self.reconnectView = UIView(frame: CGRect.zero)
        self.reconnectLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0, weight: .regular),
                                      inColor: UIColor.white, lines: 1,
                                      text: NSLocalizedString("DFU_RECONNECT_TITLE", comment: ""))
        self.reconnectIndicator = UIActivityIndicatorView(style: .whiteLarge)

        self.currentFirmwareTitleLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                                 inColor: UIColor.titleTextBlack.withAlphaComponent(0.6), lines: 1,
                                                 text: NSLocalizedString("DFU_CURRENT_FIRMWARE_TITLE", comment: ""))

        self.appNameProperty = DfuPropertyView(key: NSLocalizedString("DFU_APP_NAME_TITLE",
                                                                      comment: ""),
                                               value: sensorViewModel.appName)

        self.appVersionProperty = DfuPropertyView(key: NSLocalizedString("DFU_APP_VERSION_TITLE",
                                                                         comment: ""),
                                                  value: sensorViewModel.appVersion)

        self.coreVersionProperty = DfuPropertyView(key: NSLocalizedString("DFU_CORE_VERSION_TITLE",
                                                                          comment: ""),
                                                   value: sensorViewModel.deviceViewModel.swVersion)

        self.updateFirmwareTitleLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                                inColor: UIColor.titleTextBlack.withAlphaComponent(0.6), lines: 1,
                                                text: NSLocalizedString("DFU_FIRMWARE_TITLE", comment: ""))

        self.selectFirmwareButton = UIButton(type: .roundedRect)
        self.resetFirmwareButton = UIButton(type: .roundedRect)

        self.instructionsTitleLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                              inColor: UIColor.titleTextBlack.withAlphaComponent(0.6), lines: 1,
                                              text: NSLocalizedString("DFU_INSTRUCTIONS_TITLE", comment: ""))

        self.instructionsView = UIView(frame: CGRect.zero)
        self.instructionsLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                                         inColor: UIColor.titleTextBlack, lines: 1,
                                         text: NSLocalizedString("DFU_INSTRUCTIONS_HOWTO_TITLE", comment: ""))
        self.instructionsButton = UIButton(type: .roundedRect)

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0

        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false

        reconnectView.isHidden = true
        reconnectView.isUserInteractionEnabled = true
        reconnectView.backgroundColor = UIColor.gray.withAlphaComponent(0.8)

        reconnectLabel.textAlignment = .center

        dismissBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_cross"), style: .plain,
                                               target: self, action: #selector(dismissAction))
        dismissBarButtonItem?.tintColor = .black

        selectFirmwareButton.setTitle(NSLocalizedString("DFU_UPDATE_FIRMWARE_TITLE", comment: ""), for: .normal)
        selectFirmwareButton.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        selectFirmwareButton.contentHorizontalAlignment = .left

        resetFirmwareButton.setTitle(NSLocalizedString("DFU_RESET_TITLE", comment: ""), for: .normal)
        resetFirmwareButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        resetFirmwareButton.contentHorizontalAlignment = .left

        instructionsButton.setImage(UIImage(named: "icon_arrow_right"), for: .normal)
        instructionsButton.tintColor = UIColor.titleTextBlack

        instructionsView.isUserInteractionEnabled = true
        instructionsView.addTapGesture(tapNumber: 1, target: self, action: #selector(instructionsAction))

        sensorViewModel.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("DFU_NAV_TITLE", comment: "")

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        stackView.addArrangedSubview(currentFirmwareTitleLabel)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 8.0, bottom: -16.0))
        stackView.addArrangedSubview(appNameProperty)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 16.0, bottom: -16.0))
        stackView.addArrangedSubview(appVersionProperty)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 16.0, bottom: -16.0))
        stackView.addArrangedSubview(coreVersionProperty)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 16.0, bottom: -32.0))
        stackView.addArrangedSubview(updateFirmwareTitleLabel)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 8.0, bottom: -16.0))
        stackView.addArrangedSubview(selectFirmwareButton)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 16.0, bottom: -16.0))
        stackView.addArrangedSubview(resetFirmwareButton)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 16.0, bottom: -32.0))
        stackView.addArrangedSubview(instructionsTitleLabel)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 8.0, bottom: -16.0))
        stackView.addArrangedSubview(instructionsView)
        stackView.addArrangedSubview(UIView.separator(color: .separatorGray, top: 16.0, bottom: -16.0))

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationItem.setLeftBarButton(dismissBarButtonItem, animated: false)

        if let sensorViewModel = viewModel.sensorViewModel {
            updateVisualState(sensorViewModel.deviceViewModel.state)
            sensorViewModel.stateAction(state: .discovered)
        }
    }

    @objc private func dismissAction() {
        dismiss(animated: true)
    }

    @objc private func selectAction() {
        navigationController?.pushViewController(DfuSelectViewController(viewModel: viewModel), animated: true)
    }

    @objc private func resetAction() {
        let title = NSLocalizedString("DFU_RESET_CONFIRMATION_TITLE", comment: "")
        let text = NSLocalizedString("DFU_RESET_CONFIRMATION_TEXT", comment: "")
        let buttonTitle = NSLocalizedString("DFU_RESET_BUTTON_TITLE", comment: "")
        let cancelTitle = NSLocalizedString("DFU_RESET_CANCEL_TITLE", comment: "")

        let contentView = ConfirmationView(title: title, text: text, image: UIImage(named: "image_dfu_reset"))

        PopoverViewController.popoverAction(contentView: contentView,
                                            buttonTitle: buttonTitle,
                                            dismissTitle: cancelTitle) { [viewModel] in
            guard let sensorSerial = viewModel.sensorViewModel?.sensorSerial else { return }

            self.viewModel.requestDfuMode(sensorSerial)
            self.viewModel.selectedPackage = viewModel.getBundledDfuPackages().first

            self.present(UINavigationController(rootViewController: DfuTargListViewController(viewModel: viewModel)),
                         animated: true)
        }
    }

    @objc private func instructionsAction() {
        navigationController?.pushViewController(DfuHowToViewController(), animated: true)
    }

    private func updateVisualState(_ state: DeviceConnectionState) {
        switch state {
        case .disconnected: visualStateDisconnected()
        case .discovered: visualStateConnecting()
        case .connecting: visualStateConnecting()
        case .connected: visualStateConnected()
        }
    }

    private func visualStateDisconnected() {
        appNameProperty.isEnabled = false
        appVersionProperty.isEnabled = false
        coreVersionProperty.isEnabled = false

        reconnectIndicator.stopAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            self.reconnectView.alpha = 0.0
        }, completion: { _ in
            self.reconnectView.isHidden = true
        })
    }

    private func visualStateConnecting() {
        appNameProperty.isEnabled = false
        appVersionProperty.isEnabled = false
        coreVersionProperty.isEnabled = false

        reconnectIndicator.startAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            self.reconnectView.alpha = 1.0
        }, completion: { _ in
            self.reconnectView.isHidden = false
        })
    }

    private func visualStateConnected() {
        guard let sensorViewModel = viewModel.sensorViewModel else { return }

        appNameProperty.value = sensorViewModel.appName
        appVersionProperty.value = sensorViewModel.appVersion
        coreVersionProperty.value = sensorViewModel.deviceViewModel.swVersion

        appNameProperty.isEnabled = true
        appVersionProperty.isEnabled = true
        coreVersionProperty.isEnabled = true

        reconnectIndicator.stopAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            self.reconnectView.alpha = 0.0
        }, completion: { _ in
            self.reconnectView.isHidden = true
        })
    }

    private func layoutView() {
        view.addSubview(scrollView)
        view.addSubview(reconnectView)

        scrollView.addSubview(stackView)

        reconnectView.addSubview(reconnectLabel)
        reconnectView.addSubview(reconnectIndicator)

        instructionsView.addSubview(instructionsLabel)
        instructionsView.addSubview(instructionsButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        reconnectView.translatesAutoresizingMaskIntoConstraints = false
        reconnectLabel.translatesAutoresizingMaskIntoConstraints = false
        reconnectIndicator.translatesAutoresizingMaskIntoConstraints = false
        instructionsView.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        NSLayoutConstraint.activate(
            [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
             stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
             stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32.0),
             stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
             stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [reconnectView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             reconnectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             reconnectView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             reconnectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [reconnectLabel.centerXAnchor.constraint(equalTo: reconnectIndicator.centerXAnchor),
             reconnectLabel.bottomAnchor.constraint(equalTo: reconnectIndicator.topAnchor, constant: -16.0),
             reconnectLabel.widthAnchor.constraint(equalTo: reconnectView.widthAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [reconnectIndicator.centerXAnchor.constraint(equalTo: reconnectView.centerXAnchor),
             reconnectIndicator.centerYAnchor.constraint(equalTo: reconnectView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [instructionsLabel.leadingAnchor.constraint(equalTo: instructionsView.leadingAnchor),
             instructionsLabel.topAnchor.constraint(equalTo: instructionsView.topAnchor),
             instructionsLabel.bottomAnchor.constraint(equalTo: instructionsView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [instructionsButton.leadingAnchor.constraint(greaterThanOrEqualTo: instructionsLabel.trailingAnchor),
             instructionsButton.topAnchor.constraint(equalTo: instructionsView.topAnchor),
             instructionsButton.trailingAnchor.constraint(equalTo: instructionsView.trailingAnchor, constant: -16.0),
             instructionsButton.bottomAnchor.constraint(equalTo: instructionsView.bottomAnchor)])
    }
}

extension DfuViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let sensorEvent = event as? ObserverEventSensor else { return }

        switch sensorEvent {
        case .sensorChangedState(let state): sensorChangedState(state)
        case .onError(let error): onError(error)
        }
    }

    private func sensorChangedState(_ state: DeviceConnectionState) {
        DispatchQueue.main.async { self.updateVisualState(state) }
    }

    // TODO: Handle error
    private func onError(_ error: Error) {}
}
