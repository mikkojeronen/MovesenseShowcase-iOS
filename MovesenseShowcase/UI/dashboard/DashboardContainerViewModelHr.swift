//
// DashboardContainerViewModelHr.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum DashboardObserverEventHr: ObserverEvent {

    case receivedHr(average: Float)
    case onError(_ error: String)
}

class DashboardContainerViewModelHr: DashboardContainerViewModel {

    override func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventOperation else { return }

        switch event {
        case .operationResponse, .operationFinished: return
        case .operationEvent(let event): self.receivedEvent(event)
        case .operationError(let error): self.onOperationError(error)
        }
    }

    func receivedEvent(_ event: MovesenseEvent) {
        guard case let MovesenseEvent.heartRate(_, hrData) = event else {
            NSLog("DashboardContainerViewModelHr::receivedEvent invalid event.")
            return
        }

        notifyObservers(DashboardObserverEventHr.receivedHr(average: hrData.average))
    }

    func onOperationError(_ error: MovesenseError) {
        notifyObservers(DashboardObserverEventVector.onError("error: \(error.localizedDescription)\n"))
    }
}
