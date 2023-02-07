//
// FileHandle+readLine.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

extension FileHandle {

    public func readLine(delimiter: String) -> Data? {
        guard let delimData: Data = delimiter.data(using: .utf8) else { return nil }

        let bufferSize: Int = 4096
        var dataBuffer: Data = Data(capacity: bufferSize)

        repeat {
            let readBuffer = readData(ofLength: bufferSize)
            dataBuffer.append(readBuffer)

            if let range = dataBuffer.range(of: delimData) {
                let lineData = dataBuffer.subdata(in: 0..<range.upperBound)
                let offset = UInt64(dataBuffer.count - lineData.count)
                let fileOffset = offsetInFile - offset

                seek(toFileOffset: fileOffset)

                return lineData
            }

            if (readBuffer.count > 0) == false {
                return nil
            }

        } while (dataBuffer.count > 0)

        return nil
    }
}
