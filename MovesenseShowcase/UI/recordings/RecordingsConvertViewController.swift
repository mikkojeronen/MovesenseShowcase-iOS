//
// RecordingsConvertViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

enum RecordingsConvertTargetType: String {

    case csv = "com.movesense.showcase.shareCsv"
}

class RecordingsConvertViewController: UIViewController {

    private enum Constants {
        static let progressPathWidth: CGFloat = 6.0
        static let progressStartAngle: CGFloat = -CGFloat.pi / 2.0
        static let progressEndAngle: CGFloat = 3.0 * CGFloat.pi / 2.0
    }

    private let sourceActivity: UIActivity
    private let sourceFiles: [URL]
    private let targetType: RecordingsConvertTargetType

    private let cancelButton: UIButton

    private let progressStateLabel: UILabel
    private let progressPartLabel: UILabel

    private let progressView: UIView
    private let progressImageView: UIImageView
    private let progressPath: UIBezierPath
    private let progressLayer: CAShapeLayer
    private let progressBackgroundLayer: CAShapeLayer

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(activity: UIActivity, sourceFiles: [URL], targetType: RecordingsConvertTargetType) {
        self.sourceActivity = activity
        self.sourceFiles = sourceFiles
        self.targetType = targetType

        self.cancelButton = UIButton(frame: CGRect.zero)

        self.progressStateLabel = UILabel(with: UIFont.systemFont(ofSize: 14.0, weight: .regular),
                                          inColor: UIColor.white, lines: 0,
                                          text: NSLocalizedString("RECORDINGS_CONVERT_PROGRESS_UPDATING_TITLE", comment: ""))
        self.progressPartLabel = UILabel(with: UIFont.systemFont(ofSize: 14.0, weight: .regular),
                                         inColor: UIColor.white, lines: 1,
                                         text: NSLocalizedString("RECORDINGS_CONVERT_PROGRESS_PART_TITLE", comment: "") + "0 / 0")
        self.progressView = UIView()
        self.progressImageView = UIImageView(image: UIImage(named: "icon_checkmark"))
        self.progressPath = UIBezierPath(arcCenter: CGPoint(x: 25.0, y: 25.0), radius: 25.0,
                                         startAngle: Constants.progressStartAngle,
                                         endAngle: Constants.progressEndAngle, clockwise: true)
        self.progressLayer = CAShapeLayer()
        self.progressBackgroundLayer = CAShapeLayer()

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.gray

        cancelButton.setImage(UIImage(named: "icon_cross"), for: .normal)
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 20.0)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)

        progressStateLabel.textAlignment = .center
        progressPartLabel.textAlignment = .center

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

    deinit {
        RecorderApi.instance.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        RecorderApi.instance.addObserver(self)

        layoutView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        convertFiles()
    }

    @objc private func cancelAction() {
        dismiss(animated: true) {
            self.sourceActivity.activityDidFinish(false)
        }
    }

    private func convertFiles() {
        DispatchQueue.global().async { [weak self] in
            guard let sourceFiles = self?.sourceFiles else { return }
            let convertedFiles = sourceFiles.enumerated().compactMap { sourceFile -> URL? in
                self?.updateProgressLabel(part: sourceFile.offset + 1, totalParts: sourceFiles.count)
                return RecorderApi.instance.convertToCsv(sourceFile.element)
            }

            if self?.isBeingDismissed == false {
                self?.completeProgress()
                self?.shareConvertedFiles(convertedFiles)
            }
        }
    }

    private func updateProgressLabel(part: Int, totalParts: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.progressPartLabel.text = NSLocalizedString("RECORDINGS_CONVERT_PROGRESS_PART_TITLE", comment: "") +
                                           "\(part) / \(totalParts)"
        }
    }

    private func completeProgress() {
        DispatchQueue.main.async { [weak self] in
            self?.progressImageView.isHidden = false
            self?.progressLayer.strokeEnd = 1.0
            self?.progressStateLabel.text = NSLocalizedString("RECORDINGS_CONVERT_PROGRESS_ALL_DONE_TITLE", comment: "")
        }
    }

    private func shareConvertedFiles(_ files: [URL]) {
        DispatchQueue.main.async { [weak self] in
            let activityViewController = UIActivityViewController(activityItems: files, applicationActivities: nil)

            activityViewController.popoverPresentationController?.sourceView = self?.view
            activityViewController.completionWithItemsHandler = { [weak self]
            (activityType: UIActivity.ActivityType?,
             completed: Bool,
             returnedItems: [Any]?,
             activityError: Error?) -> Void in
                self?.sourceActivity.activityDidFinish(completed)
                self?.dismiss(animated: true)
            }

            self?.present(activityViewController, animated: true)
        }
    }

    private func layoutView() {
        view.addSubview(cancelButton)
        view.addSubview(progressView)
        view.addSubview(progressImageView)
        view.addSubview(progressStateLabel)
        view.addSubview(progressPartLabel)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressImageView.translatesAutoresizingMaskIntoConstraints = false
        progressStateLabel.translatesAutoresizingMaskIntoConstraints = false
        progressPartLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0)])

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

        view.layoutIfNeeded()
    }
}

extension RecordingsConvertViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let event as RecorderObserverEvent: handleEventRecorder(event)
        default: return
        }
    }

    private func handleEventRecorder(_ event: RecorderObserverEvent) {
        switch event {
        case .recorderConverting(let filePath, let progress): updateProgress(filePath: filePath, progress: progress)
        default: return
        }
    }

    private func updateProgress(filePath: String, progress: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.progressLayer.strokeEnd = CGFloat(CGFloat(progress) / 100.0)
        }
    }
}
