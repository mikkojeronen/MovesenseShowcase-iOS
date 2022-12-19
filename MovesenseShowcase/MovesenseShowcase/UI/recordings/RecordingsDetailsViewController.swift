//
// RecordingsDetailsViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class RecordingsDetailsViewController: UIViewController {

    private let viewModel: RecordingViewModel
    private let recordingsViewModel: RecordingsViewModel

    private let titleLabel: UILabel
    private let sizeLabel: UILabel
    private let sensorLabel: UILabel
    private let dateLabel: UILabel
    private let timeLabel: UILabel
    private let durationLabel: UILabel

    private let sensorTextLabel: UILabel
    private let dateTextLabel: UILabel
    private let timeTextLabel: UILabel
    private let durationTextLabel: UILabel
    private let stackView: UIStackView = UIStackView(frame: CGRect.zero)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: RecordingViewModel, recordingsViewModel: RecordingsViewModel) {
        self.viewModel = viewModel
        self.recordingsViewModel = recordingsViewModel

        self.sensorLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                   text: NSLocalizedString("RECORDINGS_DETAILS_SENSOR_TITLE", comment: ""))
        self.dateLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                 text: NSLocalizedString("RECORDINGS_DETAILS_DATE_TITLE", comment: ""))
        self.timeLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                 text: NSLocalizedString("RECORDINGS_DETAILS_TIME_TITLE", comment: ""))
        self.durationLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                     text: NSLocalizedString("RECORDINGS_DETAILS_DURATION_TITLE", comment: ""))

        self.titleLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 17.0), inColor: .titleTextBlack, lines: 1,
                                  text: viewModel.resourceName)

        self.sizeLabel = UILabel(with: UIFont.systemFont(ofSize: 15.0), inColor: .titleTextBlack, lines: 1,
                                 text: viewModel.streamSize)

        self.sensorTextLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                       text: viewModel.sensorSerial)

        self.dateTextLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                     text: viewModel.dateLongYear)

        self.timeTextLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                     text: viewModel.timeShort)

        self.durationTextLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0), inColor: .titleTextBlack, lines: 1,
                                         text: viewModel.duration)

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.dateLong + " " + viewModel.timeShort
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                                           target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self, action: #selector(actionAction))

        navigationItem.leftBarButtonItem?.tintColor = UIColor.titleTextBlack
        navigationItem.rightBarButtonItem?.tintColor = UIColor.titleTextBlack

        viewModel.parameters.forEach { parameter in
            stackView.addArrangedSubview(RecordingsParameterView(parameter))
        }

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc private func backAction(sender: UIView) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func actionAction(sender: UIView) {
        // TODO: Might take a long time, implement a progress view and execute in background
        guard let tempUrl: URL = recordingsViewModel.tempCopyRecord(viewModel) else { return }

        let activityViewController = UIActivityViewController(
            activityItems: [tempUrl],
            applicationActivities: [RecordingsConvertActivity()])

        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.completionWithItemsHandler = { [weak self]
        (activityType: UIActivity.ActivityType?,
         completed: Bool,
         returnedItems: [Any]?,
         activityError: Error?) -> Void in

            self?.recordingsViewModel.tempClear()
        }

        present(activityViewController, animated: true)
    }

    private func layoutView() {
        view.addSubview(titleLabel)
        view.addSubview(sizeLabel)
        view.addSubview(sensorLabel)
        view.addSubview(sensorTextLabel)
        view.addSubview(dateLabel)
        view.addSubview(dateTextLabel)
        view.addSubview(timeLabel)
        view.addSubview(timeTextLabel)
        view.addSubview(durationLabel)
        view.addSubview(durationTextLabel)
        view.addSubview(stackView)

        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20.0),
             titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                  constant: -20.0)])

        NSLayoutConstraint.activate(
            [sizeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             sizeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10.0),
             sizeLabel.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -20.0)])

        NSLayoutConstraint.activate(
            [sensorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             sensorLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 20.0)])

        NSLayoutConstraint.activate(
            [sensorTextLabel.leadingAnchor.constraint(equalTo: sensorLabel.trailingAnchor, constant: 5.0),
             sensorTextLabel.topAnchor.constraint(equalTo: sensorLabel.topAnchor),
             sensorTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -20.0)])

        NSLayoutConstraint.activate(
            [dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             dateLabel.topAnchor.constraint(equalTo: sensorLabel.bottomAnchor, constant: 5.0)])

        NSLayoutConstraint.activate(
            [dateTextLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 5.0),
             dateTextLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor),
             dateTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -20.0)])

        NSLayoutConstraint.activate(
            [timeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             timeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5.0)])

        NSLayoutConstraint.activate(
            [timeTextLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 5.0),
             timeTextLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
             timeTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -20.0)])

        NSLayoutConstraint.activate(
            [durationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             durationLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 5.0)])

        NSLayoutConstraint.activate(
            [durationTextLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 5.0),
             durationTextLabel.topAnchor.constraint(equalTo: durationLabel.topAnchor),
             durationTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                         constant: -20.0)])

        NSLayoutConstraint.activate(
            [stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
             stackView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 20.0),
             stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0),
             stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0)])

        view.layoutIfNeeded()
    }
}
