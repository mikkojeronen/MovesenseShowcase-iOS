//
// DashboardOperationViewControllerDebug.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit
import MovesenseApi

class DashboardOperationViewControllerDebug: UIViewController {

    private let viewModel: DashboardContainerViewModel
    private let debugTextView: UITextView = UITextView(frame: CGRect.zero)
    private let getButton: UIButton = UIButton(frame: CGRect.zero)
    private let putButton: UIButton = UIButton(frame: CGRect.zero)
    private let subscribeButton: UIButton = UIButton(frame: CGRect.zero)
    private let unsubscribeButton: UIButton = UIButton(frame: CGRect.zero)
    private let parameterPicker: UIPickerView = UIPickerView(frame: CGRect.zero)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: DashboardContainerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        debugTextView.backgroundColor = UIColor.black
        debugTextView.textColor = UIColor.lightText

        debugTextView.isEditable = false
        debugTextView.isScrollEnabled = false
        debugTextView.contentMode = .scaleAspectFit

        debugTextView.text = "Debug output:\n"

        getButton.isHidden = true
        getButton.setTitle("GET", for: .normal)
        getButton.setTitleColor(UIColor.lightText, for: .normal)
        getButton.tintColor = UIColor.black
        getButton.backgroundColor = UIColor.black
        getButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        getButton.layer.borderColor = UIColor.red.cgColor
        getButton.layer.borderWidth = 2.0
        getButton.layer.cornerRadius = 5.0
        getButton.addTarget(self, action: #selector(getAction), for: .touchUpInside)

        putButton.isHidden = true
        putButton.setTitle("PUT", for: .normal)
        putButton.setTitleColor(UIColor.lightText, for: .normal)
        putButton.tintColor = UIColor.black
        putButton.backgroundColor = UIColor.black
        putButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        putButton.layer.borderColor = UIColor.red.cgColor
        putButton.layer.borderWidth = 2.0
        putButton.layer.cornerRadius = 5.0
        putButton.addTarget(self, action: #selector(putAction), for: .touchUpInside)

        subscribeButton.isHidden = true
        subscribeButton.setTitle("SUBSCRIBE", for: .normal)
        subscribeButton.setTitleColor(UIColor.lightText, for: .normal)
        subscribeButton.tintColor = UIColor.black
        subscribeButton.backgroundColor = UIColor.black
        subscribeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        subscribeButton.layer.borderColor = UIColor.red.cgColor
        subscribeButton.layer.borderWidth = 2.0
        subscribeButton.layer.cornerRadius = 5.0
        subscribeButton.addTarget(self, action: #selector(subscribeAction), for: .touchUpInside)

        unsubscribeButton.isHidden = true
        unsubscribeButton.setTitle("UNSUBSCRIBE", for: .normal)
        unsubscribeButton.setTitleColor(UIColor.lightText, for: .normal)
        unsubscribeButton.tintColor = UIColor.black
        unsubscribeButton.backgroundColor = UIColor.black
        unsubscribeButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        unsubscribeButton.layer.borderColor = UIColor.red.cgColor
        unsubscribeButton.layer.borderWidth = 2.0
        unsubscribeButton.layer.cornerRadius = 5.0
        unsubscribeButton.addTarget(self, action: #selector(unsubscribeAction), for: .touchUpInside)

        parameterPicker.isHidden = true
        parameterPicker.delegate = self
        parameterPicker.dataSource = self
        parameterPicker.contentMode = .scaleAspectFit
        parameterPicker.showsSelectionIndicator = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.addObserver(self)

        layoutView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @objc private func getAction() {
        debugTextView.text.append("getAction\n")
        viewModel.requestMethod(.get, indices: [parameterPicker.selectedRow(inComponent: 0)])
    }

    @objc private func putAction() {
        debugTextView.text.append("putAction\n")
        viewModel.requestMethod(.put, indices: [parameterPicker.selectedRow(inComponent: 0)])
    }

    @objc private func subscribeAction() {
        debugTextView.text.append("subscribeAction\n")
        viewModel.requestMethod(.subscribe, indices: [parameterPicker.selectedRow(inComponent: 0)])
    }

    @objc private func unsubscribeAction() {
        debugTextView.text.append("unsubscribeAction\n")
        viewModel.requestMethod(.unsubscribe, indices: [parameterPicker.selectedRow(inComponent: 0)])
    }

    private func layoutView() {
        view.addSubview(debugTextView)
        view.addSubview(getButton)
        view.addSubview(putButton)
        view.addSubview(subscribeButton)
        view.addSubview(unsubscribeButton)
        view.addSubview(parameterPicker)

        debugTextView.translatesAutoresizingMaskIntoConstraints = false
        getButton.translatesAutoresizingMaskIntoConstraints = false
        putButton.translatesAutoresizingMaskIntoConstraints = false
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        unsubscribeButton.translatesAutoresizingMaskIntoConstraints = false
        parameterPicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [debugTextView.leftAnchor.constraint(equalTo: view.leftAnchor),
             debugTextView.topAnchor.constraint(equalTo: view.topAnchor),
             debugTextView.rightAnchor.constraint(equalTo: view.rightAnchor),
             debugTextView.heightAnchor.constraint(equalTo: debugTextView.widthAnchor)])

        NSLayoutConstraint.activate(
            [getButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
             getButton.topAnchor.constraint(equalTo: debugTextView.bottomAnchor, constant: 10.0)])

        NSLayoutConstraint.activate(
            [putButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
             putButton.topAnchor.constraint(equalTo: getButton.bottomAnchor, constant: 10.0)])

        NSLayoutConstraint.activate(
            [subscribeButton.leadingAnchor.constraint(greaterThanOrEqualTo: getButton.trailingAnchor, constant: 10.0),
             subscribeButton.topAnchor.constraint(equalTo: debugTextView.bottomAnchor, constant: 10.0),
             subscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0)])

        NSLayoutConstraint.activate(
            [unsubscribeButton.leadingAnchor.constraint(greaterThanOrEqualTo: putButton.trailingAnchor, constant: 10.0),
             unsubscribeButton.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 10.0),
             unsubscribeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0)])

        NSLayoutConstraint.activate(
            [parameterPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
             parameterPicker.topAnchor.constraint(equalTo: putButton.bottomAnchor, constant: 10.0),
             parameterPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
             parameterPicker.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -10),
             parameterPicker.heightAnchor.constraint(equalToConstant: 60.0)])

        view.layoutIfNeeded()
    }
}

extension DashboardOperationViewControllerDebug: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let debugEvent as DashboardObserverEventDebug: handleDebugEvent(debugEvent)
        case let containerEvent as DashboardObserverEventContainer: handleContainerEvent(containerEvent)
        default: return
        }
    }

    func handleDebugEvent(_ event: DashboardObserverEventDebug) {
        switch event {
        case .receivedResponse(let response): receivedResponse(response)
        case .receivedEvent(let event): receivedEvent(event)
        case .onError(let error): onError(error)
        }
    }

    func handleContainerEvent(_ event: DashboardObserverEventContainer) {
        switch event {
        case .editModeUpdate(let update): editModeUpdate(update)
        case .selectModeUpdate(let update, let enabled): selectModeUpdate(update, enabled: enabled)
        case .quantityUpdate: return
        case .onError(let error): onError(error)
        }
    }

    func receivedResponse(_ response: String) {
        DispatchQueue.main.async {
            self.debugTextView.text = response
        }
    }

    func receivedEvent(_ event: String) {
        DispatchQueue.main.async {
            self.debugTextView.text = event
        }
    }

    func editModeUpdate(_ update: Bool) {
        DispatchQueue.main.async {
            if update {
                self.getButton.isHidden = false
                self.putButton.isHidden = false
                self.subscribeButton.isHidden = false
                self.unsubscribeButton.isHidden = false
                self.parameterPicker.isHidden = false
            } else {
                self.getButton.isHidden = true
                self.putButton.isHidden = true
                self.subscribeButton.isHidden = true
                self.unsubscribeButton.isHidden = true
                self.parameterPicker.isHidden = true
            }
        }
    }

    func selectModeUpdate(_ update: Bool, enabled: Bool) {
        DispatchQueue.main.async {
            self.editModeUpdate(self.viewModel.isEditMode)
        }
    }

    func onError(_ error: String) {
        DispatchQueue.main.async {
            self.debugTextView.text = error
        }
    }
}

extension DashboardOperationViewControllerDebug: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.parameters.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.parameters[row]?.description
    }
}
