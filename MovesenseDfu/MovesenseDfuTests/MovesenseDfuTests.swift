//
// MovesenseDfuTests.swift
// MovesenseDfuTests
//
// Copyright © 2019 Suunto. All rights reserved.
//

import XCTest
@testable import MovesenseDfu

import iOSDFULibrary

class MovesenseDfuTestSetup: NSObject {
    override init() {
        super.init()
        //copyTestPackageToMainBundle(self)
    }
}

class MovesenseDfuTests: XCTestCase {

    let dfuApi: MovesenseDfuApi = DfuApi(with: CBCentralManagerMock.self, dfuContainerType: DfuContainerMock.self)

    var dfuStateChangedHandler: ((MovesenseDfuState) -> Void)?
    var dfuDeviceDiscoveredHandler: ((MovesenseDfuDevice) -> Void)?
    var dfuUpdateProgressHandler: ((Int, Int, Int, Double, Double) -> Void)?
    var dfuErrorHandler: ((MovesenseDfuError) -> Void)?

    override func setUp() {
        dfuApi.delegate = self
        CBCentralManagerMock.powerState = .poweredOn
        DfuContainerMock.startResponse = true
        DfuContainerMock.abortResponse = true
    }

    override func tearDown() {
        dfuApi.delegate = nil
    }

    private func testUpdate() {
        let deviceExpectation = self.expectation(description: "device")
        self.dfuDeviceDiscoveredHandler = { device in
            deviceExpectation.fulfill()
        }

        let discoveryStateExpectation = self.expectation(description: "discoveryState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuDiscovery { discoveryStateExpectation.fulfill() }
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssert(dfuApi.getDfuDevices().count == 1)

        copyTestPackageToDocuments(self)

        XCTAssert(dfuApi.getDfuPackages().count == 1)

        let updateProgressExpectation = self.expectation(description: "updateProgress")
        self.dfuUpdateProgressHandler = { part, totalParts, progress, currentSpeed, avgSpeed in
            updateProgressExpectation.fulfill()
        }

        let updateStateExpectation = self.expectation(description: "updateState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuUpdate { updateStateExpectation.fulfill() }
        }

        let dfuPackage = dfuApi.getDfuPackages().first!
        let dfuDevice = dfuApi.getDfuDevices().first!

        dfuApi.updateDfuDevice(dfuDevice, dfuPackage: dfuPackage)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateFromInit() {
        let deviceExpectation = self.expectation(description: "device")
        self.dfuDeviceDiscoveredHandler = { device in
            deviceExpectation.fulfill()
        }

        let discoveryStateExpectation = self.expectation(description: "discoveryState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuDiscovery { discoveryStateExpectation.fulfill() }
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssert(dfuApi.getDfuDevices().count == 1)

        copyTestPackageToDocuments(self)

        XCTAssert(dfuApi.getDfuPackages().count == 1)

        let dfuPackage = dfuApi.getDfuPackages().first!
        let dfuDevice = dfuApi.getDfuDevices().first!

        let initStateExpectation = self.expectation(description: "initState")
        initStateExpectation.expectedFulfillmentCount = 2
        self.dfuStateChangedHandler = { state in
            if state == .dfuInit { initStateExpectation.fulfill() }
        }

        dfuApi.resetDfu()

        waitForExpectations(timeout: 1, handler: nil)

        let updateProgressExpectation = self.expectation(description: "updateProgress")
        self.dfuUpdateProgressHandler = { part, totalParts, progress, currentSpeed, avgSpeed in
            updateProgressExpectation.fulfill()
        }

        let updateStateExpectation = self.expectation(description: "updateState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuUpdate { updateStateExpectation.fulfill() }
        }

        dfuApi.updateDfuDevice(dfuDevice, dfuPackage: dfuPackage)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateToCompleted() {
        testUpdate()

        let completeStateExpectation = self.expectation(description: "completeState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuCompleted { completeStateExpectation.fulfill() }
        }

        DfuContainerMock.instance!.changeState(to: DFUState.completed)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateToAbort() {
        testUpdate()

        let abortStateExpectation = self.expectation(description: "abortState")
        self.dfuStateChangedHandler = { state in
            if case MovesenseDfuState.dfuError(_) = state {
                abortStateExpectation.fulfill()
            }
        }

        let errorExpectation = self.expectation(description: "error")
        self.dfuErrorHandler = { error in
            errorExpectation.fulfill()
        }

        XCTAssert(DfuContainerMock.instance!.abort())

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateToError() {
        let deviceExpectation = self.expectation(description: "device")
        self.dfuDeviceDiscoveredHandler = { device in
            deviceExpectation.fulfill()
        }

        let discoveryStateExpectation = self.expectation(description: "discoveryState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuDiscovery { discoveryStateExpectation.fulfill() }
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssert(dfuApi.getDfuDevices().count == 1)

        copyTestPackageToDocuments(self)

        XCTAssert(dfuApi.getDfuPackages().count == 1)

        let updateProgressExpectation = self.expectation(description: "updateProgress")
        self.dfuUpdateProgressHandler = { part, totalParts, progress, currentSpeed, avgSpeed in
            updateProgressExpectation.fulfill()
        }

        let updateStateExpectation = self.expectation(description: "updateState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuUpdate { updateStateExpectation.fulfill() }
        }

        let errorExpectation = self.expectation(description: "error")
        self.dfuErrorHandler = { error in
            errorExpectation.fulfill()
        }

        let dfuPackage = dfuApi.getDfuPackages().first!
        let dfuDevice = dfuApi.getDfuDevices().first!

        DfuContainerMock.startResponse = false

        dfuApi.updateDfuDevice(dfuDevice, dfuPackage: dfuPackage)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateResetSuccess() {
        testUpdate()

        let resetStateExpectation = self.expectation(description: "abortState")
        self.dfuStateChangedHandler = { state in
            if state == .dfuInit { resetStateExpectation.fulfill() }
        }

        self.dfuErrorHandler = { _ in }

        dfuApi.resetDfu()

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testScanBluetoothOff() {
        CBCentralManagerMock.powerState = .poweredOff

        let errorStateExpectation = self.expectation(description: "errorState")
        self.dfuStateChangedHandler = { state in
            if case MovesenseDfuState.dfuError(_) = state {
                errorStateExpectation.fulfill()
            }
        }

        let errorExpectation = self.expectation(description: "error")
        self.dfuErrorHandler = { error in
            errorExpectation.fulfill()
        }

        dfuApi.startDfuScan()

        waitForExpectations(timeout: 1, handler: nil)

        XCTAssert(dfuApi.getDfuDevices().count == 0)
    }

    func testStateDescriptions() {
        XCTAssert(MovesenseDfuState.dfuInit.description == "dfuInit")
        XCTAssert(MovesenseDfuState.dfuDiscovery.description == "dfuDiscovery")
        XCTAssert(MovesenseDfuState.dfuUpdate.description == "dfuUpdate")
        XCTAssert(MovesenseDfuState.dfuCompleted.description == "dfuCompleted")
        XCTAssert(MovesenseDfuState.dfuError(MovesenseDfuError.integrityError("")).description
                  == "dfuError: integrityError()")
    }
}

extension MovesenseDfuTests: MovesenseDfuApiDelegate {

    func movesenseDfuApiStateChanged(_ api: MovesenseDfuApi, state: MovesenseDfuState) {
        NSLog("dfuStateChanged(\(state))")
        self.dfuStateChangedHandler!(state)
    }

    func movesenseDfuApiDeviceDiscovered(_ api: MovesenseDfuApi, device: MovesenseDfuDevice) {
        self.dfuDeviceDiscoveredHandler!(device)
    }

    func movesenseDfuApiUpdateProgress(_ api: MovesenseDfuApi, for part: Int, outOf totalParts: Int,
                                       to progress: Int, currentSpeed: Double, avgSpeed: Double) {
        self.dfuUpdateProgressHandler!(part, totalParts, progress, currentSpeed, avgSpeed)
    }

    func movesenseDfuApiOnError(_ api: MovesenseDfuApi, error: MovesenseDfuError) {
        NSLog("dfuOnError(\(error))")
        self.dfuErrorHandler!(error)
    }
}
