//
// DfuViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi
import MovesenseDfu

enum MovesenseObserverEventDfu: ObserverEvent {

    case dfuStateChanged(_ state: MovesenseDfuState)
    case dfuDeviceDiscovered(_ device: DfuDeviceViewModel)
    case dfuUpdateProgress(part: Int, totalParts: Int, progress: Int,
                           currentSpeed: Double, avgSpeed: Double)
    case dfuOnError(_ error: String)
}

struct DfuDeviceViewModel {

    private let dfuDevice: MovesenseDfuDevice

    var deviceName: String { return dfuDevice.deviceLocalName }

    var deviceRssi: String { return "RSSI: \(dfuDevice.deviceRssi) dBm" }

    var deviceSerial: String? { return nil }

    var deviceUuid: String { return dfuDevice.deviceUuid.uuidString }

    init(_ with: MovesenseDfuDevice) {
        self.dfuDevice = with
    }
}

struct DfuPackageViewModel {

    private let dfuPackage: MovesenseDfuPackage

    var fileType: MovesenseDfuPackageType { return dfuPackage.fileType }

    var fileName: String { return dfuPackage.fileName }

    var fileSize: String { return String(dfuPackage.fileSize / 1024) + " kB" }

    init(_ with: MovesenseDfuPackage) {
        self.dfuPackage = with
    }
}

class DfuViewModel: Observable {

    let sensorViewModel: SensorsSensorViewModel?

    private var devices: [MovesenseDfuDevice] {
        return MovesenseDfu.api.getDfuDevices()
    }

    internal var observations: [Observation] = [Observation]()
    private(set) var observationQueue: DispatchQueue = DispatchQueue.global()

    var selectedDevice: DfuDeviceViewModel?
    var selectedPackage: DfuPackageViewModel?

    init(sensorViewModel: SensorsSensorViewModel?) {
        self.sensorViewModel = sensorViewModel
        MovesenseDfu.api.delegate = self
    }

    convenience init() {
        self.init(sensorViewModel: nil)
    }

    func getDiscoveredDevices() -> [DfuDeviceViewModel] {
        return devices.map { DfuDeviceViewModel($0) }
    }

    func getAddedDfuPackages() -> [DfuPackageViewModel] {
        return MovesenseDfu.api.getDfuPackages().filter { $0.fileType == .addedDfu }.map { DfuPackageViewModel($0) }
    }

    func getBundledDfuPackages() -> [DfuPackageViewModel] {
        return MovesenseDfu.api.getDfuPackages().filter { $0.fileType == .bundledDfu }.map { DfuPackageViewModel($0) }
    }

    func removeDfuPackage(_ packageIndex: Int) {
        if let removedPackage = (MovesenseDfu.api.getDfuPackages().filter { $0.fileType == .addedDfu })[safe: packageIndex] {
            MovesenseDfu.api.removeDfuPackage(removedPackage)
        }
    }

    func startDevicesScan() {
        MovesenseDfu.api.startDfuScan()
    }

    func stopDevicesScan() {
        MovesenseDfu.api.stopDfuScan()
    }

    func resetDevices() {
        MovesenseDfu.api.resetDfuScan()
    }

    func resetDfu() {
        MovesenseDfu.api.resetDfu()
    }

    func requestDfuMode(_ dfuSerial: String) {
        guard let dfuDevice = (Movesense.api.getDevices().first { $0.serialNumber == dfuSerial }) else {
            let errorString = "DFU mode request without a matching sensor found."
            notifyObservers(MovesenseObserverEventDfu.dfuOnError(errorString))
            return
        }

        let dfuRequest = MovesenseRequest(resourceType: .systemMode, method: .put,
                                          parameters: [MovesenseRequestParameter.systemMode(12)])

        Movesense.api.sendRequestForDevice(dfuDevice, request: dfuRequest) { response in
            if case .operationError(_) = response {
                let errorString = "Error requesting DFU mode."
                self.notifyObservers(MovesenseObserverEventDfu.dfuOnError(errorString))
            }
        }
    }

    func updateDevice() {
        guard let deviceUuid = selectedDevice?.deviceUuid,
              let dfuDevice = (MovesenseDfu.api.getDfuDevices().first { $0.deviceUuid == UUID(uuidString: deviceUuid) }),
              let dfuPackage = (MovesenseDfu.api.getDfuPackages().first { $0.fileName == selectedPackage?.fileName }) else {

            let errorString = "Selected device, or DFU package, not found."
            notifyObservers(MovesenseObserverEventDfu.dfuOnError(errorString))

            return
        }

        MovesenseDfu.api.updateDfuDevice(dfuDevice, dfuPackage: dfuPackage)
    }
}

extension DfuViewModel: MovesenseDfuApiDelegate {

    func movesenseDfuApiStateChanged(_ api: MovesenseDfuApi, state: MovesenseDfuState) {
        notifyObservers(MovesenseObserverEventDfu.dfuStateChanged(state))
    }

    func movesenseDfuApiDeviceDiscovered(_ api: MovesenseDfuApi, device: MovesenseDfuDevice) {
        notifyObservers(MovesenseObserverEventDfu.dfuDeviceDiscovered(DfuDeviceViewModel(device)))
    }

    func movesenseDfuApiUpdateProgress(_ api: MovesenseDfuApi, for part: Int, outOf totalParts: Int,
                                       to progress: Int, currentSpeed: Double, avgSpeed: Double) {
        notifyObservers(MovesenseObserverEventDfu.dfuUpdateProgress(part: part, totalParts: totalParts, progress: progress,
                                                                    currentSpeed: currentSpeed, avgSpeed: avgSpeed))
    }

    func movesenseDfuApiOnError(_ api: MovesenseDfuApi, error: MovesenseDfuError) {
        notifyObservers(MovesenseObserverEventDfu.dfuOnError(error.description))
    }
}
