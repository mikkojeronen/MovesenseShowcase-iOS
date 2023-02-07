//
// DashboardContainerViewModelDebug.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum DashboardObserverEventDebug: ObserverEvent {

    case receivedResponse(_ response: String)
    case receivedEvent(_ event: String)
    case onError(_ error: String)
}

class DashboardContainerViewModelDebug: DashboardContainerViewModel {

    override func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventOperation else { return }
        switch event {
        case .operationResponse(let response): self.receivedResponse(response)
        case .operationEvent(let event): self.receivedEvent(event)
        case .operationFinished: return
        case .operationError(let error): self.onOperationError(error)
        }
    }

    func receivedResponse(_ response: MovesenseResponse) {
        notifyObservers(DashboardObserverEventDebug.receivedResponse("response: \(response)\n"))
    }

    func receivedEvent(_ event: MovesenseEvent) {
        notifyObservers(DashboardObserverEventDebug.receivedEvent("event: \(event)\n"))
    }

    func onOperationError(_ error: MovesenseError) {
        notifyObservers(DashboardObserverEventDebug.onError("error: \(error.localizedDescription)\n"))
    }
}
