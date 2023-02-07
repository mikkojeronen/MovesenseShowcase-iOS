//
// DfuRecoveryViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit
import MovesenseDfu

class DfuRecoveryViewController: UIViewController {

    private let scrollView: UIScrollView
    private let stackView: UIStackView

    private var backBarButtonItem: UIBarButtonItem?

    private let ledOnSensorImageView: UIImageView

    private let recoverSensorTitleLabel: UILabel
    private let selectFirmwareButton: UIButton
    private let resetFirmwareButton: UIButton

    private let instructionsTitleLabel: UILabel
    private let instructionsView: UIView
    private let instructionsLabel: UILabel
    private let instructionsButton: UIButton

    init() {
        self.scrollView = UIScrollView(frame: CGRect.zero)
        self.stackView = UIStackView(frame: CGRect.zero)

        self.ledOnSensorImageView = UIImageView(image: UIImage(named: "image_sensor"))

        self.recoverSensorTitleLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                               inColor: UIColor.titleTextBlack.withAlphaComponent(0.6), lines: 1,
                                               text: NSLocalizedString("DFU_RECOVERY_RECOVER_SENSOR_TITLE", comment: ""))

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

        ledOnSensorImageView.contentMode = .scaleAspectFit

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0

        scrollView.backgroundColor = UIColor.white
        scrollView.showsVerticalScrollIndicator = false

        backBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain,
                                            target: self, action: #selector(backAction))
        backBarButtonItem?.tintColor = .black

        selectFirmwareButton.setTitle(NSLocalizedString("DFU_RECOVERY_SELECT_FIRMWARE_TITLE", comment: ""), for: .normal)
        selectFirmwareButton.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        selectFirmwareButton.contentHorizontalAlignment = .left

        resetFirmwareButton.setTitle(NSLocalizedString("DFU_RESET_TITLE", comment: ""), for: .normal)
        resetFirmwareButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        resetFirmwareButton.contentHorizontalAlignment = .left

        instructionsButton.setImage(UIImage(named: "icon_arrow_right"), for: .normal)
        instructionsButton.tintColor = UIColor.titleTextBlack

        instructionsView.isUserInteractionEnabled = true
        instructionsView.addTapGesture(tapNumber: 1, target: self, action: #selector(instructionsAction))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("DFU_RECOVERY_NAV_TITLE", comment: "")

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        stackView.addArrangedSubview(recoverSensorTitleLabel)
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

        navigationItem.setLeftBarButton(backBarButtonItem, animated: animated)
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func selectAction() {
        navigationController?.pushViewController(DfuSelectViewController(viewModel: DfuViewModel()),
                                                 animated: true)
    }

    @objc private func resetAction() {
        let title = NSLocalizedString("DFU_RESET_CONFIRMATION_TITLE", comment: "")
        let text = NSLocalizedString("DFU_RESET_CONFIRMATION_TEXT", comment: "")
        let buttonTitle = NSLocalizedString("DFU_RESET_BUTTON_TITLE", comment: "")
        let cancelTitle = NSLocalizedString("DFU_RESET_CANCEL_TITLE", comment: "")

        let contentView = ConfirmationView(title: title, text: text, image: UIImage(named: "image_dfu_reset"))

        PopoverViewController.popoverAction(contentView: contentView,
                                            buttonTitle: buttonTitle,
                                            dismissTitle: cancelTitle) {
            let viewModel = DfuViewModel()
            viewModel.selectedPackage = viewModel.getBundledDfuPackages().first

            self.present(UINavigationController(rootViewController: DfuTargListViewController(viewModel: viewModel)),
                         animated: true)
        }
    }

    @objc private func instructionsAction() {
        navigationController?.pushViewController(DfuHowToViewController(),
                                                 animated: true)
    }

    private func layoutView() {
        view.addSubview(ledOnSensorImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        instructionsView.addSubview(instructionsLabel)
        instructionsView.addSubview(instructionsButton)

        ledOnSensorImageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        instructionsView.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [ledOnSensorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             ledOnSensorImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
             ledOnSensorImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 120.0),
             ledOnSensorImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 120.0)])

        NSLayoutConstraint.activate(
            [scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
             scrollView.topAnchor.constraint(equalTo: ledOnSensorImageView.bottomAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        NSLayoutConstraint.activate(
            [stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
             stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
             stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32.0),
             stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
             stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)])

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
