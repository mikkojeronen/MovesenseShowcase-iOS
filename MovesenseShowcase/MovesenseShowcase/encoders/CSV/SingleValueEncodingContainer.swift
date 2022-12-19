//
// SingleValueEncodingContainer.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

extension CsvEncoderConcrete {

    final class SingleValueContainer {

        private var storage: Data = Data()

        private var canEncodeNewValue: Bool {
            return self.storage.isEmpty
        }

        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension CsvEncoderConcrete.SingleValueContainer: SingleValueEncodingContainer {

    fileprivate func checkCanEncodeNewValue() throws {
        if self.canEncodeNewValue == false {
            let error = "Attempt to encode value through single value container when previously value already encoded."
            throw CsvEncoderError.operationError(error)
        }
    }

    func encodeNil() throws {
        try checkCanEncodeNewValue()
        storage.append(Data())
    }

    func utf8StringToData(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8) else {
            let context = EncodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unable to encode UTF8 to data.")
            throw EncodingError.invalidValue(string as Any, context)
        }

        return data
    }

    func encode(_ value: Bool) throws {
        try checkCanEncodeNewValue()
        switch value {
        case true: storage.append(try utf8StringToData("1"))
        case false: storage.append(try utf8StringToData("0"))
        }
    }

    func encode(_ value: String) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(value))
    }

    func encode(_ value: Double) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: Float) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: Int) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: Int8) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: Int16) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: Int32) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: Int64) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: UInt) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: UInt8) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: UInt16) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: UInt32) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode(_ value: UInt64) throws {
        try checkCanEncodeNewValue()
        storage.append(try utf8StringToData(String(value)))
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        try checkCanEncodeNewValue()

        let encoder = CsvEncoderConcrete()
        try value.encode(to: encoder)
        storage.append(encoder.data)
    }
}

extension CsvEncoderConcrete.SingleValueContainer: CsvEncodingContainer {

    var data: Data {
        return storage
    }
}
