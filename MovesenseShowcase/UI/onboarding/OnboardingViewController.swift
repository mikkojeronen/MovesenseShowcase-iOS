//
// OnboardingViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class OnboardingViewController: UIViewController {

    private enum Constants {
        static let labelAnimationDuration: TimeInterval = 0.5
        static let buttonBorderWidth: CGFloat = 1.0
        static let buttonCornerRadius: CGFloat = 5.0
        static let buttonShadowRadius: CGFloat = 2.0
        static let buttonShadowOpacity: Float = 0.2
        static let buttonShadowOffset: CGSize = CGSize(width: 1.0, height: 1.0)
        static let buttonTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 14.0)
    }

    fileprivate let viewModel: OnboardingViewModel

    private let actionButton: UIButton = UIButton(type: .system)
    private let backButton: UIButton = UIButton(type: .system)
    private let infoButton: UIButton = UIButton(type: .system)
    private let skipButton: UIButton = UIButton(type: .system)

    private let logoImageView: UIImageView
    private let wireframeImageView: UIImageView
    private let sensorImageView: UIImageView
    private let visualizationView: PulseVisualizationView

    private let labelContainer: UIView = UIView(frame: CGRect.zero)
    private let stateLabel: UILabel

    private let gradientLayer: CAGradientLayer = CAGradientLayer()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init() {
        self.viewModel = OnboardingViewModel()
        self.logoImageView = UIImageView(image: UIImage(named: "image_logo_movesense"))
        self.wireframeImageView = UIImageView(image: UIImage(named: "image_sensor_wireframe"))
        self.sensorImageView = UIImageView(image: UIImage(named: "image_sensor"))
        self.stateLabel = UILabel.init(with: UIFont.systemFont(ofSize: 16.0), inColor: .white,
                                       lines: 0)
        self.visualizationView = PulseVisualizationView(strokeColor: UIColor.white.withAlphaComponent(0.25),
                                                        fillColor: UIColor.white)

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true

        actionButton.setTitleColor(UIColor.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        actionButton.layer.borderColor = UIColor.white.cgColor
        actionButton.layer.borderWidth = Constants.buttonBorderWidth
        actionButton.layer.cornerRadius = Constants.buttonCornerRadius
        actionButton.layer.shadowRadius = Constants.buttonShadowRadius
        actionButton.layer.shadowColor = UIColor.black.cgColor
        actionButton.layer.shadowOffset = Constants.buttonShadowOffset
        actionButton.layer.shadowOpacity = Constants.buttonShadowOpacity

        backButton.tintColor = UIColor.white
        backButton.setImage(UIImage(named: "icon_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)

        infoButton.tintColor = UIColor.white
        infoButton.setImage(UIImage(named: "icon_info"), for: .normal)
        infoButton.addTarget(self, action: #selector(infoAction), for: .touchUpInside)

        skipButton.setTitle(NSLocalizedString("ONBOARDING_BUTTON_SKIP", comment: ""), for: .normal)
        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        skipButton.addTarget(self, action: #selector(skipAction), for: .touchUpInside)

        stateLabel.textAlignment = .center
        labelContainer.contentMode = .scaleAspectFit
        logoImageView.contentMode = .scaleAspectFit
        wireframeImageView.contentMode = .scaleAspectFit
        sensorImageView.contentMode = .scaleAspectFit

        gradientLayer.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)

        viewModel.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        changeVisualState(.disconnected)

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visualizationView.startPulseAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame = self.view.bounds
    }

    @objc private func connectAction() {
        navigationController?.pushViewController(ConnectListViewController(viewModel: viewModel), animated: true)
    }

    @objc private func backAction() {
        navigationController?.pushViewController(ConnectListViewController(viewModel: viewModel), animated: true)
        viewModel.getActiveDevices().forEach { viewModel.disconnectDevice($0.serial) }
    }

    @objc private func infoAction() {
        if let connectedDevice = viewModel.getConnectedDevices().first {
            present(OnboardingSensorInfoViewController(viewModel: connectedDevice), animated: true)
        }
    }

    @objc private func skipAction() {
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func startAction() {
        TabBarViewController.sharedInstance.selectedIndex = TabBarTabIds.dashboard
        navigationController?.popToRootViewController(animated: true)
    }

    private func changeVisualState(_ state: DeviceConnectionState, device: DeviceViewModel? = nil) {
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)

        switch state {
        case .disconnected:
            actionButton.setTitle(NSLocalizedString("ONBOARDING_BUTTON_CONNECT_A_SENSOR", comment: ""), for: .normal)
            actionButton.addTarget(self, action: #selector(connectAction), for: .touchUpInside)

            actionButton.alpha = 1.0
            logoImageView.alpha = 1.0
            backButton.alpha = 0.0
            infoButton.alpha = 0.0
            stateLabel.alpha = 0.0
            wireframeImageView.alpha = 0.0
            sensorImageView.alpha = 0.0

            actionButton.isUserInteractionEnabled = true
            backButton.isUserInteractionEnabled = false
            infoButton.isUserInteractionEnabled = false

            skipButton.isHidden = false

            visualizationView.startPulseAnimation()

        case .connecting:
            actionButton.alpha = 0.0
            actionButton.isUserInteractionEnabled = false

            backButton.alpha = 1.0
            backButton.isUserInteractionEnabled = true

            skipButton.isHidden = true

            stateLabel.alpha = 0.0
            stateLabel.text = NSLocalizedString("ONBOARDING_PLEASE_WAIT_CONNECTING", comment: "")

            UIView.animate(withDuration: Constants.labelAnimationDuration, animations: {
                self.stateLabel.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: Constants.labelAnimationDuration, animations: {
                    self.stateLabel.alpha = 0.0
                }, completion: { _ in
                    self.stateLabel.text = String(format: NSLocalizedString("ONBOARDING_CONNECTING_TO_SENSOR", comment: ""),
                                                  device?.serial ?? "n/a")
                    UIView.animate(withDuration: Constants.labelAnimationDuration, animations: {
                        self.stateLabel.alpha = 1.0
                        self.wireframeImageView.alpha = 1.0
                    }, completion: { completed in
                        if !completed {
                            self.stateLabel.alpha = 0.0
                        }
                    })
                })
            })

        case .connected:
            actionButton.setTitle(NSLocalizedString("ONBOARDING_BUTTON_START_TESTING", comment: ""), for: .normal)
            actionButton.addTarget(self, action: #selector(startAction), for: .touchUpInside)
            actionButton.isUserInteractionEnabled = true

            skipButton.isHidden = true

            visualizationView.stopPulseAnimation()

            UIView.animate(withDuration: Constants.labelAnimationDuration, animations: {
                self.stateLabel.alpha = 0.0
            }, completion: { _ in
                self.backButton.isUserInteractionEnabled = true
                self.infoButton.isUserInteractionEnabled = true
                self.stateLabel.text = String(format: NSLocalizedString("ONBOARDING_SENSOR_CONNECTED", comment: ""),
                                              device?.serial ?? "n/a")
                UIView.animate(withDuration: Constants.labelAnimationDuration, animations: {
                    self.stateLabel.alpha = 1.0
                    self.actionButton.alpha = 1.0
                    self.backButton.alpha = 1.0
                    self.infoButton.alpha = 1.0
                    self.wireframeImageView.alpha = 0.0
                    self.logoImageView.alpha = 0.0
                    self.sensorImageView.alpha = 1.0
                })
            })

        default: return
        }
    }

    private func layoutView() {
        view.addSubview(visualizationView)
        view.addSubview(logoImageView)
        view.addSubview(wireframeImageView)
        view.addSubview(sensorImageView)
        view.addSubview(labelContainer)
        view.addSubview(actionButton)
        view.addSubview(backButton)
        view.addSubview(infoButton)
        view.addSubview(skipButton)

        labelContainer.addSubview(stateLabel)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        wireframeImageView.translatesAutoresizingMaskIntoConstraints = false
        sensorImageView.translatesAutoresizingMaskIntoConstraints = false
        labelContainer.translatesAutoresizingMaskIntoConstraints = false
        visualizationView.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [skipButton.heightAnchor.constraint(equalToConstant: 44.0),
             skipButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36.0),
             skipButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [logoImageView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -114.0),
             logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             logoImageView.widthAnchor.constraint(equalToConstant: 142.0),
             logoImageView.heightAnchor.constraint(equalToConstant: 17.0)])

        NSLayoutConstraint.activate(
            [wireframeImageView.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
             wireframeImageView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
             wireframeImageView.widthAnchor.constraint(equalToConstant: 237.0),
             wireframeImageView.heightAnchor.constraint(equalToConstant: 237.0)])

        NSLayoutConstraint.activate(
            [sensorImageView.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
             sensorImageView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
             sensorImageView.widthAnchor.constraint(equalToConstant: 237.0),
             sensorImageView.heightAnchor.constraint(equalToConstant: 237.0)])

        NSLayoutConstraint.activate(
            [visualizationView.centerXAnchor.constraint(equalTo: logoImageView.centerXAnchor),
             visualizationView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
             visualizationView.widthAnchor.constraint(equalTo: view.widthAnchor),
             visualizationView.heightAnchor.constraint(equalTo: visualizationView.widthAnchor)])

        NSLayoutConstraint.activate(
            [labelContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             labelContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40.0)])

        NSLayoutConstraint.activate(
            [stateLabel.centerXAnchor.constraint(equalTo: labelContainer.centerXAnchor),
             stateLabel.widthAnchor.constraint(equalTo: labelContainer.widthAnchor),
             stateLabel.centerYAnchor.constraint(equalTo: labelContainer.centerYAnchor),
             stateLabel.heightAnchor.constraint(equalTo: labelContainer.heightAnchor)])

        NSLayoutConstraint.activate(
            [actionButton.topAnchor.constraint(equalTo: labelContainer.centerYAnchor, constant: 70.0),
             actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             actionButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40.0),
             actionButton.heightAnchor.constraint(equalToConstant: 56.0),
             actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [backButton.widthAnchor.constraint(equalToConstant: 44.0),
             backButton.heightAnchor.constraint(equalToConstant: 44.0),
             backButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40.0),
             backButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40.0)])

        NSLayoutConstraint.activate(
            [infoButton.widthAnchor.constraint(equalToConstant: 44.0),
             infoButton.heightAnchor.constraint(equalToConstant: 44.0),
             infoButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40.0),
             infoButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40.0)])

        view.layoutIfNeeded()
    }
}

extension OnboardingViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventOnboarding else { return }

        switch event {
        case .deviceDiscovered: return
        case .deviceStateChanged(let device): deviceStateChanged(device)
        case .onError(let error): onError(error)
        }
    }

    func deviceStateChanged(_ device: DeviceViewModel) {
        DispatchQueue.main.async {
            self.changeVisualState(device.state, device: device)
        }
    }

    // TODO: Display error info to user
    func onError(_ error: Error) {
        DispatchQueue.main.async {
            self.changeVisualState(.disconnected)
        }
    }
}
