//
// NSAttributedString+withLocalizedHtmlString.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

extension NSAttributedString {

    convenience init?(withLocalizedHTMLString: String) {
        guard let stringData = withLocalizedHTMLString.data(using: String.Encoding.utf8) else {
            return nil
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]

        try? self.init(data: stringData, options: options, documentAttributes: nil)
    }
}
