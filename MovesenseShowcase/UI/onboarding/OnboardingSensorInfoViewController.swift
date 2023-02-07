//
// OnboardingSensorInfoViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class OnboardingSensorInfoViewController: UIViewController {

    private let viewModel: SensorsSensorViewModel

    private let infoView: UIView

    private let serialLabel: UILabel
    private let nameLabel: UILabel

    private let energyLevelLabel: UILabel
    private let energyWarningLabel: UILabel

    private let sensorImageView: UIImageView

    private let appNameLabel: UILabel
    private let appVersionLabel: UILabel
    private let coreVersionLabel: UILabel

    private let closeButton: ActionButton

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init(viewModel: DeviceViewModel) {
        self.viewModel = SensorsSensorViewModel(viewModel)

        self.infoView = UIView()

        self.nameLabel = UILabel(with: UIFont.systemFont(ofSize: 12.0), inColor: UIColor.titleTextBlack,
                                 lines: 1, text: viewModel.name)
        self.serialLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                   lines: 1, text: viewModel.serial)

        self.energyLevelLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                        lines: 1, text: NSLocalizedString("CONNECT_INFO_BATTERY_LABEL", comment: "") + "..%")

        self.energyWarningLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 12.0), inColor: UIColor.warningText,
                                          lines: 1, text: NSLocalizedString("SENSORS_ENERGY_WARNING", comment: ""))

        self.sensorImageView = UIImageView(image: UIImage(named: "image_sensor"))

        self.appNameLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                    lines: 1, text: NSLocalizedString("CONNECT_INFO_APP_NAME_LABEL", comment: "") + "..")
        self.appVersionLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                       lines: 1, text: NSLocalizedString("CONNECT_INFO_APP_VERSION_LABEL", comment: "") + "..")
        self.coreVersionLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                        lines: 1, text: NSLocalizedString("CONNECT_INFO_CORE_VERSION_LABEL", comment: "") +
                                                        viewModel.swVersion)

        self.closeButton = ActionButton()
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen

        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)

        energyLevelLabel.isHidden = true
        energyWarningLabel.isHidden = true

        infoView.backgroundColor = UIColor.white
        infoView.layer.cornerRadius = 10.0

        sensorImageView.clipsToBounds = true
        sensorImageView.contentMode = .scaleAspectFit

        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.addObserver(self)

        viewModel.updateState(viewModel.deviceViewModel)

        layoutView()
    }

    @objc private func closeAction() {
        dismiss(animated: true)
    }

    private func updateVisualState() {
        switch viewModel.sensorState {
        case .connected: visualStateConnected()
        default: return
        }
    }

    private func visualStateConnected() {
        appNameLabel.text = NSLocalizedString("CONNECT_INFO_APP_NAME_LABEL", comment: "") + viewModel.appName
        appVersionLabel.text = NSLocalizedString("CONNECT_INFO_APP_VERSION_LABEL", comment: "") + viewModel.appVersion

        energyLevelLabel.text = viewModel.sensorEnergy
        energyLevelLabel.isHidden = false

        energyWarningLabel.isHidden = viewModel.isSensorEnergyLow == false
    }

    private func layoutView() {
        view.addSubview(infoView)

        infoView.addSubview(nameLabel)
        infoView.addSubview(serialLabel)
        infoView.addSubview(energyLevelLabel)
        infoView.addSubview(energyWarningLabel)
        infoView.addSubview(sensorImageView)
        infoView.addSubview(appNameLabel)
        infoView.addSubview(appVersionLabel)
        infoView.addSubview(coreVersionLabel)
        infoView.addSubview(closeButton)

        infoView.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        coreVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        serialLabel.translatesAutoresizingMaskIntoConstraints = false
        energyLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        energyWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        sensorImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             infoView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32.0),
             infoView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [serialLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16.0),
             serialLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 46.0)])

        NSLayoutConstraint.activate(
            [nameLabel.leadingAnchor.constraint(equalTo: serialLabel.leadingAnchor),
             nameLabel.topAnchor.constraint(equalTo: serialLabel.bottomAnchor, constant: 10.0)])

        NSLayoutConstraint.activate(
            [energyLevelLabel.leadingAnchor.constraint(greaterThanOrEqualTo: serialLabel.trailingAnchor),
             energyLevelLabel.topAnchor.constraint(equalTo: serialLabel.topAnchor),
             energyLevelLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [energyWarningLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor),
             energyWarningLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
             energyWarningLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16.0)])

        sensorImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate(
            [sensorImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32.0),
             sensorImageView.widthAnchor.constraint(lessThanOrEqualTo: infoView.widthAnchor, constant: -32.0),
             sensorImageView.heightAnchor.constraint(lessThanOrEqualTo: sensorImageView.widthAnchor),
             sensorImageView.centerXAnchor.constraint(equalTo: infoView.centerXAnchor)])

        NSLayoutConstraint.activate(
            [appNameLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16.0),
             appNameLabel.topAnchor.constraint(equalTo: sensorImageView.bottomAnchor, constant: 32.0),
             appNameLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor)])

        NSLayoutConstraint.activate(
            [appVersionLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16.0),
             appVersionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 6.0),
             appVersionLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor)])

        NSLayoutConstraint.activate(
            [coreVersionLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16.0),
             coreVersionLabel.topAnchor.constraint(equalTo: appVersionLabel.bottomAnchor, constant: 6.0),
             coreVersionLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor)])

        NSLayoutConstraint.activate(
            [closeButton.topAnchor.constraint(greaterThanOrEqualTo: coreVersionLabel.bottomAnchor, constant: 32.0),
             closeButton.centerXAnchor.constraint(equalTo: infoView.centerXAnchor),
             closeButton.widthAnchor.constraint(equalTo: infoView.widthAnchor, constant: -32.0),
             closeButton.heightAnchor.constraint(equalToConstant: 56.0),
             closeButton.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -46.0)])

        view.layoutIfNeeded()
    }
}

extension OnboardingSensorInfoViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let sensorEvent = event as? ObserverEventSensor else { return }

        switch sensorEvent {
        case .sensorChangedState: sensorChangedState()
        case .onError(let error): onError(error)
        }
    }

    private func sensorChangedState() {
        DispatchQueue.main.async { self.updateVisualState() }
    }

    private func onError(_ error: Error) {
        // TODO: Handle error
        DispatchQueue.main.async {}
    }
}
