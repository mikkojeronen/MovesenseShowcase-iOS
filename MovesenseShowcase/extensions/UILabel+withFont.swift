//
// UILabel+withFont.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

extension UILabel {

    convenience init(with font: UIFont, inColor color: UIColor, lines: Int? = nil, text: String? = nil) {
        self.init()
        self.font = font
        self.textColor = color
        self.adjustsFontSizeToFitWidth = false

        if let lines = lines {
            setLines(lines)
        }

        if let text = text {
            self.text = text
        }
    }

    func setLines(_ lines: Int) {
        self.numberOfLines = lines
        self.adjustsFontSizeToFitWidth = false
        self.lineBreakMode = lines > 0 ? .byTruncatingTail : .byClipping
    }
}
