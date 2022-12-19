//
// DfuState.swift
// MovesenseDfu
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import CoreBluetooth
import Foundation
import iOSDFULibrary

internal protocol DfuState: class {

    var stateType: MovesenseDfuState { get }

    func enterState(_ stateMachine: DfuStateMachine)

    func exitState(_ stateMachine: DfuStateMachine)

    func resetState(_ stateMachine: DfuStateMachine)

    func startDfuScan(_ stateMachine: DfuStateMachine)

    func stopDfuScan(_ stateMachine: DfuStateMachine)

    func updateSensor(_ stateMachine: DfuStateMachine, dfuSensor: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage)

    func btStateChanged(_ stateMachine: DfuStateMachine, central: CBCentralManager)

    func discoveredSensor(_ stateMachine: DfuStateMachine, central: CBCentralManager, peripheral: CBPeripheral,
                          advertisementData: [String: Any], rssi: NSNumber)

    func dfuStateDidChange(_ stateMachine: DfuStateMachine, to state: DFUState)

    func dfuError(_ stateMachine: DfuStateMachine, error: DFUError, didOccurWithMessage message: String)
}

extension DfuState {

    func exitState(_ stateMachine: DfuStateMachine) {}

    func resetState(_ stateMachine: DfuStateMachine) {
        stateMachine.newState(DfuStateInit(stateMachine))
    }

    func startDfuScan(_ stateMachine: DfuStateMachine) {
        let dfuError = MovesenseDfuError.operationError("Trying to start sensors scan in wrong state (\(stateType.description)).")
        stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
    }

    func stopDfuScan(_ stateMachine: DfuStateMachine) {} // Do nothing

    func updateSensor(_ stateMachine: DfuStateMachine, dfuSensor: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage) {
        let dfuError = MovesenseDfuError.operationError("Trying to update sensor in wrong state (\(stateType.description)).")
        stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
    }

    func btStateChanged(_ stateMachine: DfuStateMachine, central: CBCentralManager) {
        NSLog("DfuState::btStateChanged(\(central.state.rawValue))")

        switch central.state {
        case .poweredOn: return
        default:
            let dfuError = MovesenseDfuError.operationError("Bluetooth changed to invalid state (\(stateType.description)).")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
        }
    }

    func discoveredSensor(_ stateMachine: DfuStateMachine, central: CBCentralManager, peripheral: CBPeripheral,
                          advertisementData: [String: Any], rssi: NSNumber) {
        let dfuError = MovesenseDfuError.operationError("DFU sensor discovery in wrong state (\(stateType.description)).")
        stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
    }

    func dfuStateDidChange(_ stateMachine: DfuStateMachine, to state: DFUState) {
        let dfuError = MovesenseDfuError.operationError("DFU state change in wrong state (\(stateType.description)).")
        stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
    }

    func dfuError(_ stateMachine: DfuStateMachine, error: DFUError, didOccurWithMessage message: String) {
        let dfuError = MovesenseDfuError.operationError(message)
        stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
    }
}

internal final class DfuStateInit: DfuState {

    private let workItem: DispatchWorkItem = DispatchWorkItem(block: {})

    let stateType: MovesenseDfuState = .dfuInit

    init(_ stateMachine: DfuStateMachine) {}

    func enterState(_ stateMachine: DfuStateMachine) {
        stateMachine.dfuSensor = nil
        stateMachine.dfuPackage = nil
        stateMachine.centralManager = stateMachine.centralManagerType.init(delegate: stateMachine,
                                                                           queue: DispatchQueue.global(),
                                                                           options: nil)

        // 1) Wait for workItem completion here, it's completed when Bluetooth state poweredOn is observed
        if workItem.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(1)) != .success,
           workItem.isCancelled == false {
            let dfuError = MovesenseDfuError.integrityError("Timeout initializing Bluetooth.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
        }
    }

    func exitState(_ stateMachine: DfuStateMachine) {
        workItem.cancel()
    }

    func btStateChanged(_ stateMachine: DfuStateMachine, central: CBCentralManager) {
        NSLog("DfuStateInit::btStateChanged(\(central.state.rawValue))")

        switch central.state {
        case .poweredOn: workItem.perform() // 2) Perform the workItem's empty block to complete the wait
        default:
            let dfuError = MovesenseDfuError.integrityError("Bluetooth changed to invalid state.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
        }
    }

    func startDfuScan(_ stateMachine: DfuStateMachine) {
        guard stateMachine.centralManager?.state == .poweredOn else {
            let errorMessage = "Trying to start discovery when Bluetooth is not powered on."
            let dfuError = MovesenseDfuError.integrityError(errorMessage)
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
            return
        }

        stateMachine.newState(DfuStateDiscovery(stateMachine))
    }

    func updateSensor(_ stateMachine: DfuStateMachine, dfuSensor: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage) {
        guard stateMachine.centralManager?.state == .poweredOn else {
            let dfuError = MovesenseDfuError.integrityError("Trying to start update when Bluetooth is not powered on.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
            return
        }

        stateMachine.dfuSensor = dfuSensor
        stateMachine.dfuPackage = dfuPackage

        stateMachine.newState(DfuStateUpdate(stateMachine))
    }
}

internal final class DfuStateDiscovery: DfuState {

    let stateType: MovesenseDfuState = .dfuDiscovery

    init(_ stateMachine: DfuStateMachine) {}

    func enterState(_ stateMachine: DfuStateMachine) {
        stateMachine.centralManager?.scanForPeripherals(withServices: [Constants.dfuUuid],
                                                        options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func exitState(_ stateMachine: DfuStateMachine) {
        stateMachine.centralManager?.stopScan()
    }

    func stopDfuScan(_ stateMachine: DfuStateMachine) {
        stateMachine.newState(DfuStateInit(stateMachine))
    }

    // If the state machine has dfuSensor set, continue to updating that if found, otherwise just
    // inform the delegate about the discovery
    func discoveredSensor(_ stateMachine: DfuStateMachine, central: CBCentralManager, peripheral: CBPeripheral,
                          advertisementData: [String: Any], rssi: NSNumber) {
        guard let peripheralName = peripheral.name else {
            // Not an error, just continue discovery for devices with the name set
            return
        }

        stateMachine.delegate?.discoveredDfuDevice(DfuDevice(localName: peripheralName,
                                                             uuid: peripheral.identifier,
                                                             rssi: rssi))
    }

    func updateSensor(_ stateMachine: DfuStateMachine, dfuSensor: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage) {
        guard stateMachine.centralManager?.state == .poweredOn else {
            let dfuError = MovesenseDfuError.integrityError("Trying to start update when Bluetooth is not powered on.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
            return
        }

        stateMachine.dfuSensor = dfuSensor
        stateMachine.dfuPackage = dfuPackage

        stateMachine.newState(DfuStateUpdate(stateMachine))
    }
}

internal final class DfuStateUpdate: DfuState {

    let stateType: MovesenseDfuState = .dfuUpdate

    init?(_ stateMachine: DfuStateMachine) {
        guard let fileUrl = stateMachine.dfuPackage?.fileUrl,
              let firmware = DFUFirmware(urlToZipFile: fileUrl) else {

            let dfuError = MovesenseDfuError.updateError("Invalid firmware.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))

            return nil
        }

        let dfuContainer = stateMachine.dfuContainerType.init(firmware: firmware)

        dfuContainer.dfuServiceDelegate = stateMachine
        dfuContainer.dfuProgressDelegate = stateMachine
        dfuContainer.loggerDelegate = stateMachine

        stateMachine.dfuContainer = dfuContainer
    }

    func enterState(_ stateMachine: DfuStateMachine) {
        stateMachine.centralManager?.scanForPeripherals(withServices: [Constants.dfuUuid],
                                                        options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func exitState(_ stateMachine: DfuStateMachine) {
        stateMachine.dfuContainer?.dfuServiceDelegate = nil
        stateMachine.dfuContainer?.dfuProgressDelegate = nil
        stateMachine.dfuContainer?.loggerDelegate = nil

        _ = stateMachine.dfuContainer?.abort()
    }

    func resetState(_ stateMachine: DfuStateMachine) {
        if stateMachine.dfuContainer?.abort() ?? false {
            stateMachine.newState(DfuStateInit(stateMachine))
        } else {
            let dfuError = MovesenseDfuError.updateError("Aborting update failed.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
        }
    }

    // If the state machine has dfuSensor set, continue to updating that if found
    func discoveredSensor(_ stateMachine: DfuStateMachine, central: CBCentralManager, peripheral: CBPeripheral,
                          advertisementData: [String: Any], rssi: NSNumber) {
        guard let peripheralName = peripheral.name else {
            // Not an error, just continue discovery for devices with the name set
            return
        }

        if let dfuSensor = stateMachine.dfuSensor,
           dfuSensor.deviceLocalName == peripheralName,
           dfuSensor.deviceUuid == peripheral.identifier {

            stateMachine.centralManager?.stopScan()

            if let dfuContainer = stateMachine.dfuContainer,
               dfuContainer.start(target: peripheral) == false {

                let dfuError = MovesenseDfuError.updateError("DFUServiceInitiator start failed.")
                stateMachine.newState(DfuStateError(stateMachine, error: dfuError))

                return
            }
        }
    }

    func dfuStateDidChange(_ stateMachine: DfuStateMachine, to state: DFUState) {
        switch state {
        case .completed:
            stateMachine.dfuContainer = nil
            stateMachine.newState(DfuStateCompleted(stateMachine))
        case .aborted:
            stateMachine.dfuContainer = nil
            let dfuError = MovesenseDfuError.updateError("Update aborted.")
            stateMachine.newState(DfuStateError(stateMachine, error: dfuError))
        default: return
        }
    }
}

internal final class DfuStateCompleted: DfuState {

    let stateType: MovesenseDfuState = .dfuCompleted

    init(_ stateMachine: DfuStateMachine) {}

    func enterState(_ stateMachine: DfuStateMachine) {
        stateMachine.dfuSensor = nil
        stateMachine.dfuPackage = nil
    }
}

internal final class DfuStateError: DfuState {

    var stateType: MovesenseDfuState {
        return MovesenseDfuState.dfuError(self.dfuError)
    }

    private let dfuError: MovesenseDfuError

    init(_ stateMachine: DfuStateMachine, error: MovesenseDfuError) {
        self.dfuError = error
        NSLog("DfuStateError(\(error.description)")
    }

    func enterState(_ stateMachine: DfuStateMachine) {
        stateMachine.dfuSensor = nil
        stateMachine.dfuPackage = nil
        stateMachine.centralManager?.stopScan()
    }
}
