//
// DfuApi.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import CoreBluetooth
import Foundation
import iOSDFULibrary

internal final class DfuApi: MovesenseDfuApi {

    private enum Constants {
        static let packageSuffix: String = "zip"
    }

    static let sharedInstance: MovesenseDfuApi = DfuApi()

    weak var delegate: MovesenseDfuApiDelegate?

    private let stateMachine: DfuStateMachine
    private var dfuDevices: [DfuDevice] = []

    init(with centralManagerType: CBCentralManager.Type = CBCentralManager.self,
         dfuContainerType: DfuContainer.Type = DfuContainer.self) {

        stateMachine = DfuStateMachine(with: centralManagerType,
                                       dfuContainerType: dfuContainerType)
        stateMachine.delegate = self
    }

    func getDfuPackages() -> [MovesenseDfuPackage] {
        return getBundledDfuPackages() + getAddedDfuPackages()
    }

    func getBundledDfuPackages() -> [MovesenseDfuPackage] {
        guard let bundleUrls: [URL] = Bundle.main.urls(forResourcesWithExtension: Constants.packageSuffix,
                                                       subdirectory: nil) else {
            let errorMessage = "MovesenseDfuApi::getDefaultDfuPackage unable to find given package."
            delegate?.movesenseDfuApiOnError(self, error: MovesenseDfuError.operationError(errorMessage))
            return []
        }

        let packages: [MovesenseDfuPackage] = bundleUrls
            .compactMap { DFUFirmware(urlToZipFile: $0) }
            .compactMap { DfuPackage(dfuFirmware: $0, dfuType: .bundledDfu) }

        return packages
    }

    func getAddedDfuPackages() -> [MovesenseDfuPackage] {
        guard let storageUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            let errorMessage = "MovesenseDfuApi::getPackages unable to get documents dir."
            delegate?.movesenseDfuApiOnError(self, error: MovesenseDfuError.operationError(errorMessage))
            return []
        }

        let packagePath: String = storageUrl.path
        guard let enumerator = FileManager.default.enumerator(atPath: packagePath) else {
            return []
        }

        let packages: [MovesenseDfuPackage] = enumerator.compactMap { $0 as? String }
            .filter { $0.hasSuffix(Constants.packageSuffix) }
            .compactMap { DFUFirmware(urlToZipFile: URL(fileURLWithPath: packagePath + "/" + $0)) }
            .compactMap { DfuPackage(dfuFirmware: $0, dfuType: .addedDfu) }

        return packages
    }

    func removeDfuPackage(_ package: MovesenseDfuPackage) {
        do {
            try FileManager.default.removeItem(at: package.fileUrl)
        } catch let error {
            delegate?.movesenseDfuApiOnError(self, error: MovesenseDfuError.operationError(error.localizedDescription))
        }
    }

    func startDfuScan() {
        stateMachine.startDfuScan()
    }

    func stopDfuScan() {
        stateMachine.stopDfuScan()
    }

    func resetDfuScan() {
        stateMachine.stopDfuScan()
        dfuDevices.removeAll()
    }

    func getDfuDevices() -> [MovesenseDfuDevice] {
        return dfuDevices
    }

    func updateDfuDevice(_ device: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage) {
        stateMachine.updateSensor(device, dfuPackage: dfuPackage)
    }

    func resetDfu() {
        resetDfuScan()
        stateMachine.resetDfu()
    }
}

extension DfuApi: DfuStateMachineDelegate {

    func stateChanged(_ state: MovesenseDfuState) {
        delegate?.movesenseDfuApiStateChanged(self, state: state)

        if case .dfuError(let error) = state {
            delegate?.movesenseDfuApiOnError(self, error: error)
        }
    }

    func discoveredDfuDevice(_ device: DfuDevice) {
        guard (dfuDevices.contains { $0 == device }) == false else {
            NSLog("Discovered device already in dfuSensors.")
            return
        }

        dfuDevices.append(device)

        delegate?.movesenseDfuApiDeviceDiscovered(self, device: device)
    }

    func updateProgress(for part: Int, outOf totalParts: Int, to progress: Int,
                        currentSpeed: Double, avgSpeed: Double) {
        delegate?.movesenseDfuApiUpdateProgress(self, for: part, outOf: totalParts, to: progress,
                                                currentSpeed: currentSpeed, avgSpeed: avgSpeed)
    }
}

internal struct DfuPackage: MovesenseDfuPackage {

    let fileType: MovesenseDfuPackageType
    let fileName: String
    let fileUrl: URL
    let fileSize: UInt32
    let fileParts: Int

    init?(dfuFirmware: DFUFirmware, dfuType: MovesenseDfuPackageType) {
        guard dfuFirmware.valid,
              let fileUrl = dfuFirmware.fileUrl,
              let fileName = dfuFirmware.fileName else { return nil }

        self.fileType = dfuType
        self.fileUrl = fileUrl
        self.fileName = fileName
        self.fileSize = dfuFirmware.size.softdevice + dfuFirmware.size.bootloader + dfuFirmware.size.application
        self.fileParts = dfuFirmware.parts
    }
}

internal struct DfuDevice: MovesenseDfuDevice {

    let deviceLocalName: String
    let deviceUuid: UUID
    let deviceRssi: NSNumber

    init(localName: String, uuid: UUID, rssi: NSNumber) {
        self.deviceLocalName = localName
        self.deviceUuid = uuid
        self.deviceRssi = rssi
    }
}

extension DfuDevice: Equatable {

    static func == (lhs: DfuDevice, rhs: DfuDevice) -> Bool {
        return lhs.deviceLocalName == rhs.deviceLocalName &&
               lhs.deviceUuid == rhs.deviceUuid
    }
}
