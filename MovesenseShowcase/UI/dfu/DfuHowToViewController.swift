//
// DfuHowToViewController.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DfuHowToViewController: UIViewController {

    private let viewModel: DfuHowToViewModel
    private let addingFilesLabel: UILabel
    private let tableView: UITableView
    private let faqFooter: DfuHowToFooterView
    private let backItem: UIBarButtonItem

    init() {
        self.viewModel = DfuHowToViewModel()
        self.addingFilesLabel = UILabel(with: UIFont.systemFont(ofSize: 17.0, weight: .semibold),
                                        inColor: UIColor.titleTextBlack, lines: 1,
                                        text: NSLocalizedString("DFU_HOWTO_ADDING_FILES_TITLE", comment: ""))
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        self.faqFooter = DfuHowToFooterView()
        self.backItem = UIBarButtonItem()

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = UIColor.white

        addingFilesLabel.textAlignment = .left

        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        tableView.allowsSelectionDuringEditing = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

        backItem.target = self
        backItem.action = #selector(backAction)
        backItem.image = UIImage(named: "icon_back")
        backItem.tintColor = UIColor.titleTextBlack

        faqFooter.addTapGesture(tapNumber: 1, target: self, action: #selector(footerTapAction))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("DFU_HOWTO_NAV_TITLE", comment: "")
        navigationItem.leftBarButtonItem = backItem

        navigationController?.navigationBar.barTintColor = UIColor.navigationBarTint
        navigationController?.navigationBar.backgroundColor = nil
        navigationController?.navigationBar.isTranslucent = false

        tableView.register(DfuHowToTableViewCell.self, forCellReuseIdentifier: "DfuHowToTableViewCell")

        layoutView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Get the tableview to layout the footer properly
        tableView.tableFooterView = faqFooter

        faqFooter.setNeedsLayout()
        faqFooter.layoutIfNeeded()

        faqFooter.frame.size = faqFooter.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        tableView.tableFooterView = faqFooter
    }

    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func footerTapAction() {
        faqFooter.backgroundColor = UIColor.lightGray
        navigationController?.pushViewController(FaqViewController(), animated: true)

        UIView.animate(withDuration: 0.35, animations: {
            self.faqFooter.backgroundColor = UIColor.white
        })
    }

    private func layoutView() {
        view.addSubview(addingFilesLabel)
        view.addSubview(tableView)

        addingFilesLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [addingFilesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             addingFilesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22.0),
             addingFilesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)])

        NSLayoutConstraint.activate(
            [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
             tableView.topAnchor.constraint(equalTo: addingFilesLabel.bottomAnchor, constant: 8.0),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
             tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        view.layoutIfNeeded()
    }
}

extension DfuHowToViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.steps.count
    }
}

extension DfuHowToViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DfuHowToTableViewCell",
                                                       for: indexPath) as? DfuHowToTableViewCell else {
            NSLog("Invalid reusable tableview cell in DfuHowToTableViewCell.")
            return UITableViewCell()
        }

        if let stepContent = viewModel.steps[safe: indexPath.item] {
            cell.setupView(stepText: stepContent.text, stepImage: stepContent.image)
        }

        return cell
    }
}
