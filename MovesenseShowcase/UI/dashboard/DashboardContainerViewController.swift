//
// DashboardContainerViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardContainerViewController: UIViewController {

    let viewModel: DashboardContainerViewModel

    private let stackView: UIStackView
    private let headerContainer: UIView
    private let contentContainer: UIView

    private let titleLabel: UILabel
    private let serialLabel: UILabel
    private let quantityLabel: UILabel
    private let enableSwitch: UISwitch

    init(viewModel: DashboardContainerViewModel) {
        self.viewModel = viewModel
        self.stackView = UIStackView(frame: CGRect.zero)
        self.headerContainer = UIView(frame: CGRect.zero)
        self.contentContainer = UIView(frame: CGRect.zero)

        self.titleLabel = UILabel(with: UIFont.boldSystemFont(ofSize: 18.0), inColor: UIColor.black,
                                  lines: 1, text: viewModel.name)
        self.serialLabel = UILabel(with: UIFont.systemFont(ofSize: 10.0), inColor: UIColor.lightGray,
                                   lines: 1, text: viewModel.serial)
        self.quantityLabel = UILabel(with: UIFont.systemFont(ofSize: 12.0), inColor: UIColor.black,
                                     lines: 1, text: viewModel.quantity)
        self.enableSwitch = UISwitch(frame: CGRect.zero)

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white
        view.clipsToBounds = true

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0

        enableSwitch.isHidden = viewModel.isEditMode == false
        enableSwitch.isUserInteractionEnabled = true
        enableSwitch.addTarget(self, action: #selector(enableSwitchAction), for: .touchUpInside)

        viewModel.addObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(headerContainer)
        stackView.addArrangedSubview(contentContainer)

        contentContainer.isHidden = viewModel.isEnabled == false

        if viewModel.isEnabled {
            enableContainer()
        }

        layoutView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let thumbGradientColors = [UIColor(red: 238 / 255, green: 49 / 255, blue: 38 / 255, alpha: 1.0),
                                   UIColor(red: 220 / 255, green: 0 / 255, blue: 97 / 255, alpha: 1.0)]
        enableSwitch.thumbTintColor = UIColor.colorWithGradient(frame: enableSwitch.frame,
                                                                colors: thumbGradientColors)

        let onGradientColors = [UIColor(red: 238 / 255, green: 49 / 255, blue: 38 / 255, alpha: 0.6),
                                UIColor(red: 220 / 255, green: 0 / 255, blue: 97 / 255, alpha: 0.6)]
        enableSwitch.onTintColor = UIColor.colorWithGradient(frame: enableSwitch.frame,
                                                             colors: onGradientColors,
                                                             startPoint: CGPoint(x: 0.0, y: 0.5),
                                                             endPoint: CGPoint(x: 1.0, y: 0.5))
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        if parent == nil {
            children.forEach { $0.removeFromParent() }
        }
    }

    @objc private func enableSwitchAction() {
        if enableSwitch.isOn {
            enableContainer()
            viewModel.isEditMode = true
        } else {
            disableContainer()
            viewModel.isEditMode = false
        }
    }

    private func enableContainer() {
        guard let operationVC = DashboardFactory.createOperationViewController(viewModel: viewModel) else { return }

        addChild(operationVC)
        operationVC.didMove(toParent: self)

        contentContainer.addSubview(operationVC.view)
        operationVC.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [operationVC.view.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
             operationVC.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
             operationVC.view.rightAnchor.constraint(equalTo: contentContainer.rightAnchor),
             operationVC.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)])

        UIView.animate(withDuration: 0.5) {
            self.contentContainer.isHidden = false
        }

        viewModel.isEnabled = true
    }

    private func disableContainer() {
        children.forEach { child in
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        contentContainer.isHidden = true
        viewModel.isEnabled = false
    }

    private func layoutView() {
        view.addSubview(stackView)
        headerContainer.addSubview(titleLabel)
        headerContainer.addSubview(serialLabel)
        headerContainer.addSubview(quantityLabel)
        headerContainer.addSubview(enableSwitch)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        serialLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        enableSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
             stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
             stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        NSLayoutConstraint.activate(
            [serialLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
             serialLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 2.0)])

        NSLayoutConstraint.activate(
            [titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16.0),
             titleLabel.topAnchor.constraint(equalTo: serialLabel.bottomAnchor, constant: -1.0),
             titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -6.0)])

        NSLayoutConstraint.activate(
            [enableSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
             enableSwitch.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -10.0),
             enableSwitch.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor)])

        NSLayoutConstraint.activate(
            [quantityLabel.leadingAnchor.constraint(equalTo: enableSwitch.leadingAnchor),
             quantityLabel.trailingAnchor.constraint(equalTo: enableSwitch.trailingAnchor),
             quantityLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension DashboardContainerViewController: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? DashboardObserverEventContainer else { return }

        switch event {
        case .editModeUpdate(let update): editModeUpdate(update)
        case .selectModeUpdate(let update, let enabled): selectModeUpdate(update, enabled: enabled)
        case .quantityUpdate(let update): quantityUpdate(update)
        case .onError(let error): onError(error)
        }
    }

    func editModeUpdate(_ update: Bool) {}

    func selectModeUpdate(_ update: Bool, enabled: Bool) {
        DispatchQueue.main.async {
            self.enableSwitch.isHidden = update == false
            self.quantityLabel.isHidden = update || enabled == false
        }
    }

    func quantityUpdate(_ update: String) {
        DispatchQueue.main.async {
            self.quantityLabel.text = update
        }
    }

    func onError(_ error: String) {
        // TODO: Handle
    }
}
