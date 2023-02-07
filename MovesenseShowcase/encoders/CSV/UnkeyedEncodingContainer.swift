//
// UnkeyedEncodingContainer.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

extension CsvEncoderConcrete {

    final class UnkeyedContainer {

        private var storage: [CsvEncodingContainer] = []

        var codingPath: [CodingKey]

        var count: Int {
            return storage.count
        }

        var nestedCodingPath: [CodingKey] {
            guard let codingKey = CsvCodingKey(intValue: count) else {
                return codingPath
            }

            return codingPath + [codingKey]
        }

        var userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension CsvEncoderConcrete.UnkeyedContainer: UnkeyedEncodingContainer {

    func encodeNil() throws {
        var container = nestedSingleValueContainer()
        try container.encodeNil()
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        var container = nestedSingleValueContainer()
        try container.encode(value)
    }

    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        let container = CsvEncoderConcrete.SingleValueContainer(codingPath: nestedCodingPath, userInfo: userInfo)
        storage.append(container)

        return container
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) ->
        KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {

        fatalError("Unimplemented")
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }

    func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }
}

extension CsvEncoderConcrete.UnkeyedContainer: CsvEncodingContainer {

    var data: Data {
        var myData = Data()

        for container in self.storage {
            myData.append(container.data)
            myData.append(CsvEncoderConcrete.Constants.lfData)
            myData.append(CsvEncoderConcrete.Constants.commaData)
        }

        // Drop the last ln & comma
        myData = myData.dropLast(2)

        return myData
    }
}
