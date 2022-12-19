//
// DfuContainerMock.swift
// MovesenseDfu
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import CoreBluetooth
import Foundation
import iOSDFULibrary

class DfuContainerMock: DfuContainer {

    public static weak var instance: DfuContainerMock?

    public static var abortResponse: Bool = true
    public static var startResponse: Bool = true

    required init(firmware: DFUFirmware) {
        super.init(firmware: firmware)

        DfuContainerMock.instance = self
    }

    deinit {
        NSLog("DfuContainerMock::deinit")
    }

    // DFUServiceInitiator wrapper functions
    override func start(target: CBPeripheral) -> Bool {
        DispatchQueue.global().async {
            self.dfuProgressDidChange(for: 1, outOf: 1, to: 1,
                                      currentSpeedBytesPerSecond: 1.0,
                                      avgSpeedBytesPerSecond: 1.0)
        }
        return DfuContainerMock.startResponse
    }

    // DFUServiceController wrapper functions
    override func abort() -> Bool {
        DispatchQueue.global().async {
            self.dfuStateDidChange(to: DFUState.aborted)
        }

        return DfuContainerMock.abortResponse
    }

    internal func changeState(to state: DFUState) {
        DispatchQueue.global().async {
            self.dfuStateDidChange(to: state)
        }
    }
}

extension DfuContainerMock { // DFUServiceDelegate

    override func dfuStateDidChange(to state: DFUState) {
        dfuServiceDelegate?.dfuStateDidChange(to: state)
    }

    override func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuServiceDelegate?.dfuError(error, didOccurWithMessage: message)
    }
}

extension DfuContainerMock { // DFUProgressDelegate

    override func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                                       currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        dfuProgressDelegate?.dfuProgressDidChange(for: part, outOf: totalParts, to: progress,
                                                  currentSpeedBytesPerSecond: currentSpeedBytesPerSecond,
                                                  avgSpeedBytesPerSecond: avgSpeedBytesPerSecond)
    }
}

extension DfuContainerMock { // LoggerDelegate

    override func logWith(_ level: LogLevel, message: String) {
        loggerDelegate?.logWith(level, message: message)
    }
}
