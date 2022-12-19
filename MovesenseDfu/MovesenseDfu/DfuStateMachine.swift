//
// DfuStateMachine.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import CoreBluetooth
import Foundation
import iOSDFULibrary

internal enum Constants {
    static let dfuUuid: CBUUID = CBUUID(string: "FE59")
}

internal protocol DfuStateMachineDelegate: class {

    func stateChanged(_ state: MovesenseDfuState)

    func discoveredDfuDevice(_ device: DfuDevice)

    func updateProgress(for part: Int, outOf totalParts: Int, to progress: Int,
                        currentSpeed: Double, avgSpeed: Double)
}

final internal class DfuStateMachine: NSObject {

    weak var delegate: DfuStateMachineDelegate?

    // Context for the state machine
    var dfuContainer: DfuContainer?
    var dfuSensor: MovesenseDfuDevice? // TODO: DfuDevice?
    var dfuPackage: MovesenseDfuPackage? // TODO: DfuPackage?
    var centralManager: CBCentralManager?

    let dfuContainerType: DfuContainer.Type
    let centralManagerType: CBCentralManager.Type

    private var currentState: DfuState?

    init(with centralManagerType: CBCentralManager.Type,
         dfuContainerType: DfuContainer.Type) {
        self.centralManagerType = centralManagerType
        self.dfuContainerType = dfuContainerType
        super.init()

        newState(DfuStateInit(self))
    }

    func startDfuScan() {
        currentState?.startDfuScan(self)
    }

    func stopDfuScan() {
        currentState?.stopDfuScan(self)
    }

    func updateSensor(_ dfuSensor: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage) {
        currentState?.updateSensor(self, dfuSensor: dfuSensor, dfuPackage: dfuPackage)
    }

    func resetDfu() {
        currentState?.resetState(self)
    }

    func newState(_ state: DfuState?) {
        guard let state = state else {
            let dfuError = MovesenseDfuError.integrityError("Tried to change to invalid state.")
            newState(DfuStateError(self, error: dfuError))

            return
        }

        currentState?.exitState(self)

        currentState = state
        delegate?.stateChanged(state.stateType)

        currentState?.enterState(self)
    }
}

extension DfuStateMachine: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        currentState?.btStateChanged(self, central: central)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {

        currentState?.discoveredSensor(self,
                                       central: central,
                                       peripheral: peripheral,
                                       advertisementData: advertisementData,
                                       rssi: RSSI)
    }
}

extension DfuStateMachine: DFUServiceDelegate {

    func dfuStateDidChange(to state: DFUState) {
        currentState?.dfuStateDidChange(self, to: state)
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        currentState?.dfuError(self, error: error, didOccurWithMessage: message)
    }
}

extension DfuStateMachine: DFUProgressDelegate {

    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                              currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        delegate?.updateProgress(for: part, outOf: totalParts, to: progress,
                                 currentSpeed: round(currentSpeedBytesPerSecond * 100) / 100,
                                 avgSpeed: round(avgSpeedBytesPerSecond * 100) / 100)
    }
}

extension DfuStateMachine: LoggerDelegate {

    func logWith(_ level: LogLevel, message: String) {
        // TODO
    }
}
