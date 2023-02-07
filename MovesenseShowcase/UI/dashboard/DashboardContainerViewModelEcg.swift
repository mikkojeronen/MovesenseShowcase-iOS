//
// DashboardContainerViewModelEcg.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum DashboardObserverEventEcg: ObserverEvent {

    case receivedEcg(sample: Int32, timestamp: UInt32)
    case onError(_ error: String)
}

class DashboardContainerViewModelEcg: DashboardContainerViewModel {

    private var previousTimestamp: UInt32 = 0

    override func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? MovesenseObserverEventOperation else { return }

        switch event {
        case .operationResponse, .operationFinished: return
        case .operationEvent(let event): self.receivedEvent(event)
        case .operationError(let error): self.onOperationError(error)
        }
    }

    func receivedEvent(_ event: MovesenseEvent) {
        guard case let MovesenseEvent.ecg(_, ecgData) = event,
              ecgData.samples.count > 0 else {
            NSLog("DashboardContainerViewModelEcg::receivedEvent invalid event.")
            return
        }

        if previousTimestamp == 0 || previousTimestamp > ecgData.timestamp {
            NSLog("DashboardContainerViewModelAcc::receivedEvent invalid timestamp, resetting.")
            previousTimestamp = ecgData.timestamp
            return
        }

        let timeIncrement: Double = Double(ecgData.timestamp - previousTimestamp) / Double(ecgData.samples.count)
        ecgData.samples.enumerated().forEach { (index, sample) in
            let timestamp = ecgData.timestamp + UInt32(round(Double(index) * timeIncrement))
            // This requires serial observation queue to guarantee the order
            notifyObservers(DashboardObserverEventEcg.receivedEcg(sample: sample,
                                                                  timestamp: timestamp))
        }

        previousTimestamp = ecgData.timestamp
    }

    func onOperationError(_ error: MovesenseError) {
        notifyObservers(DashboardObserverEventVector.onError("error: \(error.localizedDescription)\n"))
    }
}
