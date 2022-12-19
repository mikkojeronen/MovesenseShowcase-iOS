//
// CBCentralManagerMock.swift
// MovesenseDfu
//
// Copyright (c) 2019 Suunto. All rights reserved.
//

import CoreBluetooth

class CBCentralManagerMock: CBCentralManager {

    public static var powerState: CBManagerState = .poweredOn

    override var state: CBManagerState {
        return CBCentralManagerMock.powerState
    }

    override init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, options: [String: Any]? = nil) {
        super.init(delegate: delegate, queue: queue, options: options)
    }

    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]? = nil) {
        let peripheralMock = CBPeripheralMock("Foo")
        peripheralMock.addObserver(peripheralMock, forKeyPath: "delegate", options: .new, context: nil)

        delegate?.centralManager?(self, didDiscover: peripheralMock,
                                  advertisementData: [:],
                                  rssi: NSNumber(value: -100))
    }

    override func stopScan() {}
}

class CBPeripheralMock: CBPeripheral {

    let mockName: String
    let mockUuid: UUID

    override var name: String? {
        return mockName
    }

    override var identifier: UUID {
        return mockUuid
    }

    init(_ name: String, uuid: UUID? = nil) {
        self.mockName = name
        self.mockUuid = uuid ?? UUID(uuidString: "00000000-0000-0000-0000-6F0000000000")!
    }
}
