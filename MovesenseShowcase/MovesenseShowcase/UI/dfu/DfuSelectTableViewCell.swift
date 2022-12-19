//
// DfuSelectTableViewCell.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import UIKit

class DfuSelectTableViewCell: UITableViewCell {

    private let radioButton: UIButton
    private let fileNameLabel: UILabel
    private let fileSizeLabel: UILabel

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.fileNameLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: UIColor.black, lines: 3)
        self.fileSizeLabel = UILabel(with: UIFont.systemFont(ofSize: 13), inColor: UIColor.gray)
        self.radioButton = UIButton(type: .custom)
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        fileNameLabel.lineBreakMode = .byWordWrapping

        radioButton.isUserInteractionEnabled = false
        radioButton.setImage(UIImage(named: "icon_radiobutton_selected"), for: .selected)
        radioButton.setImage(UIImage(named: "icon_radiobutton_unselected"), for: .normal)
        radioButton.imageView?.contentMode = .scaleAspectFit

        selectionStyle = UITableViewCell.SelectionStyle.none

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

    func setupView(fileName: String, fileSize: String) {
        fileNameLabel.text = fileName
        fileSizeLabel.text = fileSize

        layoutIfNeeded()
    }

    private func layoutView() {
        contentView.addSubview(radioButton)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileSizeLabel)

        radioButton.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fileSizeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [radioButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])

        NSLayoutConstraint.activate(
            [fileNameLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 16.0),
             fileNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
             fileNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)])

        NSLayoutConstraint.activate(
            [fileSizeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: fileNameLabel.trailingAnchor, constant: 8.0),
             fileSizeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             fileSizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)])
    }
}
