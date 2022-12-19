//
// CsvEncoder.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

public enum CsvEncoderError: Error {
    case operationError(_ description: String)
}

protocol CsvEncodingContainer: AnyObject {

    var data: Data { get }
}

public class CsvEncoder {

    func encode(_ value: Encodable) throws -> Data {
        let encoder = CsvEncoderConcrete()
        try value.encode(to: encoder)
        return encoder.data
    }
}

final class CsvEncoderConcrete {

    internal enum Constants {
        static let commaData: Data = Data([UInt8(0x2c)]) // Comma UTF8 code point 0x2c
        static let lfData: Data = Data([UInt8(0x0a)]) // Linefeed UTF8 code point 0x0a
    }

    fileprivate var container: CsvEncodingContainer?

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    var data: Data {
        return container?.data ?? Data()
    }
}

extension CsvEncoderConcrete: Encoder {

    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()

        let container = UnkeyedContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()

        let container = SingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }
}
