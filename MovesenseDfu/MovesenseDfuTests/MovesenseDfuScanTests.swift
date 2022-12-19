//
// MovesenseDfuScanTests.swift
// MovesenseDfuScanTests
//
// Copyright © 2019 Suunto. All rights reserved.
//

import XCTest
@testable import MovesenseDfu

import CoreBluetooth
import iOSDFULibrary

class MovesenseDfuScanTests: XCTestCase {

    let dfuApi: MovesenseDfuApi = DfuApi(with: CBCentralManagerMock.self)

    var dfuStateChangedHandler: ((MovesenseDfuState) -> Void)?
    var dfuDeviceDiscoveredHandler: ((MovesenseDfuDevice) -> Void)?

    override func setUp() {
        dfuApi.delegate = self
        dfuStateChangedHandler = nil
        dfuDeviceDiscoveredHandler = nil
    }

    override func tearDown() {
        dfuApi.delegate = nil
    }

    func testStartScan() {
        let deviceExpectation = self.expectation(description: "device")
        let discoveryStateExpectation = self.expectation(description: "discoveryState")

        self.dfuDeviceDiscoveredHandler = { device in
            deviceExpectation.fulfill()
        }

        self.dfuStateChangedHandler = { state in
            if state == .dfuDiscovery { discoveryStateExpectation.fulfill() }
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStartStopScan() {
        let deviceExpectation = self.expectation(description: "device")
        let discoveryStateExpectation = self.expectation(description: "discoveryState")

        self.dfuDeviceDiscoveredHandler = { device in
            deviceExpectation.fulfill()
        }

        self.dfuStateChangedHandler = { state in
            if state == .dfuDiscovery { discoveryStateExpectation.fulfill() }
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        let initStateExpectation = self.expectation(description: "initState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuInit { initStateExpectation.fulfill() }
        }

        dfuApi.stopDfuScan()

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testResetScan() {
        let discoveryStateExpectation = self.expectation(description: "discoveryState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuDiscovery { discoveryStateExpectation.fulfill() }
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssert(dfuApi.getDfuDevices().count == 1)

        let initStateExpectation = self.expectation(description: "initState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuInit { initStateExpectation.fulfill() }
        }

        dfuApi.resetDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssert(dfuApi.getDfuDevices().count == 0)
    }
}

extension MovesenseDfuScanTests: MovesenseDfuApiDelegate {

    func movesenseDfuApiStateChanged(_ api: MovesenseDfuApi, state: MovesenseDfuState) {
        NSLog("dfuStateChanged(\(state))")
        self.dfuStateChangedHandler?(state)
    }

    func movesenseDfuApiDeviceDiscovered(_ api: MovesenseDfuApi, device: MovesenseDfuDevice) {
        self.dfuDeviceDiscoveredHandler?(device)
    }

    func movesenseDfuApiUpdateProgress(_ api: MovesenseDfuApi, for part: Int, outOf totalParts: Int,
                                       to progress: Int, currentSpeed: Double, avgSpeed: Double) {}

    func movesenseDfuApiOnError(_ api: MovesenseDfuApi, error: MovesenseDfuError) {
        XCTFail(error.description)
    }
}
