//
// DashboardContainerViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum DashboardObserverEventContainer: ObserverEvent {

    case editModeUpdate(_ update: Bool)
    case selectModeUpdate(_ update: Bool, enabled: Bool)
    case quantityUpdate(_ quantity: String)
    case onError(_ error: String)
}

class DashboardContainerViewModel: Observable, Observer {

    internal var observations: [Observation] = [Observation]()
    private(set) var observationQueue: DispatchQueue = DispatchQueue(label: "com.movesesense.dashboardcontainer")

    private let movesenseDevice: MovesenseDevice
    private let movesenseResource: MovesenseResource
    private var movesenseOperation: MovesenseOperation?

    let name: String

    var serial: String {
        return movesenseDevice.serialNumber
    }

    var resource: DashboardResource {
        return DashboardResource(movesenseResource)
    }

    var quantity: String? = nil {
        didSet {
            guard let updatedQuantity = quantity else { return }
            notifyObservers(DashboardObserverEventContainer.quantityUpdate(updatedQuantity))
        }
    }

    var isEnabled: Bool = false {
        didSet {
            if isEnabled == false {
                movesenseOperation = nil
            }
        }
    }

    var isEditMode: Bool = false {
        didSet {
            notifyObservers(DashboardObserverEventContainer.editModeUpdate(isEditMode))
        }
    }

    var isSelectMode: Bool = false {
        didSet {
            notifyObservers(DashboardObserverEventContainer.selectModeUpdate(isSelectMode, enabled: isEnabled))
        }
    }

    var isOperation: Bool {
        return movesenseOperation != nil
    }

    var parameters: [DashboardParameter?] {
        return resourceParameters(resource: DashboardResource(movesenseResource))
    }

    init(name: String, device: MovesenseDevice, resource: MovesenseResource) {
        self.name = name
        self.movesenseDevice = device
        self.movesenseResource = resource
    }

    func requestMethod(_ method: DashboardMethod, indices: [Int]) {
        guard let movesenseMethod = (movesenseResource.methods.first { $0 == method }) else {
            NSLog("Resource has no method \(method)")
            return
        }

        let request = MovesenseRequest(resourceType: movesenseResource.resourceType, method: movesenseMethod,
                                       parameters: indices.compactMap { index in movesenseResource.requestParameter(index) })

        movesenseOperation = movesenseDevice.sendRequest(request, observer: self)
    }

    func requestSend(resource: DashboardResource, method: DashboardMethod, parameterIndices: [Int]) {
        guard let movesenseResource = (movesenseDevice.resources.first { $0.resourceType == resource }) else {
            NSLog("Device has no resource \(resource)")
            return
        }

        guard let movesenseMethod = (movesenseResource.methods.first { $0 == method }) else {
            NSLog("Resource has no method \(method)")
            return
        }

        let request = MovesenseRequest(resourceType: movesenseResource.resourceType, method: movesenseMethod,
                                       parameters: parameterIndices.compactMap { index in
                                           movesenseResource.requestParameter(index)
                                       })

        _ = movesenseDevice.sendRequest(request, observer: self)
    }

    func resourceParameters(resource: DashboardResource) -> [DashboardParameter] {
        guard let movesenseResource = (movesenseDevice.resources.first { $0.resourceType == resource }) else {
            NSLog("Device has no resource \(resource)")
            return []
        }

        return movesenseResource.methodParameters.map { parameter in
            DashboardParameter(method: DashboardMethod(parameter.0),
                               name: parameter.1, type: parameter.2, value: parameter.3)
        }
    }

    func addToRecorder() {
        guard let operation = movesenseOperation else { return }
        RecorderApi.instance.addDeviceOperation(movesenseDevice, operation)
    }

    func removeFromRecorder() {
        guard let operation = movesenseOperation else { return }
        RecorderApi.instance.removeDeviceOperation(movesenseDevice, operation)
    }

    func handleEvent(_ event: ObserverEvent) {
        assertionFailure("DashboardContainerViewModel::handleEvent not implemented in subclass.")
    }
}

extension DashboardContainerViewModel: Equatable {

    public static func == (lhs: DashboardContainerViewModel, rhs: DashboardContainerViewModel) -> Bool {
        return lhs.serial == rhs.serial &&
               lhs.resource == rhs.resource
    }
}
