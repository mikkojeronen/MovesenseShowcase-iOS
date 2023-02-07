//
// DfuProgressViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi
import MovesenseDfu

class DfuProgressViewController: UIViewController {

    private enum Constants {
        static let progressPathWidth: CGFloat = 6.0
        static let progressStartAngle: CGFloat = -CGFloat.pi / 2.0
        static let progressEndAngle: CGFloat = 3.0 * CGFloat.pi / 2.0
    }

    private let viewModel: DfuViewModel

    private let progressStateLabel: UILabel
    private let progressPartLabel: UILabel
    private let progressSpeedLabel: UILabel

    private let progressView: UIView
    private let progressImageView: UIImageView
    private let progressPath: UIBezierPath
    private let progressLayer: CAShapeLayer
    private let progressBackgroundLayer: CAShapeLayer

    private let cancelButton: UIButton

    init(viewModel: DfuViewModel) {
        self.viewModel = viewModel

        self.progressStateLabel = UILabel(with: UIFont.systemFont(ofSize: 14.0, weight: .regular),
                                          inColor: UIColor.white, lines: 0,
                                          text: NSLocalizedString("DFU_PROGRESS_UPDATING_TITLE", comment: ""))
        self.progressPartLabel = UILabel(with: UIFont.systemFont(ofSize: 14.0, weight: .regular),
                                         inColor: UIColor.white, lines: 1,
                                         text: NSLocalizedString("DFU_PROGRESS_PART_TITLE", comment: "") + "0 / 0")
        self.progressSpeedLabel = UILabel(with: UIFont.systemFont(ofSize: 14.0, weight: .regular),
                                          inColor: UIColor.white, lines: 0,
                                          text: NSLocalizedString("DFU_PROGRESS_SPEED_TITLE", comment: "") + "0.0 kB/s")
        self.progressView = UIView()
        self.progressImageView = UIImageView(image: UIImage(named: "icon_checkmark"))
        self.progressPath = UIBezierPath(arcCenter: CGPoint(x: 25.0, y: 25.0), radius: 25.0,
                                         startAngle: Constants.progressStartAngle,
                                         endAngle: Constants.progressEndAngle, clockwise: true)
        self.progressLayer = CAShapeLayer()
        self.progressBackgroundLayer = CAShapeLayer()

        self.cancelButton = UIButton(type: .system)

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.gray

        cancelButton.setImage(UIImage(named: "icon_cross"), for: .normal)
        cancelButton.tintColor = UIColor.titleTextBlack
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)

        progressStateLabel.textAlignment = .center
        progressPartLabel.textAlignment = .center
        progressSpeedLabel.textAlignment = .center

        progressView.layer.addSublayer(progressBackgroundLayer)
        progressView.layer.addSublayer(progressLayer)

        progressImageView.isHidden = true
        progressImageView.contentMode = .scaleAspectFit

        progressBackgroundLayer.strokeColor = UIColor.white.cgColor
        progressBackgroundLayer.lineWidth = Constants.progressPathWidth
        progressBackgroundLayer.fillColor = nil
        progressBackgroundLayer.path = progressPath.cgPath

        progressLayer.strokeColor = UIColor.progressIndicator.cgColor
        progressLayer.lineWidth = Constants.progressPathWidth
        progressLayer.fillColor = nil
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeEnd = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.addObserver(self)

        viewModel.updateDevice()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        progressLayer.frame = progressView.bounds
    }

    @objc private func cancelAction() {
        viewModel.resetDfu()

        dismiss(animated: true)
    }

    private func layoutView() {
        view.addSubview(cancelButton)
        view.addSubview(progressView)
        view.addSubview(progressImageView)
        view.addSubview(progressStateLabel)
        view.addSubview(progressPartLabel)
        view.addSubview(progressSpeedLabel)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressImageView.translatesAutoresizingMaskIntoConstraints = false
        progressStateLabel.translatesAutoresizingMaskIntoConstraints = false
        progressPartLabel.translatesAutoresizingMaskIntoConstraints = false
        progressSpeedLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [cancelButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 35.0),
             cancelButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35.0),
             cancelButton.widthAnchor.constraint(equalToConstant: 44.0),
             cancelButton.heightAnchor.constraint(equalToConstant: 44.0)])

        NSLayoutConstraint.activate(
            [progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             progressView.widthAnchor.constraint(equalToConstant: 50.0),
             progressView.heightAnchor.constraint(equalToConstant: 50.0),
             progressView.bottomAnchor.constraint(equalTo: progressStateLabel.topAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [progressImageView.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
             progressImageView.centerYAnchor.constraint(equalTo: progressView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [progressStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             progressStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             progressStateLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -32.0)])

        NSLayoutConstraint.activate(
            [progressPartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             progressPartLabel.topAnchor.constraint(equalTo: progressStateLabel.bottomAnchor, constant: 16.0)])

        NSLayoutConstraint.activate(
            [progressSpeedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             progressSpeedLabel.topAnchor.constraint(equalTo: progressPartLabel.bottomAnchor, constant: 16.0)])

        view.layoutIfNeeded()
    }
}

extension DfuProgressViewController: Observer {
    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventDfu else { return }

        switch event {
        case .dfuStateChanged(let state): stateChanged(state)
        case .dfuDeviceDiscovered: return
        case .dfuUpdateProgress(let part, let totalParts, let progress,
                                let currentSpeed, let avgSpeed): updateProgress(part, totalParts, progress,
                                                                                currentSpeed, avgSpeed)
        case .dfuOnError(let error): onError(error)
        }
    }

    private func stateChanged(_ state: MovesenseDfuState) {
        switch state {
        case .dfuCompleted:
            DispatchQueue.main.async {
                self.progressImageView.isHidden = false
                self.progressLayer.strokeEnd = 1.0
                self.progressStateLabel.text = NSLocalizedString("DFU_PROGRESS_ALL_DONE_TITLE", comment: "")
            }
        default: return
        }
    }

    private func updateProgress(_ part: Int, _ totalParts: Int, _ progress: Int, _ currentSpeed: Double, _ avgSpeed: Double) {
        DispatchQueue.main.async {
            // TODO: Move to viewmodel
            let kbSpeed: Double = (currentSpeed / 1024.0)
            let formattedSpeed: String = String(format: "%3.1f kB/s", kbSpeed)
            let partsProgress = CGFloat(part - 1) / CGFloat(totalParts)

            self.progressLayer.strokeEnd = CGFloat(progress - 1) / (CGFloat(totalParts) * 100.0) + partsProgress
            self.progressPartLabel.text = NSLocalizedString("DFU_PROGRESS_PART_TITLE", comment: "") + "\(part) / \(totalParts)"
            self.progressSpeedLabel.text = NSLocalizedString("DFU_PROGRESS_SPEED_TITLE", comment: "") + formattedSpeed
        }
    }

    private func onError(_ error: String) {
        DispatchQueue.main.async {
            self.progressStateLabel.text = "Error: \(error)"
        }
    }
}
