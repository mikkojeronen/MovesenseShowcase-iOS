//
//  MovesenseDfu.swift
//  MovesenseDfu
//
//  Copyright © 2019 Suunto. All rights reserved.
//

import Foundation

public struct MovesenseDfu {

    public static let api: MovesenseDfuApi = DfuApi.sharedInstance
}

public enum MovesenseDfuPackageType {

    case addedDfu
    case bundledDfu
}

public protocol MovesenseDfuPackage {

    var fileType: MovesenseDfuPackageType { get }
    var fileName: String { get }
    var fileUrl: URL { get }
    var fileSize: UInt32 { get }
    var fileParts: Int { get }
}

public protocol MovesenseDfuDevice {

    var deviceLocalName: String { get }
    var deviceUuid: UUID { get }
    var deviceRssi: NSNumber { get }
}

public enum MovesenseDfuState {

    case dfuInit
    case dfuDiscovery
    case dfuUpdate
    case dfuCompleted
    case dfuError(_ error: MovesenseDfuError)

    public var description: String {
        switch self {
        case .dfuInit: return "dfuInit"
        case .dfuDiscovery: return "dfuDiscovery"
        case .dfuUpdate: return "dfuUpdate"
        case .dfuCompleted: return "dfuCompleted"
        case .dfuError(let error): return "dfuError: \(error.description)"
        }
    }
}

extension MovesenseDfuState: Equatable {

    public static func == (lhs: MovesenseDfuState, rhs: MovesenseDfuState) -> Bool {
        switch (lhs, rhs) {
        case (.dfuInit, .dfuInit),
             (.dfuDiscovery, .dfuDiscovery),
             (.dfuUpdate, .dfuUpdate),
             (.dfuCompleted, .dfuCompleted): return true
        case (.dfuError(let lhsError), .dfuError(let rhsError)): return lhsError.description == rhsError.description
        default: return false
        }
    }
}

public enum MovesenseDfuError: Error {

    case integrityError(String)
    case operationError(String)
    case packageError(String)
    case updateError(String)

    public var description: String {
        switch self {
        case .integrityError(let error): return "integrityError(\(error))"
        case .operationError(let error): return "operationError(\(error))"
        case .packageError(let error): return "packageError(\(error))"
        case .updateError(let error): return "updateError(\(error))"
        }
    }
}

public protocol MovesenseDfuApiDelegate: class {

    func movesenseDfuApiStateChanged(_ api: MovesenseDfuApi, state: MovesenseDfuState)

    func movesenseDfuApiDeviceDiscovered(_ api: MovesenseDfuApi, device: MovesenseDfuDevice)

    func movesenseDfuApiUpdateProgress(_ api: MovesenseDfuApi, for part: Int, outOf totalParts: Int,
                                       to progress: Int, currentSpeed: Double, avgSpeed: Double)

    func movesenseDfuApiOnError(_ api: MovesenseDfuApi, error: MovesenseDfuError)
}

public protocol MovesenseDfuApi: class {

    var delegate: MovesenseDfuApiDelegate? { get set }

    /// Returns bundled and user-added array of DFU packages usable for updating sensors.
    ///
    /// - Returns: DFU packages usable for updating sensors.
    func getDfuPackages() -> [MovesenseDfuPackage]

    /// Delete the given user-added DFU package from the file system.
    ///
    /// - Parameters:
    ///   - package: User-added DFU package to be removed.
    func removeDfuPackage(_ package: MovesenseDfuPackage)

    /// Starts scanning for sensors in DFU mode.
    ///
    func startDfuScan()

    /// Stops scanning.
    ///
    func stopDfuScan()

    /// Stops scanning and resets the list of discovered sensors in DFU mode.
    ///
    func resetDfuScan()

    /// Returns discovered sensors which are in DFU mode.
    ///
    /// - Returns: Discovered DFU mode sensors.
    func getDfuDevices() -> [MovesenseDfuDevice]

    /// Starts the update process for the given sensor with the given update package.
    ///
    /// - Parameters:
    ///   - device: The sensor to be updated.
    ///   - dfuPackage: The DFU package to be used for the update.
    func updateDfuDevice(_ device: MovesenseDfuDevice, dfuPackage: MovesenseDfuPackage)

    /// Resets DFU update.
    ///
    func resetDfu()
}
