//
// RecorderFileJson.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

struct RecorderFile: Codable {

    let uuid: UUID
    let fileVersion: Int
    let filePath: String
    let fileSize: Int64
    let serialNumber: String
    let resourceType: MovesenseResourceType
    let startDate: Date
    let endDate: Date
    let parameters: [String: String]?
}

class RecorderFileJson {

    internal enum Constants {
        static let fileVersion: Int = 1
        static let headerPrefix: String = ""
        static let streamPrefix: String = ""
        static let headerSuffix: String = "_header.json"
        static let streamSuffix: String = "_stream.json"
        static let lfData: Data = Data([UInt8(0x0a)]) // Linefeed UTF8 code point 0x0a
    }

    weak var delegate: RecorderDelegate?

    private let device: MovesenseDevice
    private let operation: MovesenseOperation
    private let jsonEncoder: JSONEncoder = JSONEncoder()

    private let streamQueue: DispatchQueue = DispatchQueue(label: "com.movesense.recorderFileJson")

    private var streamFilePath: String?
    private var streamFileHandle: FileHandle?

    init(device: MovesenseDevice, operation: MovesenseOperation) {
        self.device = device
        self.operation = operation

        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    func startRecording(_ date: Date) {
        streamQueue.sync {
            guard let (streamPath, streamFile) = openFile(date, prefix: Constants.streamPrefix,
                                                          suffix: Constants.streamSuffix) else {
                delegate?.recorderError(self, AppError.operationError("RecorderFile::startRecording failed."))
                return
            }

            streamFilePath = streamPath
            streamFileHandle = streamFile

            operation.addObserver(self)
        }
    }

    func stopRecording(_ date: Date) {
        streamQueue.sync {
            operation.removeObserver(self)

            streamFileHandle?.closeFile()
            streamFileHandle = nil

            writeHeader(date)
        }
    }

    private func openFile(_ date: Date, prefix: String, suffix: String) -> (String, FileHandle)? {
        guard let storageUrl: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            let error = AppError.operationError("RecorderFile::openFile unable to get documents dir")
            NSLog(error.localizedDescription)
            delegate?.recorderError(self, error)
            return nil
        }

        let resource: String = operation.operationRequest.resourceType.rawValue
        let recordPath: String = "/recordings/" + date.iso8601 + "/" + device.serialNumber + "/" + resource
        let operationPath: String = storageUrl.path + recordPath

        do {
            try FileManager.default.createDirectory(atPath: operationPath, withIntermediateDirectories: true)
        } catch let error {
            NSLog("RecorderFile::openFile create directory error: \(error)")
            delegate?.recorderError(self, error)
            return nil
        }

        let fileName: String = prefix + resource + suffix
        let fullPath: String = operationPath + "/" + fileName

        guard FileManager.default.createFile(atPath: fullPath, contents: nil),
              let handle = FileHandle(forWritingAtPath: fullPath) else {

            let error = AppError.operationError("RecorderFile::openFile file creation error")
            NSLog(error.localizedDescription)
            delegate?.recorderError(self, error)
            return nil
        }

        // Return the relative file path in the storage directory
        let relativePath = recordPath + "/" + fileName
        return (relativePath, handle)
    }

    private func writeHeader(_ date: Date) {
        guard let (_, headerFile) = openFile(date, prefix: Constants.headerPrefix,
                                             suffix: Constants.headerSuffix),
              let streamPath = streamFilePath,
              let streamSize = getFileSize(streamPath) else {

            delegate?.recorderError(self, AppError.operationError("RecorderFile::stopRecording header open failed."))
            return
        }

        let parameters = operation.operationRequest.parameters?.reduce(into: [:]) { result, parameter in
            result[parameter.name] = parameter.valueWithUnit
        }

        let header = RecorderFile(uuid: UUID(),
                                  fileVersion: Constants.fileVersion,
                                  filePath: streamPath,
                                  fileSize: streamSize,
                                  serialNumber: device.serialNumber,
                                  resourceType: operation.operationRequest.resourceType,
                                  startDate: date,
                                  endDate: Date(),
                                  parameters: parameters)

        guard let headerData = try? jsonEncoder.encode(header) else {
            delegate?.recorderError(self, AppError.operationError("RecorderFile::stopRecording header encode failed."))
            return
        }

        headerFile.write(headerData)
        headerFile.closeFile()
    }

    private func getFileSize(_ filePath: String) -> Int64? {
        guard let storageUrl: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
              let attr = try? FileManager.default.attributesOfItem(atPath: storageUrl.path + filePath) else {

            delegate?.recorderError(self, AppError.operationError("RecorderFile::getFileSize failed getting attributes."))
            return nil
        }

        return attr[FileAttributeKey.size] as? Int64
    }
}

extension RecorderFileJson: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventOperation else { return }

        switch event {
        case .operationEvent(let event): encodeEvent(event)
        case .operationResponse: return
        case .operationFinished, .operationError: return // TODO: Close file
        }
    }

    func encodeEvent(_ event: MovesenseEvent) {
        guard let data = try? jsonEncoder.encode(event) else {
            // TODO: Generate error
            return
        }

        streamQueue.sync {
            streamFileHandle?.write(data + Constants.lfData)
        }
    }
}

extension RecorderFileJson: Equatable {

    public static func == (lhs: RecorderFileJson, rhs: RecorderFileJson) -> Bool {
        return lhs.device === rhs.device &&
               lhs.operation === rhs.operation
    }
}
