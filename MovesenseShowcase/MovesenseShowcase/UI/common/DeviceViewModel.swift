//
// DeviceViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

enum DeviceConnectionState: String, Codable {

    case discovered
    case disconnected
    case connecting
    case connected
}

extension DeviceConnectionState {

    init(_ deviceState: MovesenseDeviceState) {
        switch deviceState {
        case .disconnected: self = .disconnected
        case .connected: self = .connected
        case .connecting: self = .connecting
        }
    }
}

struct DeviceViewModel: Codable {

    let state: DeviceConnectionState
    let serial: String
    let name: String
    let rssi: String
    let swVersion: String
    let hwVersion: String

    init(_ with: MovesenseDevice, newState: DeviceConnectionState? = nil) {
        state = newState ?? DeviceConnectionState(with.deviceState)
        serial = with.serialNumber
        name = with.localName.components(separatedBy: " ")[0]
        rssi = "\(with.rssi) dBm"
        swVersion = "\(with.deviceInfo?.swVersion ?? "n/a")"
        hwVersion = "\(with.deviceInfo?.hwVersion ?? "n/a")"
    }

    init(_ with: DeviceViewModel, newState: DeviceConnectionState? = nil) {
        state = newState ?? with.state
        serial = with.serial
        name = with.name
        rssi = with.rssi
        swVersion = with.swVersion
        hwVersion = with.hwVersion
    }
}
