//
// DfuSelectViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DfuSelectViewController: UIViewController {

    private let viewModel: DfuViewModel

    private let uploadedFilesLabel: UILabel
    private let uploadedFilesSeparator: UIView
    private let placeholderImageView: UIImageView
    private let placeholderLabel: UILabel
    private let tableView: UITableView
    private let backItem: UIBarButtonItem
    private let trashItem: UIBarButtonItem
    private let actionView: ActionButtonView = ActionButtonView()
    private var actionConstraint: NSLayoutConstraint?

    init(viewModel: DfuViewModel) {
        self.viewModel = viewModel

        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.uploadedFilesLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                          inColor: UIColor.titleTextBlack.withAlphaComponent(0.6), lines: 1,
                                          text: NSLocalizedString("DFU_SELECT_UPLOADED_FILES_TITLE", comment: ""))
        self.uploadedFilesSeparator = UIView.separator(separatorHeight: 2.0)

        self.placeholderImageView = UIImageView(image: UIImage(named: "image_placeholder"))
        self.placeholderLabel = UILabel(with: UIFont.systemFont(ofSize: 13.0, weight: .regular),
                                        inColor: UIColor.titleTextBlack, lines: 1,
                                        text: NSLocalizedString("DFU_SELECT_PLACEHOLDER_TITLE", comment: ""))

        self.backItem = UIBarButtonItem()
        self.trashItem = UIBarButtonItem()

        super.init(nibName: nil, bundle: nil)

        uploadedFilesLabel.textAlignment = .left

        actionView.alpha = 0.0
        actionView.setAction(target: self, action: #selector(updateAction), for: .touchUpInside,
                             actionName: NSLocalizedString("DFU_SELECT_ACTION_TITLE", comment: ""))

        placeholderImageView.contentMode = .scaleAspectFit
        placeholderImageView.isHidden = true

        placeholderLabel.textAlignment = .center

        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.estimatedRowHeight = 45.0
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.delegate = self
        tableView.dataSource = self

        backItem.target = self
        backItem.action = #selector(backAction)
        backItem.image = UIImage(named: "icon_back")
        backItem.tintColor = UIColor.titleTextBlack

        trashItem.target = self
        trashItem.action = #selector(trashAction)
        trashItem.image = UIImage(named: "icon_trashcan")
        trashItem.tintColor = UIColor.titleTextBlack
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)

        view.backgroundColor = UIColor.white

        navigationItem.title = NSLocalizedString("DFU_SELECT_TITLE", comment: "")
        navigationItem.leftBarButtonItem = backItem
        navigationItem.rightBarButtonItem = trashItem

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(DfuSelectTableViewCell.self,
                           forCellReuseIdentifier: "DfuSelectTableViewCell")

        layoutView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionView.topShadow(color: UIColor.black, opacity: 0.2, radius: 5)
    }

    @objc private func applicationDidBecomeActive() {
        tableView.dataSource = self
        tableView.reloadData()
    }

    @objc private func applicationWillResignActive() {
        tableView.dataSource = nil
        tableView.reloadData()

        actionConstraint?.constant = 0.0
        actionView.alpha = 0.0
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func trashAction() {
        if let item = tableView.indexPathForSelectedRow?.item {
            viewModel.removeDfuPackage(item)
            tableView.reloadData()

            UIView.animate(withDuration: 0.5, animations: {
                self.actionConstraint?.constant = 0
                self.actionView.alpha = 0.0
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc private func updateAction() {
        guard let selectedItem = tableView.indexPathForSelectedRow?.item else { return }

        if let package = viewModel.getAddedDfuPackages()[safe: selectedItem],
           let navigationController = navigationController {

            viewModel.selectedPackage = package

            if let sensorSerial = viewModel.sensorViewModel?.sensorSerial {
                viewModel.requestDfuMode(sensorSerial)
            }

            let dfuList = UINavigationController(rootViewController: DfuTargListViewController(viewModel: viewModel))
            navigationController.present(dfuList, animated: true) {
                navigationController.popViewController(animated: true)
            }
        }
    }

    private func layoutView() {
        view.addSubview(uploadedFilesLabel)
        view.addSubview(uploadedFilesSeparator)
        view.addSubview(tableView)
        view.addSubview(actionView)
        view.addSubview(placeholderImageView)
        placeholderImageView.addSubview(placeholderLabel)

        uploadedFilesLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadedFilesSeparator.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        actionView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [uploadedFilesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             uploadedFilesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
             uploadedFilesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        NSLayoutConstraint.activate(
            [uploadedFilesSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             uploadedFilesSeparator.topAnchor.constraint(equalTo: uploadedFilesLabel.bottomAnchor, constant: 8.0),
             uploadedFilesSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             tableView.topAnchor.constraint(equalTo: uploadedFilesSeparator.bottomAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

        NSLayoutConstraint.activate(
            [actionView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
             actionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             actionView.widthAnchor.constraint(equalTo: view.widthAnchor),
             actionView.heightAnchor.constraint(equalToConstant: 125.0)])

        NSLayoutConstraint.activate(
            [placeholderImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor),
             placeholderImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             placeholderImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

        NSLayoutConstraint.activate(
            [placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
             placeholderLabel.centerYAnchor.constraint(equalTo: placeholderImageView.centerYAnchor),
             placeholderLabel.widthAnchor.constraint(equalTo: placeholderImageView.widthAnchor, constant: -32.0)])

        actionConstraint = actionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        actionConstraint?.isActive = true

        view.layoutIfNeeded()
    }
}

extension DfuSelectViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel.getAddedDfuPackages().count

        if rows < 1 {
            trashItem.isEnabled = false
            placeholderImageView.isHidden = false
            uploadedFilesLabel.isHidden = true
            uploadedFilesSeparator.isHidden = true
        } else {
            trashItem.isEnabled = true
            placeholderImageView.isHidden = true
            uploadedFilesLabel.isHidden = false
            uploadedFilesSeparator.isHidden = false
        }

        return rows
    }
}

extension DfuSelectViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DfuSelectTableViewCell",
                                                       for: indexPath) as? DfuSelectTableViewCell else {
            NSLog("Invalid reusable tableview cell in SensorsSensorDfuSelectViewController.")
            return UITableViewCell()
        }

        if let package = viewModel.getAddedDfuPackages()[safe: indexPath.item] {
            cell.setupView(fileName: package.fileName, fileSize: package.fileSize)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, animations: {
            self.actionConstraint?.constant = -self.actionView.frame.height
            self.actionView.alpha = 1.0
            self.trashItem.isEnabled = true
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if self.tableView.numberOfSections >= indexPath.section &&
               self.tableView.numberOfRows(inSection: indexPath.section) >= indexPath.row {
                self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
            }
        })
    }
}
