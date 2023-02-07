//
// KeyedEncodingContainer.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

extension CsvEncoderConcrete {

    final class KeyedContainer<Key> where Key: CodingKey {

        private var storage: [(CsvCodingKey, CsvEncodingContainer)] = []

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension CsvEncoderConcrete.KeyedContainer: KeyedEncodingContainerProtocol {

    func encodeNil(forKey key: Key) throws {
        var container = nestedSingleValueContainer(forKey: key)
        try container.encodeNil()
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        var container = nestedSingleValueContainer(forKey: key)
        try container.encode(value)
    }

    private func nestedSingleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
        let container = CsvEncoderConcrete.SingleValueContainer(codingPath: nestedCodingPath(forKey: key), userInfo: userInfo)
        storage.append((CsvCodingKey(stringValue: key.stringValue, intValue: key.intValue), container))

        return container
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {

        fatalError("Unimplemented")
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Unimplemented")
    }
}

extension CsvEncoderConcrete.KeyedContainer: CsvEncodingContainer {

    var data: Data {
        var myData = Data()

        for (_, container) in self.storage {
            myData.append(container.data)
            myData.append(CsvEncoderConcrete.Constants.commaData)
        }

        // Drop the last comma
        myData = myData.dropLast()

        return myData
    }
}
