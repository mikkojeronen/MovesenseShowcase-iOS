//
// DashboardContainerViewModelGyro.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

class DashboardContainerViewModelGyro: DashboardContainerViewModel {

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
        guard case let MovesenseEvent.gyroscope(_, gyroData) = event,
              gyroData.vectors.count > 0 else {
            NSLog("DashboardContainerViewModelGyro::receivedEvent invalid event.")
            return
        }

        if previousTimestamp == 0 || previousTimestamp > gyroData.timestamp {
            NSLog("DashboardContainerViewModelGyro::receivedEvent invalid timestamp, resetting.")
            previousTimestamp = gyroData.timestamp
            return
        }

        let timeIncrement: Double = Double(gyroData.timestamp - previousTimestamp) / Double(gyroData.vectors.count)
        gyroData.vectors.forEach { vector in
            // This requires serial observation queue to guarantee the order
            notifyObservers(DashboardObserverEventVector.receivedVector(x: vector.x, y: vector.y, z: vector.z,
                                                                        step: timeIncrement))
        }

        previousTimestamp = gyroData.timestamp
    }

    func onOperationError(_ error: MovesenseError) {
        notifyObservers(DashboardObserverEventVector.onError("error: \(error.localizedDescription)\n"))
    }
}
