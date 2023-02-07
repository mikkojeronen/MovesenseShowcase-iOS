//
// SensorsSensorViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class SensorsSensorViewController: UIViewController {

    private let viewModel: SensorsSensorViewModel

    private let sensorContainer: UIView
    private let actionStackView: UIStackView

    private let titleLabel: UILabel
    private let serialLabel: UILabel

    private let energyLevelLabel: UILabel
    private let energyWarningLabel: UILabel

    private let forgetButton: UIButton

    private let sensorInfoView: SensorsSensorInfoView
    private let actionView: UIView
    private let actionLabel: UILabel
    private let actionSeparator: UIView

    private let dfuView: UIView
    private let dfuLabel: UILabel
    private let dfuButton: UIButton

    private let sensorConnectedImageView: UIImageView
    private let sensorDisconnectedImageView: UIImageView
    private let sensorPulseView: PulseVisualizationView

    init(viewModel: SensorsSensorViewModel) {
        self.viewModel = viewModel
        self.sensorContainer = UIView(frame: CGRect.zero)
        self.titleLabel = UILabel(with: UIFont.systemFont(ofSize: 12.0), inColor: UIColor.titleTextBlack,
                                  lines: 1, text: viewModel.sensorName)
        self.serialLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                   lines: 1, text: viewModel.sensorSerial)

        self.forgetButton = UIButton(type: .system)

        self.energyLevelLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                        lines: 1, text: viewModel.sensorEnergy)
        self.energyWarningLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 12.0), inColor: UIColor.warningText,
                                          lines: 1, text: NSLocalizedString("SENSORS_ENERGY_WARNING", comment: ""))

        self.actionView = UIView()
        self.actionLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.lightGray,
                                   lines: 1, text: viewModel.stateActionName)

        self.dfuView = UIView()
        self.dfuLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0), inColor: UIColor.titleTextBlack,
                                lines: 1, text: NSLocalizedString("SENSORS_ACTION_DFU", comment: ""))
        self.dfuButton = UIButton(type: .roundedRect)

        self.actionSeparator = UIView.separator(color: .separatorGray)

        self.sensorInfoView = SensorsSensorInfoView(viewModel: viewModel)
        self.actionStackView = UIStackView(frame: CGRect.zero)

        self.sensorConnectedImageView = UIImageView(image: UIImage(named: "image_sensor"))
        self.sensorDisconnectedImageView = UIImageView(image: UIImage(named: "image_sensor_wireframe_dark"))
        self.sensorPulseView = PulseVisualizationView(strokeColor: UIColor.gradientStart.withAlphaComponent(0.5),
                                                      fillColor: UIColor.white)

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        actionStackView.axis = .vertical
        actionStackView.distribution = .equalSpacing
        actionStackView.alignment = .fill
        actionStackView.spacing = 0

        actionLabel.isEnabled = false
        actionLabel.textColor = .blue
        actionLabel.isUserInteractionEnabled = true
        actionLabel.addTapGesture(tapNumber: 1, cancelTouches: true, target: self,
                                  action: #selector(stateAction))

        dfuView.isUserInteractionEnabled = true
        dfuView.addTapGesture(tapNumber: 1, cancelTouches: true, target: self,
                              action: #selector(dfuAction))

        dfuButton.isUserInteractionEnabled = false
        dfuButton.setImage(UIImage(named: "icon_arrow_right"), for: .normal)
        dfuButton.tintColor = UIColor.titleTextBlack

        forgetButton.isUserInteractionEnabled = true
        forgetButton.setImage(UIImage(named: "icon_cross"), for: .normal)
        forgetButton.tintColor = UIColor.titleTextBlack
        forgetButton.addTarget(self, action: #selector(forgetAction), for: .touchUpInside)

        energyLevelLabel.isHidden = true
        energyWarningLabel.isHidden = true
        serialLabel.isEnabled = false
        titleLabel.isEnabled = false

        sensorConnectedImageView.alpha = 0.0
        sensorConnectedImageView.contentMode = .scaleAspectFit

        sensorDisconnectedImageView.alpha = 1.0
        sensorDisconnectedImageView.contentMode = .scaleAspectFit

        viewModel.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        actionStackView.addArrangedSubview(sensorInfoView)
        actionStackView.addArrangedSubview(UIView.separator(color: .separatorGray, trailing: 16.0))
        actionStackView.addArrangedSubview(dfuView)
        actionStackView.addArrangedSubview(UIView.separator(color: .separatorGray, trailing: 16.0))

        actionStackView.arrangedSubviews.forEach { $0.isHidden = true }

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateVisualState()
    }

    @objc private func stateAction() {
        let sensorState = viewModel.sensorState

        if sensorState != .connected {
            viewModel.stateAction(state: sensorState)
            return
        }

        let title = NSLocalizedString("SENSORS_ACTION_DISCONNECT_CONFIRMATION_TITLE", comment: "") + viewModel.sensorSerial
        let buttonTitle = NSLocalizedString("SENSORS_ACTION_CONFIRMATION_TITLE", comment: "")
        let cancelTitle = NSLocalizedString("SENSORS_ACTION_CANCEL_TITLE", comment: "")

        PopoverViewController.popoverAction(contentView: ConfirmationView(title: title,
                                                                          image: UIImage(named: "image_movesense_symbol")),
                                            buttonTitle: buttonTitle,
                                            dismissTitle: cancelTitle) { [sensorState] in
            self.viewModel.stateAction(state: sensorState)
        }
    }

    @objc private func forgetAction() {
        let title = NSLocalizedString("SENSORS_ACTION_FORGET_CONFIRMATION_TITLE", comment: "") + viewModel.sensorSerial
        let buttonTitle = NSLocalizedString("SENSORS_ACTION_CONFIRMATION_TITLE", comment: "")

        PopoverViewController.popoverAction(contentView: ConfirmationView(title: title,
                                                                          image: UIImage(named: "image_movesense_symbol")),
                                            buttonTitle: buttonTitle,
                                            dismissTitle: "Cancel") {
            self.viewModel.forgetAction(self)
        }
    }

    @objc private func dfuAction() {
        let dfuNavigationController = UINavigationController(rootViewController: DfuViewController(sensorViewModel: viewModel))
        dfuNavigationController.transitioningDelegate = self
        present(dfuNavigationController, animated: true)
    }

    private func updateVisualState() {
        actionLabel.text = viewModel.stateActionName

        switch viewModel.sensorState {
        case .disconnected: visualStateDisconnected()
        case .discovered: visualStateDiscovered()
        case .connecting: visualStateConnecting()
        case .connected: visualStateConnected()
        }
    }

    private func visualStateDisconnected() {
        sensorPulseView.stopPulseAnimation()

        serialLabel.isEnabled = false
        titleLabel.isEnabled = false

        energyLevelLabel.isHidden = true
        energyWarningLabel.isHidden = true

        forgetButton.isHidden = false
        actionLabel.isEnabled = false

        sensorInfoView.updateInfo(viewModel: viewModel)

        UIView.animate(withDuration: 0.5) {
            self.sensorConnectedImageView.alpha = 0.0
            self.sensorDisconnectedImageView.alpha = 1.0
        }

        self.actionStackView.arrangedSubviews.forEach { $0.isHidden = true }
    }

    private func visualStateDiscovered() {
        sensorPulseView.stopPulseAnimation()

        serialLabel.isEnabled = false
        titleLabel.isEnabled = false

        energyLevelLabel.isHidden = true
        energyWarningLabel.isHidden = true

        forgetButton.isHidden = false
        actionLabel.isEnabled = true

        sensorInfoView.updateInfo(viewModel: viewModel)

        UIView.animate(withDuration: 0.5) {
            self.sensorConnectedImageView.alpha = 0.0
            self.sensorDisconnectedImageView.alpha = 1.0
        }
    }

    private func visualStateConnecting() {
        sensorPulseView.startPulseAnimation()

        serialLabel.isEnabled = false
        titleLabel.isEnabled = false

        energyLevelLabel.isHidden = true
        energyWarningLabel.isHidden = true

        forgetButton.isHidden = true
        actionLabel.isEnabled = true
    }

    private func visualStateConnected() {
        sensorPulseView.stopPulseAnimation()

        serialLabel.isEnabled = true
        titleLabel.isEnabled = true

        energyLevelLabel.text = viewModel.sensorEnergy
        energyLevelLabel.isHidden = false

        energyWarningLabel.isHidden = viewModel.isSensorEnergyLow == false

        forgetButton.isHidden = true
        actionLabel.isEnabled = true

        sensorInfoView.updateInfo(viewModel: viewModel)

        UIView.animate(withDuration: 0.5) {
            self.sensorConnectedImageView.alpha = 1.0
            self.sensorDisconnectedImageView.alpha = 0.0
            self.actionStackView.arrangedSubviews.forEach { $0.isHidden = false }
        }
    }

    private func layoutView() {
        view.addSubview(sensorContainer)
        view.addSubview(actionStackView)
        view.addSubview(actionSeparator)
        view.addSubview(actionView)

        actionView.addSubview(actionLabel)

        sensorContainer.addSubview(titleLabel)
        sensorContainer.addSubview(serialLabel)
        sensorContainer.addSubview(forgetButton)
        sensorContainer.addSubview(energyLevelLabel)
        sensorContainer.addSubview(energyWarningLabel)
        sensorContainer.addSubview(sensorConnectedImageView)
        sensorContainer.addSubview(sensorDisconnectedImageView)
        sensorContainer.addSubview(sensorPulseView)

        dfuView.addSubview(dfuLabel)
        dfuView.addSubview(dfuButton)

        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionSeparator.translatesAutoresizingMaskIntoConstraints = false
        sensorContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        serialLabel.translatesAutoresizingMaskIntoConstraints = false
        forgetButton.translatesAutoresizingMaskIntoConstraints = false
        energyLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        energyWarningLabel.translatesAutoresizingMaskIntoConstraints = false
        sensorConnectedImageView.translatesAutoresizingMaskIntoConstraints = false
        sensorDisconnectedImageView.translatesAutoresizingMaskIntoConstraints = false
        sensorPulseView.translatesAutoresizingMaskIntoConstraints = false
        dfuView.translatesAutoresizingMaskIntoConstraints = false
        dfuLabel.translatesAutoresizingMaskIntoConstraints = false
        dfuButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [sensorContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             sensorContainer.topAnchor.constraint(equalTo: view.topAnchor),
             sensorContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [serialLabel.leadingAnchor.constraint(equalTo: sensorContainer.leadingAnchor),
             serialLabel.topAnchor.constraint(equalTo: sensorContainer.topAnchor, constant: 16.0)])

        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: serialLabel.leadingAnchor),
             titleLabel.topAnchor.constraint(equalTo: serialLabel.bottomAnchor, constant: 10.0)])

        NSLayoutConstraint.activate(
            [forgetButton.widthAnchor.constraint(equalToConstant: 44.0),
             forgetButton.heightAnchor.constraint(equalToConstant: 44.0),
             forgetButton.centerYAnchor.constraint(equalTo: serialLabel.centerYAnchor),
             forgetButton.centerXAnchor.constraint(equalTo: sensorContainer.trailingAnchor, constant: -9.0)])

        NSLayoutConstraint.activate(
            [energyLevelLabel.leadingAnchor.constraint(greaterThanOrEqualTo: serialLabel.trailingAnchor),
             energyLevelLabel.topAnchor.constraint(equalTo: serialLabel.topAnchor),
             energyLevelLabel.trailingAnchor.constraint(equalTo: sensorContainer.trailingAnchor)])

        NSLayoutConstraint.activate(
            [energyWarningLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
             energyWarningLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
             energyWarningLabel.trailingAnchor.constraint(equalTo: sensorContainer.trailingAnchor)])

        NSLayoutConstraint.activate(
            [sensorConnectedImageView.centerXAnchor.constraint(equalTo: sensorContainer.centerXAnchor),
             sensorConnectedImageView.widthAnchor.constraint(equalTo: sensorContainer.widthAnchor, constant: -140.0),
             sensorConnectedImageView.heightAnchor.constraint(equalTo: sensorConnectedImageView.widthAnchor),
             sensorConnectedImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0),
             sensorConnectedImageView.bottomAnchor.constraint(equalTo: sensorContainer.bottomAnchor)])

        NSLayoutConstraint.activate(
            [sensorDisconnectedImageView.centerXAnchor.constraint(equalTo: sensorContainer.centerXAnchor),
             sensorDisconnectedImageView.widthAnchor.constraint(equalTo: sensorContainer.widthAnchor, constant: -140.0),
             sensorDisconnectedImageView.heightAnchor.constraint(equalTo: sensorDisconnectedImageView.widthAnchor),
             sensorDisconnectedImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0),
             sensorDisconnectedImageView.bottomAnchor.constraint(equalTo: sensorContainer.bottomAnchor)])

        NSLayoutConstraint.activate(
            [sensorPulseView.centerXAnchor.constraint(equalTo: sensorDisconnectedImageView.centerXAnchor),
             sensorPulseView.centerYAnchor.constraint(equalTo: sensorDisconnectedImageView.centerYAnchor),
             sensorPulseView.widthAnchor.constraint(equalTo: sensorDisconnectedImageView.widthAnchor),
             sensorPulseView.heightAnchor.constraint(equalTo: sensorDisconnectedImageView.heightAnchor)])

        NSLayoutConstraint.activate(
            [actionStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             actionStackView.topAnchor.constraint(equalTo: sensorContainer.bottomAnchor, constant: 16.0),
             actionStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)])

        NSLayoutConstraint.activate(
            [actionSeparator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             actionSeparator.topAnchor.constraint(equalTo: sensorContainer.bottomAnchor, constant: 16.0),
             actionSeparator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16.0)])

        NSLayoutConstraint.activate(
            [actionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             actionView.topAnchor.constraint(equalTo: actionStackView.bottomAnchor),
             actionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
             actionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [actionLabel.leadingAnchor.constraint(equalTo: actionView.leadingAnchor),
             actionLabel.topAnchor.constraint(equalTo: actionView.topAnchor),
             actionLabel.bottomAnchor.constraint(equalTo: actionView.bottomAnchor),
             actionLabel.heightAnchor.constraint(equalToConstant: 44.0)])

        NSLayoutConstraint.activate(
            [dfuView.heightAnchor.constraint(equalToConstant: 44.0)])

        NSLayoutConstraint.activate(
            [dfuLabel.leadingAnchor.constraint(equalTo: dfuView.leadingAnchor),
             dfuLabel.topAnchor.constraint(equalTo: dfuView.topAnchor),
             dfuLabel.bottomAnchor.constraint(equalTo: dfuView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [dfuButton.leadingAnchor.constraint(greaterThanOrEqualTo: dfuLabel.trailingAnchor),
             dfuButton.centerYAnchor.constraint(equalTo: dfuLabel.centerYAnchor),
             dfuButton.trailingAnchor.constraint(equalTo: dfuView.trailingAnchor, constant: -19.0)])

        view.layoutIfNeeded()
    }
}

extension SensorsSensorViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HorizontalModalSlideAnimator()
    }
}

extension SensorsSensorViewController: Observer {

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
