//
// ConnectTableViewCell.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class ConnectTableViewCell: UITableViewCell {

    fileprivate let serialLabel: UILabel
    fileprivate let nameLabel: UILabel
    fileprivate let rssiLabel: UILabel

    fileprivate let iconView: UIImageView = UIImageView(image: UIImage(named: "icon_m_unselected"),
                                                        highlightedImage: UIImage(named: "icon_m_selected"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        serialLabel = UILabel(with: UIFont.systemFont(ofSize: 20), inColor: UIColor.black)
        nameLabel = UILabel(with: UIFont.systemFont(ofSize: 17), inColor: UIColor.black)
        rssiLabel = UILabel(with: UIFont.systemFont(ofSize: 13), inColor: UIColor.gray)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit

        selectionStyle = UITableViewCell.SelectionStyle.none

        layoutView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        iconView.isHighlighted = selected
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets.init(top: 24, left: 16, bottom: 24, right: 16))
    }

    func setupView(serial: String?, name: String, rssi: String) {
        if let serial = serial {
            serialLabel.textColor = UIColor.black
            serialLabel.text = serial
        } else {
            serialLabel.textColor = UIColor.lightGray
            serialLabel.text = NSLocalizedString("CONNECT_SENSOR_SERIAL_NOT_AVAILABLE", comment: "")
        }

        nameLabel.text = name
        rssiLabel.text = rssi
    }

    private func layoutView() {
        contentView.addSubview(iconView)
        contentView.addSubview(serialLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(rssiLabel)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        serialLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        rssiLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [iconView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
             iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
             iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0)])

        NSLayoutConstraint.activate(
            [serialLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 23.0),
             serialLabel.topAnchor.constraint(equalTo: contentView.topAnchor)])

        NSLayoutConstraint.activate(
            [nameLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 23.0),
             nameLabel.topAnchor.constraint(equalTo: serialLabel.bottomAnchor, constant: 3.0),
             nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)])

        NSLayoutConstraint.activate(
            [rssiLabel.leftAnchor.constraint(greaterThanOrEqualTo: nameLabel.rightAnchor),
             rssiLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
             rssiLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor)])
    }
}
