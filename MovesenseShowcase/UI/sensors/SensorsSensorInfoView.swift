//
// SensorsSensorInfoView.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class SensorsSensorInfoView: UIView {

    private let titleContainer: UIView = UIView(frame: CGRect.zero)
    private let titleLabel: UILabel
    private let expandButton: UIButton = UIButton(frame: CGRect.zero)

    private let infoStackView: UIStackView = UIStackView(frame: CGRect.zero)

    private let appNameLabel: UILabel
    private let appVersionLabel: UILabel
    private let coreSwVersionLabel: UILabel

    init(viewModel: SensorsSensorViewModel) {
        self.titleLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0, weight: .regular), inColor: .titleTextBlack,
                                  lines: 1, text: NSLocalizedString("SENSORS_SENSOR_INFO_TITLE", comment: ""))
        self.appNameLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0, weight: .light),
                                    inColor: .titleTextBlack, lines: 1)
        self.appVersionLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0, weight: .light),
                                       inColor: .titleTextBlack, lines: 1)
        self.coreSwVersionLabel = UILabel(with: UIFont.systemFont(ofSize: 16.0, weight: .light),
                                          inColor: .titleTextBlack, lines: 1)
        super.init(frame: CGRect.zero)

        clipsToBounds = true

        titleContainer.addTapGesture(tapNumber: 1, target: self, action: #selector(expandAction))

        expandButton.isUserInteractionEnabled = false
        expandButton.setImage(UIImage(named: "icon_plus_small"), for: .normal)
        expandButton.tintColor = UIColor.titleTextBlack

        infoStackView.axis = .vertical
        infoStackView.distribution = .equalSpacing
        infoStackView.alignment = .fill
        infoStackView.spacing = 0.0

        infoStackView.addArrangedSubview(appNameLabel)
        infoStackView.addArrangedSubview(appVersionLabel)
        infoStackView.addArrangedSubview(coreSwVersionLabel)
        infoStackView.addArrangedSubview(UIView.separator(color: .clear, bottom: -16.0))

        infoStackView.arrangedSubviews.forEach { $0.isHidden = true }

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateInfo(viewModel: SensorsSensorViewModel) {
        appNameLabel.text = NSLocalizedString("SENSOR_INFO_APP_NAME_TITLE", comment: "") + viewModel.appName

        appVersionLabel.text = NSLocalizedString("SENSOR_INFO_APP_VERSION_TITLE", comment: "") + viewModel.appVersion

        coreSwVersionLabel.text = NSLocalizedString("SENSOR_INFO_CORE_VERSION_TITLE", comment: "") +
                                  viewModel.deviceViewModel.swVersion
    }

    @objc private func expandAction() {
        UIView.animate(withDuration: 0.35) {
            if self.expandButton.transform == CGAffineTransform.identity {
                self.expandButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                self.infoStackView.arrangedSubviews.forEach { $0.isHidden = false }
            } else {
                self.expandButton.transform = CGAffineTransform.identity
                self.infoStackView.arrangedSubviews.forEach { $0.isHidden = true }
            }
        }
    }

    private func layoutView() {
        addSubview(titleContainer)
        addSubview(infoStackView)
        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(expandButton)

        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [titleContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
             titleContainer.topAnchor.constraint(equalTo: topAnchor),
             titleContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
             titleContainer.heightAnchor.constraint(equalToConstant: 44.0)])

        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
             titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor),
             titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor)])

        NSLayoutConstraint.activate(
            [expandButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
             expandButton.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
             expandButton.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
             infoStackView.topAnchor.constraint(equalTo: titleContainer.bottomAnchor),
             infoStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
             infoStackView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
