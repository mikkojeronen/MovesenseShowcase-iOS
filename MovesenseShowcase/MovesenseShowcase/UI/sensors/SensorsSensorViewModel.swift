//
// SensorsSensorViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum ObserverEventSensor: ObserverEvent {

    case sensorChangedState(_ state: DeviceConnectionState)
    case onError(_ error: Error)
}

protocol SensorsSensorViewModelDelegate: class {

    func connectPreviousSensor(_ sensor: DeviceViewModel)
    func disconnectPreviousSensor(_ sensor: DeviceViewModel)
    func forgetPreviousSensor(_ sensor: DeviceViewModel)
}

class SensorsSensorViewModel: Observable {

    private enum Constants {
        static let energyReadRetryCount: Int = 1
    }

    weak var delegate: SensorsSensorViewModelDelegate?

    private(set) var deviceViewModel: DeviceViewModel

    var sensorState: DeviceConnectionState { return deviceViewModel.state }

    var stateActionName: String {
        switch sensorState {
        case .discovered: return NSLocalizedString("SENSORS_ACTION_CONNECT", comment: "")
        case .disconnected: return NSLocalizedString("SENSORS_ACTION_CONNECT", comment: "")
        case .connecting: return NSLocalizedString("SENSORS_ACTION_CANCEL", comment: "")
        case .connected: return NSLocalizedString("SENSORS_ACTION_DISCONNECT", comment: "")
        }
    }

    var sensorName: String { return deviceViewModel.name }

    var sensorSerial: String { return deviceViewModel.serial }

    var sensorEnergy: String {
        if let percentage = sensorEnergyPercentage {
            return "\(NSLocalizedString("SENSORS_ENERGY_TITLE", comment: "")) \(percentage)%"
        }

        return ""
    }

    var isSensorEnergyLow: Bool {
        if let percentage = sensorEnergyPercentage {
            return percentage <= 20
        } else {
            return false
        }
    }

    var appName: String {
        if let name = appInfo?.name {
            return name
        } else {
            return "n/a"
        }
    }

    var appVersion: String {
        if let version = appInfo?.version {
            return version
        } else {
            return "n/a"
        }
    }

    var appCompany: String {
        if let company = appInfo?.company {
            return company
        } else {
            return "n/a"
        }
    }

    private var sensorEnergyPercentage: UInt8?
    private var appInfo: MovesenseAppInfo?

    internal var observations: [Observation] = [Observation]()
    private(set) var observationQueue: DispatchQueue = DispatchQueue.global()

    init(_ device: DeviceViewModel) {
        self.deviceViewModel = DeviceViewModel(device)
    }

    func updateState(_ viewModel: DeviceViewModel) {
        deviceViewModel = viewModel

        if deviceViewModel.state == .connected {
            updateSensorInfo()
        } else {
            notifyObservers(ObserverEventSensor.sensorChangedState(sensorState))
        }
    }

    func forgetAction(_ sender: Any) {
        delegate?.forgetPreviousSensor(deviceViewModel)
    }

    func stateAction(state: DeviceConnectionState) {
        guard sensorState == state else { return }

        switch state {
        case .disconnected: return
        case .discovered: connectDevice()
        case .connecting: disconnectDevice()
        case .connected: disconnectDevice()
        }
    }

    private func updateSensorInfo() {
        updateSensorEnergyLevel()
    }

    private func updateSensorEnergyLevel(_ attemptCount: Int = 0) {
        guard let device = (Movesense.api.getDevices().first { $0.serialNumber == deviceViewModel.serial }) else {
            return
        }

        let request = MovesenseRequest(resourceType: .systemEnergy, method: MovesenseMethod.get,
                                       parameters: nil)

        Movesense.api.sendRequestForDevice(device, request: request) { response in
            guard case let MovesenseObserverEventOperation.operationResponse(operationResponse) = response,
                  case let MovesenseResponse.systemEnergy(_, _, systemEnergy) = operationResponse else {

                NSLog("Invalid system energy response: \(response)")

                // After DFU reading system energy fails every time, retry once
                if case MovesenseObserverEventOperation.operationError(_) = response,
                   attemptCount < Constants.energyReadRetryCount {
                    self.updateSensorEnergyLevel(attemptCount + 1)
                } else {
                    self.sensorEnergyPercentage = nil
                    self.updateSensorAppInfo()
                }

                return
            }

            self.sensorEnergyPercentage = systemEnergy.percentage
            self.updateSensorAppInfo()
        }
    }

    private func updateSensorAppInfo() {
        guard let device = (Movesense.api.getDevices().first { $0.serialNumber == deviceViewModel.serial }) else {
            return
        }

        let request = MovesenseRequest(resourceType: .appInfo, method: MovesenseMethod.get, parameters: nil)

        Movesense.api.sendRequestForDevice(device, request: request) { response in
            guard case let MovesenseObserverEventOperation.operationResponse(operationResponse) = response,
                  case let MovesenseResponse.appInfo(_, _, appInfo) = operationResponse else {

                NSLog("Invalid app info response: \(response)")

                self.appInfo = nil
                self.notifyObservers(ObserverEventSensor.sensorChangedState(.connected))

                return
            }

            self.appInfo = appInfo
            self.notifyObservers(ObserverEventSensor.sensorChangedState(.connected))
        }
    }

    private func connectDevice() {
        delegate?.connectPreviousSensor(deviceViewModel)
    }

    private func disconnectDevice() {
        sensorEnergyPercentage = nil
        delegate?.disconnectPreviousSensor(deviceViewModel)
    }
}
