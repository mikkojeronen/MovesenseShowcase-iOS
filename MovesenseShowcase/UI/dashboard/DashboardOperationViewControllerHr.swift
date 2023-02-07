//
// DashboardOperationViewControllerHr.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardOperationViewControllerHr: UIViewController {

    private enum Constants {
        static let progressPathWidth: CGFloat = 6.0
        static let progressStartAngle: CGFloat = -CGFloat.pi / 2.0
        static let progressEndAngle: CGFloat = 3.0 * CGFloat.pi / 2.0
        static let progressStep: CGFloat = 1.0 / 60.0
        static let tickWidth: CGFloat = 2.0
        static let tickLength: CGFloat = 4.0
    }

    private let viewModel: DashboardContainerViewModel

    private let hrContainer: UIView = UIView()
    private let pulseContainer: UIView = UIView()
    private let pulseView: PulseVisualizationView
    private let hrAverageView: DashboardHrView
    private let hrMinView: DashboardHrView
    private let hrMaxView: DashboardHrView
    private let minLabel: UILabel
    private let maxLabel: UILabel

    private let progressLayer: CAShapeLayer
    private let ticksLayer: CAShapeLayer

    private var hrMin: Int = Int.max
    private var hrMax: Int = Int.min

    init(viewModel: DashboardContainerViewModel) {
        self.viewModel = viewModel
        self.pulseView = PulseVisualizationView(strokeColor: UIColor.gradientStart,
                                                 fillColor: UIColor.white)
        self.hrAverageView = DashboardHrView(labelSize: 57.0)
        self.hrMinView = DashboardHrView(labelSize: 27.0)
        self.hrMaxView = DashboardHrView(labelSize: 27.0)
        self.minLabel = UILabel(with: UIFont.systemFont(ofSize: 12.0, weight: .medium),
                                inColor: UIColor.gradientStart, text: "min")
        self.maxLabel = UILabel(with: UIFont.systemFont(ofSize: 12.0, weight: .medium),
                                inColor: UIColor.gradientStart, text: "max")
        self.progressLayer = CAShapeLayer()
        self.ticksLayer = CAShapeLayer()
        super.init(nibName: nil, bundle: nil)

        hrContainer.backgroundColor = .white
        hrContainer.dropShadow(color: UIColor.black, opacity: 0.5, radius: 10.0)

        progressLayer.strokeEnd = 0.0

        hrMinView.isUserInteractionEnabled = true
        hrMinView.addTapGesture(tapNumber: 1, target: self, action: #selector(resetMinValue))

        hrMaxView.isUserInteractionEnabled = true
        hrMaxView.addTapGesture(tapNumber: 1, target: self, action: #selector(resetMaxValue))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.addObserver(self)

        layoutView()

        if viewModel.isOperation == false {
            viewModel.requestMethod(DashboardMethod.subscribe, indices: [])
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        hrContainer.layer.cornerRadius = hrContainer.bounds.width / 2

        createProgress(width: hrContainer.bounds.width, height: hrContainer.bounds.height)
        createTicks(width: hrContainer.bounds.width, height: hrContainer.bounds.height)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        pulseView.startPulseAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        pulseView.stopPulseAnimation()
    }

    @objc private func resetMinValue() {
        hrMinView.hrValue = nil
        hrMin = Int.max
    }

    @objc private func resetMaxValue() {
        hrMaxView.hrValue = nil
        hrMax = Int.min
    }

    private func updateHeartRate(_ value: Int) {
        hrAverageView.hrValue = value

        hrMin = value < hrMin ? value : hrMin
        hrMax = value > hrMax ? value : hrMax

        hrMinView.hrValue = hrMin
        hrMaxView.hrValue = hrMax

        let nextStrokeEnd = progressLayer.strokeEnd + Constants.progressStep

        CATransaction.begin()

        if nextStrokeEnd >= (1.0 + Constants.progressStep) {
            CATransaction.setAnimationDuration(0.0)
            progressLayer.strokeEnd = 0.0
            CATransaction.setCompletionBlock({
                CATransaction.setAnimationDuration(1.0)
                self.progressLayer.strokeEnd = Constants.progressStep
            })
        } else {
            CATransaction.setAnimationDuration(1.0)
            progressLayer.strokeEnd = nextStrokeEnd
        }

        CATransaction.commit()
    }

    private func createTicks(width: CGFloat, height: CGFloat) {
        let ticksPath = CGMutablePath()
        ticksPath.move(to: CGPoint(x: width / 2, y: 0.0))
        ticksPath.addLine(to: CGPoint(x: width / 2, y: Constants.tickLength))
        ticksPath.move(to: CGPoint(x: width, y: height / 2))
        ticksPath.addLine(to: CGPoint(x: width - Constants.tickLength, y: height / 2))
        ticksPath.move(to: CGPoint(x: width / 2, y: height))
        ticksPath.addLine(to: CGPoint(x: width / 2, y: height - Constants.tickLength))
        ticksPath.move(to: CGPoint(x: 0.0, y: height / 2))
        ticksPath.addLine(to: CGPoint(x: Constants.tickLength, y: height / 2))

        ticksLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        ticksLayer.strokeColor = UIColor.titleTextBlack.cgColor
        ticksLayer.lineWidth = Constants.tickWidth
        ticksLayer.path = ticksPath

        hrContainer.layer.addSublayer(ticksLayer)
    }

    private func createProgress(width: CGFloat, height: CGFloat) {
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: width / 2.0, y: height / 2.0),
                                        radius: (width / 2.0) - Constants.tickLength / 2.0,
                                        startAngle: Constants.progressStartAngle,
                                        endAngle: Constants.progressEndAngle, clockwise: true)

        progressLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.progressIndicator.cgColor
        progressLayer.lineWidth = Constants.tickLength
        progressLayer.path = progressPath.cgPath

        hrContainer.layer.addSublayer(progressLayer)
    }

    private func layoutView() {
        view.addSubview(pulseView)
        view.addSubview(pulseContainer)
        view.addSubview(hrMinView)
        view.addSubview(hrMaxView)
        view.addSubview(minLabel)
        view.addSubview(maxLabel)
        view.addSubview(hrContainer)
        view.addSubview(hrAverageView)

        pulseView.translatesAutoresizingMaskIntoConstraints = false
        pulseContainer.translatesAutoresizingMaskIntoConstraints = false
        hrMinView.translatesAutoresizingMaskIntoConstraints = false
        hrMaxView.translatesAutoresizingMaskIntoConstraints = false
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        maxLabel.translatesAutoresizingMaskIntoConstraints = false
        hrContainer.translatesAutoresizingMaskIntoConstraints = false
        hrAverageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [pulseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             pulseView.topAnchor.constraint(equalTo: view.topAnchor),
             pulseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             pulseView.heightAnchor.constraint(equalTo: pulseView.widthAnchor)])

        NSLayoutConstraint.activate(
            [pulseContainer.leadingAnchor.constraint(equalTo: pulseView.leadingAnchor),
             pulseContainer.topAnchor.constraint(equalTo: pulseView.topAnchor),
             pulseContainer.trailingAnchor.constraint(equalTo: pulseView.trailingAnchor),
             pulseContainer.bottomAnchor.constraint(equalTo: pulseView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [hrContainer.centerXAnchor.constraint(equalTo: pulseView.centerXAnchor),
             hrContainer.centerYAnchor.constraint(equalTo: pulseView.centerYAnchor),
             hrContainer.widthAnchor.constraint(equalTo: pulseView.widthAnchor, multiplier: 0.6),
             hrContainer.heightAnchor.constraint(equalTo: hrContainer.widthAnchor)])

        NSLayoutConstraint.activate(
            [hrAverageView.trailingAnchor.constraint(equalTo: hrContainer.centerXAnchor, constant: 65.0),
             hrAverageView.centerYAnchor.constraint(equalTo: pulseView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [minLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             minLabel.bottomAnchor.constraint(equalTo: hrMinView.bottomAnchor, constant: -4)])

        NSLayoutConstraint.activate(
            [hrMinView.leadingAnchor.constraint(equalTo: minLabel.trailingAnchor, constant: 6.0),
             hrMinView.topAnchor.constraint(equalTo: pulseView.bottomAnchor),
             hrMinView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [maxLabel.leadingAnchor.constraint(greaterThanOrEqualTo: hrMinView.trailingAnchor),
             maxLabel.bottomAnchor.constraint(equalTo: hrMaxView.bottomAnchor, constant: -4)])

        NSLayoutConstraint.activate(
            [hrMaxView.leadingAnchor.constraint(equalTo: maxLabel.trailingAnchor, constant: 6.0),
             hrMaxView.topAnchor.constraint(equalTo: pulseView.bottomAnchor),
             hrMaxView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
             hrMaxView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16.0)])

        view.layoutIfNeeded()
    }
}

extension DashboardOperationViewControllerHr: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let hrEvent as DashboardObserverEventHr: handleEventHr(hrEvent)
        default: return
        }
    }

    func handleEventHr(_ event: DashboardObserverEventHr) {
        switch event {
        case .receivedHr(let average): DispatchQueue.main.async { self.updateHeartRate(Int(average)) }
        case .onError(let error): onError(error)
        }
    }

    func onError(_ error: String) {}
}
