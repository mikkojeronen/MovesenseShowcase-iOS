//
// RecordViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class RecordViewController: UIViewController {

    private let viewModel: DashboardViewModel

    private let recordButton: UIButton
    private let recordLabel: UILabel
    private let recordTimerLabel: UILabel
    private let recordCountLabel: UILabel
    private let recordView: UIView
    private let recordContainer: UIView
    private let recordViewGradientLayer: CAGradientLayer
    private let recordPulseView: PulseVisualizationView
    private let recordDurationFormatter: DateComponentsFormatter
    private let scrollView: UIScrollView
    private let stackView: UIStackView

    private var containers: [DashboardContainerViewController]
    private var dismissItem: UIBarButtonItem?

    private var recordingStartDate: Date?
    private var recordingTimer: Timer?
    private var recordingSessionCount: Int = 1

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        self.recordButton = UIButton(frame: CGRect.zero)
        self.recordLabel = UILabel(with: UIFont.systemFont(ofSize: 10.0), inColor: .titleTextBlack,
                                   lines: 1, text: NSLocalizedString("RECORD_START_TITLE", comment: ""))
        self.recordTimerLabel = UILabel(with: UIFont.monospacedDigitSystemFont(ofSize: 17.0, weight: .regular),
                                        inColor: .white, lines: 1, text: "00:00:00")
        self.recordCountLabel = UILabel(with: UIFont.monospacedDigitSystemFont(ofSize: 17.0, weight: .regular),
                                        inColor: .white, lines: 1, text: "#1")
        self.recordView = UIView(frame: CGRect.zero)
        self.recordContainer = UIView(frame: CGRect.zero)
        self.recordViewGradientLayer = CAGradientLayer()
        self.recordPulseView = PulseVisualizationView(strokeColor: UIColor.gradientStart.withAlphaComponent(0.25),
                                                      fillColor: UIColor.gradientStart)
        self.recordDurationFormatter = DateComponentsFormatter()
        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.stackView = UIStackView(frame: CGRect.zero)

        self.containers = [DashboardContainerViewController]()

        super.init(nibName: nil, bundle: nil)

        // These can only be initialized after self has been constructed
        dismissItem = UIBarButtonItem(image: UIImage(named: "icon_cross"), style: .plain,
                                      target: self, action: #selector(dismissAction))

        dismissItem?.tintColor = UIColor.black

        modalPresentationStyle = .overFullScreen

        recordButton.setImage(UIImage(named: "icon_record_button_stopped"), for: .normal)
        recordButton.setImage(UIImage(named: "icon_record_button_started"), for: .selected)
        recordButton.addTarget(self, action: #selector(recordAction), for: .touchUpInside)

        recordViewGradientLayer.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        recordViewGradientLayer.locations = [0.0, 1.0]
        recordViewGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        recordViewGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        recordViewGradientLayer.isHidden = true

        recordView.backgroundColor = .white
        recordView.layer.addSublayer(recordViewGradientLayer)

        recordLabel.textAlignment = .center
        recordCountLabel.textAlignment = .center
        recordTimerLabel.textAlignment = .center

        recordDurationFormatter.allowedUnits = [.hour, .minute, .second]
        recordDurationFormatter.unitsStyle = .positional
        recordDurationFormatter.zeroFormattingBehavior = .pad
        recordDurationFormatter.maximumUnitCount = 3

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10

        scrollView.backgroundColor = UIColor.tabPageBackground
        scrollView.showsVerticalScrollIndicator = false

        containers = viewModel.containers.filter { $0.isEnabled }.map { DashboardContainerViewController(viewModel: $0) }

        viewModel.containers.forEach {
            $0.isSelectMode = false
            $0.isEditMode = false
        }

        containers.forEach {
            addChild($0)
            $0.didMove(toParent: self)
        }

        if containers.isEmpty {
            recordButton.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.addObserver(self)

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        navigationItem.title = NSLocalizedString("RECORD_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = dismissItem

        if containers.isEmpty {
            // Remove autolayout size ambiguity with scrollview
            stackView.addArrangedSubview(UIView(frame: CGRect.zero))
        } else {
            containers.forEach { stackView.addArrangedSubview($0.view) }
        }

        layoutView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        recordView.dropShadow(color: .black, opacity: 0.5, radius: 4)

        recordViewGradientLayer.frame = recordView.bounds
    }

    @objc private func dismissAction() {
        dismiss(animated: true) {
            self.containers.forEach { $0.removeFromParent() }
            self.removeFromParent()
        }
    }

    @objc private func recordAction() {
        if recordButton.isSelected == false {
            recordButton.isSelected = true
            viewModel.startRecording()
        } else {
            recordButton.isSelected = false
            viewModel.stopRecording()
        }
    }

    private func startRecordingSession() {
        navigationItem.leftBarButtonItem = nil

        recordCountLabel.text = "#\(recordingSessionCount)"
        recordLabel.text = NSLocalizedString("RECORD_STOP_TITLE", comment: "")
        recordLabel.textColor = .white
        recordViewGradientLayer.isHidden = false
        recordPulseView.startPulseAnimation()

        recordingSessionCount += 1
        recordingStartDate = Date()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let startDate = self?.recordingStartDate,
                  let timerLabel = self?.recordTimerLabel,
                  let formatter = self?.recordDurationFormatter else { return }

            let timeInterval = Date().timeIntervalSince(startDate)
            let hourPad = timeInterval < 36000 ? "0" : ""

            timerLabel.text = hourPad + (formatter.string(from: timeInterval) ?? "")
        }
    }

    private func stopRecordingSession() {
        recordLabel.text = NSLocalizedString("RECORD_START_TITLE", comment: "")
        recordLabel.textColor = .titleTextBlack
        recordViewGradientLayer.isHidden = true
        recordPulseView.stopPulseAnimation()
        recordTimerLabel.text = "00:00:00"

        recordingTimer?.invalidate()
        recordingTimer = nil

        navigationItem.leftBarButtonItem = dismissItem
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
            stopRecordingSession()
            recordButton.isHidden = true
            recordLabel.text = NSLocalizedString("RECORD_NOTHING_TITLE", comment: "")
        }

        view.layoutIfNeeded()
    }

    private func layoutView() {
        view.addSubview(scrollView)
        view.addSubview(recordView)
        view.addSubview(recordButton)
        recordView.addSubview(recordContainer)
        recordView.addSubview(recordPulseView)
        recordContainer.addSubview(recordLabel)
        recordContainer.addSubview(recordTimerLabel)
        recordContainer.addSubview(recordCountLabel)
        scrollView.addSubview(stackView)

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordPulseView.translatesAutoresizingMaskIntoConstraints = false
        recordLabel.translatesAutoresizingMaskIntoConstraints = false
        recordTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        recordCountLabel.translatesAutoresizingMaskIntoConstraints = false
        recordView.translatesAutoresizingMaskIntoConstraints = false
        recordContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)])

        NSLayoutConstraint.activate(
            [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
             stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
             stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10.0),
             stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
             stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [recordView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             recordView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
             recordView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -49.0),
             recordView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             recordView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [recordContainer.leadingAnchor.constraint(equalTo: recordView.leadingAnchor),
             recordContainer.topAnchor.constraint(equalTo: recordView.topAnchor),
             recordContainer.trailingAnchor.constraint(equalTo: recordView.trailingAnchor),
             recordContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        NSLayoutConstraint.activate(
            [recordButton.centerXAnchor.constraint(equalTo: recordContainer.centerXAnchor),
             recordButton.centerYAnchor.constraint(equalTo: recordContainer.topAnchor, constant: 2.0),
             recordButton.widthAnchor.constraint(equalToConstant: 66.0),
             recordButton.heightAnchor.constraint(equalToConstant: 66.0)])

        NSLayoutConstraint.activate(
            [recordPulseView.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor),
             // Button image bounding box is not centered
             recordPulseView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor, constant: -2.0),
             recordPulseView.widthAnchor.constraint(equalTo: recordButton.widthAnchor),
             recordPulseView.heightAnchor.constraint(equalTo: recordButton.heightAnchor)])

        NSLayoutConstraint.activate(
            [recordLabel.centerXAnchor.constraint(equalTo: recordContainer.centerXAnchor),
             recordLabel.bottomAnchor.constraint(equalTo: recordContainer.bottomAnchor, constant: -2.0)])

        NSLayoutConstraint.activate(
            [recordTimerLabel.centerYAnchor.constraint(equalTo: recordContainer.centerYAnchor),
             recordTimerLabel.leadingAnchor.constraint(equalTo: recordContainer.leadingAnchor),
             recordTimerLabel.trailingAnchor.constraint(equalTo: recordContainer.centerXAnchor, constant: -33.0)])

        NSLayoutConstraint.activate(
            [recordCountLabel.centerYAnchor.constraint(equalTo: recordContainer.centerYAnchor),
             recordCountLabel.leadingAnchor.constraint(equalTo: recordContainer.centerXAnchor, constant: 33.0),
             recordCountLabel.trailingAnchor.constraint(equalTo: recordContainer.trailingAnchor)])

        view.layoutIfNeeded()
    }
}

extension RecordViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let event as MovesenseObserverEventDashboard: handleEventDashboard(event)
        case let event as RecorderObserverEvent: handleEventRecorder(event)
        default: return
        }
    }

    func handleEventDashboard(_ event: MovesenseObserverEventDashboard) {
        switch event {
        case .dashboardUpdated: DispatchQueue.main.async { self.updateDashboard() }
        case .dashboardError(let error): onError(error)
        }
    }

    func handleEventRecorder(_ event: RecorderObserverEvent) {
        switch event {
        case .idle: DispatchQueue.main.async { self.stopRecordingSession() }
        case .recording: DispatchQueue.main.async { self.startRecordingSession() }
        case .recordsUpdated: NSLog("recordsUpdated") // TODO: Display notification on snack bar
        case .recorderConverting: NSLog("recorderConverting")
        case .recorderError(let error): NSLog("recorderError: \(error)")
        }
    }

    func onError(_ error: Error) {
        // TODO: Notify user about error
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.containers.forEach {
                    $0.view.removeFromSuperview()
                    $0.removeFromParent()
                }
                self.removeFromParent()
            }
        }
    }
}
