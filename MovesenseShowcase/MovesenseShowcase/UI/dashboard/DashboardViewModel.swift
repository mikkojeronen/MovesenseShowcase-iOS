//
// DashboardViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import CoreGraphics
import MovesenseApi

struct DashboardDevice {

    let name: String
    let serial: String

    init(_ device: MovesenseDevice) {
        self.name = device.localName
        self.serial = device.serialNumber
    }
}

enum DashboardResource: String, Equatable {

    case acc
    case accConfig
    case accInfo
    case appInfo
    case ecg
    case ecgInfo
    case heartRate
    case gyro
    case gyroConfig
    case gyroInfo
    case info
    case led
    case systemEnergy
    case systemMode

    // swiftlint:disable:next cyclomatic_complexity
    init(_ resource: MovesenseResource) {
        switch resource.resourceType {
        case .acc: self = .acc
        case .accConfig: self = .accConfig
        case .accInfo: self = .accInfo
        case .appInfo: self = .appInfo
        case .ecg: self = .ecg
        case .ecgInfo: self = .ecgInfo
        case .heartRate: self = .heartRate
        case .gyro: self = .gyro
        case .gyroConfig: self = .gyroConfig
        case .gyroInfo: self = .gyroInfo
        case .info: self = .info
        case .led: self = .led
        case .systemEnergy: self = .systemEnergy
        case .systemMode: self = .systemMode
        }
    }

    static func == (lhs: DashboardResource, rhs: MovesenseResourceType) -> Bool {
        switch (lhs, rhs) {
        case (.acc, .acc),
             (.accConfig, .accConfig),
             (.accInfo, .accInfo),
             (.appInfo, .appInfo),
             (.ecg, .ecg),
             (.ecgInfo, .ecgInfo),
             (.gyro, .gyro),
             (.gyroConfig, .gyroConfig),
             (.gyroInfo, .gyroInfo),
             (.info, .info),
             (.heartRate, .heartRate),
             (.led, .led),
             (.systemEnergy, .systemEnergy),
             (.systemMode, .systemMode): return true
        default: return false
        }
    }

    static func == (lhs: MovesenseResourceType, rhs: DashboardResource) -> Bool {
        return rhs == lhs
    }
}

struct DashboardParameter {

    let method: DashboardMethod
    let name: String
    let type: Any.Type
    let value: String
}

extension DashboardParameter: CustomStringConvertible {

    public var description: String {
        return "\(method) \(name) \(type) \(value)"
    }
}

enum DashboardMethod: String {

    case get
    case put
    case del
    case post
    case subscribe
    case unsubscribe

    init(_ method: MovesenseMethod) {
        switch method {
        case .get: self = .get
        case .put: self = .put
        case .del: self = .del
        case .post: self = .post
        case .subscribe: self = .subscribe
        case .unsubscribe: self = .unsubscribe
        }
    }

    static func == (lhs: DashboardMethod, rhs: MovesenseMethod) -> Bool {
        switch (lhs, rhs) {
        case (.get, .get),
             (.put, .put),
             (.del, .del),
             (.post, .post),
             (.subscribe, .subscribe),
             (.unsubscribe, .unsubscribe): return true
        default: return false
        }
    }

    static func == (lhs: MovesenseMethod, rhs: DashboardMethod) -> Bool {
        return rhs == lhs
    }
}

struct DashboardVector3 {

    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
}

enum MovesenseObserverEventDashboard: ObserverEvent {

    case dashboardUpdated
    case dashboardError(_ error: Error)
}

class DashboardViewModel: Observable {

    private enum Constants {
        static let twoWeeksTimeInterval: TimeInterval = 14 * 24 * 60 * 60
    }

    var isActiveDevices: Bool {
        return Movesense.api.getDevices().contains { $0.deviceState != .disconnected }
    }

    var isActivelyUsed: Bool {
        get {
            return Settings.previousDashboardLaunchDate.timeIntervalSinceNow > -Constants.twoWeeksTimeInterval
        }

        set {
            if newValue {
                Settings.previousDashboardLaunchDate = Date()
            } else {
                Settings.previousDashboardLaunchDate = Date.distantPast
            }
        }
    }

    var isEditMode: Bool = false {
        didSet {
            containers.forEach {
                $0.isSelectMode = isEditMode
                $0.isEditMode = isEditMode
            }
        }
    }

    var isEnabledContainers: Bool {
        return containers.contains { $0.isEnabled }
    }

    private var connectedDevices: [MovesenseDevice] {
        return Movesense.api.getDevices().filter { $0.isConnected }
    }

    private var _containers: [DashboardContainerViewModel] = []
    var containers: [DashboardContainerViewModel] {
        return _containers
    }

    internal var observations: [Observation] = [Observation]()
    private(set) var observationQueue: DispatchQueue = DispatchQueue.global()

    init() {
        updateContainers()
        Movesense.api.addObserver(self)
        RecorderApi.instance.addObserver(self)
    }

    func startRecording() {
        // Tell all operations to add them to recorder & start
        containers.forEach { $0.addToRecorder() }
        RecorderApi.instance.startRecording()
    }

    func stopRecording() {
        // stop & clear recorder
        RecorderApi.instance.stopRecording()
        containers.forEach { $0.removeFromRecorder() }
    }

    private func updateContainers() {
        let connectedContainers = connectedDevices.flatMap { device -> [DashboardContainerViewModel] in
            return Movesense.api.getResourcesForDevice(device)?.compactMap { resource in
                DashboardFactory.createOperationViewModel(name: "\(resource.resourceType.resourceName)",
                                                          device: device, resource: resource)
            } ?? []
        }

        connectedContainers.forEach { connectedContainer in
            if (_containers.contains { $0 == connectedContainer }) == false {
                _containers.append(connectedContainer)
            }
        }

        _containers.removeAll { currentContainer in
            connectedContainers.contains { $0 == currentContainer } == false
        }
    }
}

extension DashboardViewModel: Observer {

    func handleEvent(_ event: ObserverEvent) {
        switch event {
        case let event as MovesenseObserverEventApi: handleEventApi(event)
        case let event as MovesenseObserverEventDevice: handleEventDevice(event)
        case let event as RecorderObserverEvent: handleEventRecorder(event)
        default: return
        }
    }

    func handleEventApi(_ event: MovesenseObserverEventApi) {
        switch event {
        case .apiDeviceDiscovered, .apiDeviceConnecting: return
        case .apiDeviceConnected: deviceConnected()
        case .apiDeviceDisconnected(let device): deviceDisconnected(device)
        case .apiDeviceOperationInitiated: return
        case .apiError(let error): NSLog("DashboardViewModel::apiError \(error)")
        }
    }

    func handleEventDevice(_ event: MovesenseObserverEventDevice) {
        switch event {
        case .deviceConnecting, .deviceConnected, .deviceDisconnected, .deviceOperationInitiated: return
        case .deviceError(let device, let error): deviceError(error, device: device)
        }
    }

    func handleEventRecorder(_ event: RecorderObserverEvent) {
        notifyObservers(event)
    }

    func deviceConnected() {
        updateContainers()
        notifyObservers(MovesenseObserverEventDashboard.dashboardUpdated)
    }

    func deviceDisconnected(_ device: MovesenseDevice) {
        updateContainers()
        notifyObservers(MovesenseObserverEventDashboard.dashboardUpdated)
    }

    func deviceError(_ error: Error, device: MovesenseDevice) {
        notifyObservers(MovesenseObserverEventDashboard.dashboardError(AppError.connectionError(error.localizedDescription)))
    }
}
