//
// DfuContainer.swift
// MovesenseDfu
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import CoreBluetooth
import Foundation
import iOSDFULibrary

internal class DfuContainer {

    weak var dfuServiceDelegate: DFUServiceDelegate?
    weak var dfuProgressDelegate: DFUProgressDelegate?
    weak var loggerDelegate: LoggerDelegate?

    let dfuServiceInitiator: DFUServiceInitiator

    var dfuServiceController: DFUServiceController?

    required init(firmware: DFUFirmware) {
        self.dfuServiceInitiator = DFUServiceInitiator().with(firmware: firmware)
        self.dfuServiceInitiator.delegate = self
        self.dfuServiceInitiator.progressDelegate = self
        self.dfuServiceInitiator.logger = self
        self.dfuServiceInitiator.packetReceiptNotificationParameter = 0 // Disable notifications for small speed increase
    }

    deinit {
        NSLog("DfuContainer::deinit")
    }

    // DFUServiceInitiator wrapper functions
    func start(target: CBPeripheral) -> Bool {
        guard let dfuController = dfuServiceInitiator.start(target: target) else { return false }

        dfuServiceController = dfuController

        return true
    }

    // DFUServiceController wrapper functions
    func abort() -> Bool {
        guard let dfuController = dfuServiceController else { return false }

        return dfuController.abort()
    }
}

extension DfuContainer: DFUServiceDelegate {

    func dfuStateDidChange(to state: DFUState) {
        dfuServiceDelegate?.dfuStateDidChange(to: state)
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        dfuServiceDelegate?.dfuError(error, didOccurWithMessage: message)
    }
}

extension DfuContainer: DFUProgressDelegate {

    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                              currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        dfuProgressDelegate?.dfuProgressDidChange(for: part, outOf: totalParts, to: progress,
                                                  currentSpeedBytesPerSecond: currentSpeedBytesPerSecond,
                                                  avgSpeedBytesPerSecond: avgSpeedBytesPerSecond)
    }
}

extension DfuContainer: LoggerDelegate {

    func logWith(_ level: LogLevel, message: String) {
        loggerDelegate?.logWith(level, message: message)
    }
}
