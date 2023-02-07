//
// DashboardContainerViewModelAcc.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum DashboardObserverEventVector: ObserverEvent {

    case receivedVector(x: Float, y: Float, z: Float, step: Double)
    case onError(_ error: String)
}

class DashboardContainerViewModelAcc: DashboardContainerViewModel {

    private var previousTimestamp: UInt32 = 0

    override func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventOperation else { return }

        switch event {
        case .operationResponse: return
        case .operationFinished: return
        case .operationEvent(let event): self.receivedEvent(event)
        case .operationError(let error): self.onOperationError(error)
        }
    }

    func receivedEvent(_ event: MovesenseEvent) {
        guard case let MovesenseEvent.acc(_, accData) = event,
              accData.vectors.count > 0 else {
            NSLog("DashboardContainerViewModelAcc::receivedEvent invalid event.")
            return
        }

        if previousTimestamp == 0 || previousTimestamp > accData.timestamp {
            NSLog("DashboardContainerViewModelAcc::receivedEvent invalid timestamp, resetting.")
            previousTimestamp = accData.timestamp
            return
        }

        let timeIncrement: Double = Double(accData.timestamp - previousTimestamp) / Double(accData.vectors.count)
        accData.vectors.forEach { (vector: MovesenseVector3D) in
            // This requires serial observation queue to guarantee the order
            notifyObservers(DashboardObserverEventVector.receivedVector(x: vector.x, y: vector.y, z: vector.z,
                                                                        step: timeIncrement))
        }

        previousTimestamp = accData.timestamp
    }

    func onOperationError(_ error: MovesenseError) {
        notifyObservers(DashboardObserverEventVector.onError("error: \(error.localizedDescription)\n"))
    }
}
