//
// CsvCodingKey.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

struct CsvCodingKey: CodingKey, Equatable {

    var stringValue: String
    var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    fileprivate init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
}

extension CsvCodingKey: Hashable {

    func hash(into hasher: inout Hasher) {
        if let intValue = intValue {
            hasher.combine(intValue)
        } else {
            hasher.combine(stringValue)
        }
    }
}
