//
// RecordingsTableViewCell.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class RecordingsTableViewCell: UITableViewCell {

    private let resourceLabel: UILabel
    private let dateLabel: UILabel
    private let serialLabel: UILabel
    private let sizeLabel: UILabel
    private let radioButton: UIButton
    private let detailsButton: UIButton

    private var radioConstraint: NSLayoutConstraint?
    private var detailsConstraint: NSLayoutConstraint?

    private var cellAction: (() -> Void)?

    override var selectionStyle: SelectionStyle {
        get {
            return super.selectionStyle
        }

        set {
            super.selectionStyle = .none

            contentView.isUserInteractionEnabled = newValue == .none ? true : false

            UIView.animate(withDuration: 0.35, animations: {
                self.radioConstraint?.constant = newValue == .none ? -16.0 : 16.0
                self.detailsConstraint?.constant = newValue == .none ? -16.0 : 16.0
                self.layoutIfNeeded()
            })
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.resourceLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: UIColor.titleTextBlack)
        self.dateLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: UIColor.titleTextBlack)
        self.serialLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: UIColor.titleTextBlack)
        self.sizeLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: UIColor.titleTextBlack)
        self.radioButton = UIButton(type: .custom)
        self.detailsButton = UIButton(type: .custom)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        detailsButton.isUserInteractionEnabled = false
        detailsButton.setImage(UIImage(named: "icon_arrow_right_red_gradient"), for: .normal)
        detailsButton.contentMode = .scaleAspectFit

        radioButton.isUserInteractionEnabled = false
        radioButton.setImage(UIImage(named: "icon_radiobutton_selected"), for: .selected)
        radioButton.setImage(UIImage(named: "icon_radiobutton_unselected"), for: .normal)

        selectionStyle = UITableViewCell.SelectionStyle.none

        contentView.isUserInteractionEnabled = true
        contentView.addTapGesture(tapNumber: 1, target: self, action: #selector(detailsAction))

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        radioButton.isSelected = selected
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setupView(viewModel: RecordingViewModel, action: @escaping () -> Void) {
        resourceLabel.text = viewModel.resourceAbbreviation
        dateLabel.text = viewModel.timeShort
        serialLabel.text = viewModel.sensorSerial
        sizeLabel.text = viewModel.streamSize
        cellAction = action
    }

    @objc private func detailsAction() {
        contentView.backgroundColor = UIColor.lightGray

        cellAction?()

        UIView.animate(withDuration: 0.35, animations: {
            self.contentView.backgroundColor = UIColor.white
        })
    }

    private func layoutView() {
        contentView.addSubview(radioButton)
        contentView.addSubview(dateLabel)
        contentView.addSubview(resourceLabel)
        contentView.addSubview(serialLabel)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(detailsButton)

        radioButton.translatesAutoresizingMaskIntoConstraints = false
        resourceLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        serialLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])

        radioConstraint = radioButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -16.0)
        radioConstraint?.isActive = true

        NSLayoutConstraint.activate(
            [dateLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 16.0),
             dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
             dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)])

        NSLayoutConstraint.activate(
            [resourceLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8.0),
             resourceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [serialLabel.leadingAnchor.constraint(equalTo: resourceLabel.trailingAnchor, constant: 8.0),
             serialLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [sizeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: serialLabel.trailingAnchor, constant: 8.0),
             sizeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [detailsButton.leadingAnchor.constraint(equalTo: sizeLabel.trailingAnchor, constant: 24.0),
             detailsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])

        detailsConstraint = detailsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
        detailsConstraint?.isActive = true
    }
}
