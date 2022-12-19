//
// SensorsViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum ObserverEventSensors: ObserverEvent {

    case sensorDiscovered(_ sensor: SensorsSensorViewModel)
    case sensorAdded(_ sensor: SensorsSensorViewModel)
    case sensorRemoved(_ sensor: SensorsSensorViewModel)
    case onError(_ error: Error)
}

class SensorsViewModel: Observable {

    private(set) var previousSensors: [SensorsSensorViewModel] {
        didSet(oldValue) {
            Settings.previousSensors = previousSensors.map { $0.deviceViewModel }
        }
    }

    internal var observations: [Observation] = [Observation]()
    private(set) var observationQueue: DispatchQueue = DispatchQueue.global()

    init() {
        previousSensors = Settings.previousSensors.map { SensorsSensorViewModel(DeviceViewModel($0, newState: .disconnected)) }
        previousSensors.forEach {
            $0.delegate = self
        }

        Movesense.api.addObserver(self)
    }

    func resetDeviceStates() {
        Movesense.api.resetScan()

        previousSensors.filter { $0.sensorState == .discovered }.forEach {
            $0.updateState(DeviceViewModel($0.deviceViewModel, newState: .disconnected))
        }
    }

    func startDevicesScan() {
        Movesense.api.startScan()
    }

    func stopDevicesScan() {
        Movesense.api.stopScan()
    }
}

extension SensorsViewModel: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let event as MovesenseObserverEventApi: handleEventApi(event)
        default: return
        }
    }

    private func handleEventApi(_ event: MovesenseObserverEventApi) {
        switch event {
        case .apiDeviceConnecting(let device): apiDeviceConnecting(device)
        case .apiDeviceDiscovered(let device): apiDeviceDiscovered(device)
        case .apiDeviceConnected(let device): updateSensorState(device)
        case .apiDeviceDisconnected(let device): apiDeviceDisconnected(device)
        case .apiDeviceOperationInitiated: return
        case .apiError(let error): apiError(error)
        }
    }

    private func apiDeviceDiscovered(_ device: MovesenseDevice) {
        guard let previousSensor = (previousSensors.first { $0.sensorSerial == device.serialNumber }) else { return }
        previousSensor.updateState(DeviceViewModel(previousSensor.deviceViewModel, newState: .discovered))
    }

    private func apiDeviceDisconnected(_ device: MovesenseDevice) {
        resetDeviceStates()
        updateSensorState(device)
        startDevicesScan()
    }

    private func apiDeviceConnecting(_ device: MovesenseDevice) {
        if (previousSensors.contains { $0.sensorSerial == device.serialNumber }) == false {
            let sensorViewModel = SensorsSensorViewModel(DeviceViewModel(device))
            sensorViewModel.delegate = self
            previousSensors.insert(sensorViewModel, at: 0)
            notifyObservers(ObserverEventSensors.sensorAdded(sensorViewModel))
        } else {
            updateSensorState(device)
        }
    }

    private func updateSensorState(_ device: MovesenseDevice) {
        guard let previousSensor = (previousSensors.first { $0.sensorSerial == device.serialNumber }) else { return }
        previousSensor.updateState(DeviceViewModel(device))
    }

    private func apiError(_ error: Error) {
        notifyObservers(ObserverEventSensors.onError(error))
    }
}

extension SensorsViewModel: SensorsSensorViewModelDelegate {

    func connectPreviousSensor(_ sensor: DeviceViewModel) {
        guard let previousSensor = (Movesense.api.getDevices().first { $0.serialNumber == sensor.serial }) else {
            NSLog("No such sensor discovered: \(sensor.serial)")
            return
        }

        Movesense.api.connectDevice(previousSensor)
    }

    func disconnectPreviousSensor(_ sensor: DeviceViewModel) {
        guard let previousSensor = (Movesense.api.getDevices().first { $0.serialNumber == sensor.serial }) else {
            NSLog("No such sensor discovered: \(sensor.serial)")
            return
        }

        Movesense.api.disconnectDevice(previousSensor)
    }

    func forgetPreviousSensor(_ sensor: DeviceViewModel) {
        guard let previousSensor = (previousSensors.first { $0.sensorSerial == sensor.serial }) else { return }

        previousSensors.removeAll { $0.sensorSerial == sensor.serial }

        notifyObservers(ObserverEventSensors.sensorRemoved(previousSensor))
    }
}
