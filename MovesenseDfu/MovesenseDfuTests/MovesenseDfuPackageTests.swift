//
// MovesenseDfuPackageTests.swift
// MovesenseDfuTests
//
// Copyright © 2019 Suunto. All rights reserved.
//

import XCTest
@testable import MovesenseDfu

import CoreBluetooth
import iOSDFULibrary

class MovesenseDfuPackageTests: XCTestCase {

    private let dfuApi = DfuApi(with: CBCentralManagerMock.self)

    override func setUp() {
        super.setUp()
        dfuApi.delegate = self
        removePackagesFromDocuments()
        removePackagesFromMainBundle()
    }

    override func tearDown() {
        dfuApi.delegate = nil
        removePackagesFromDocuments()
        removePackagesFromMainBundle()
        super.tearDown()
    }

    func testGetDfuPackagesWithOneAdded() {
        // Add the bundled package to documents
        copyTestPackageToDocuments(self)

        // Get packages
        let dfuPackages = dfuApi.getDfuPackages()

        // Check that there's one added package
        XCTAssert(dfuPackages.filter { $0.fileType == .addedDfu }.count == 1)
    }

    func testGetDfuPackagesWithoutAnyAdded() {
        let dfuPackages = dfuApi.getDfuPackages()

        // Check that there's one bundled package and none added
        XCTAssert(dfuPackages.filter { $0.fileType == .bundledDfu }.count == 0)
        XCTAssert(dfuPackages.filter { $0.fileType == .addedDfu }.count == 0)
    }

    func testRemoveDocumentDfuPackage() {
        // Add the bundled package to documents
        copyTestPackageToDocuments(self)

        // Get packages
        let dfuPackages = dfuApi.getDfuPackages()

        // Check that there's one added package
        XCTAssert(dfuPackages.filter { $0.fileType == .addedDfu }.count == 1)

        // Remove the added package
        dfuApi.removeDfuPackage(dfuPackages.first!)

        // Check that there's one added package
        XCTAssert(dfuApi.getDfuPackages().filter { $0.fileType == .addedDfu }.count == 0)
    }
}

extension MovesenseDfuPackageTests: MovesenseDfuApiDelegate {

    func movesenseDfuApiStateChanged(_ api: MovesenseDfuApi, state: MovesenseDfuState) {}

    func movesenseDfuApiDeviceDiscovered(_ api: MovesenseDfuApi, device: MovesenseDfuDevice) {}

    func movesenseDfuApiUpdateProgress(_ api: MovesenseDfuApi, for part: Int, outOf totalParts: Int,
                                       to progress: Int, currentSpeed: Double, avgSpeed: Double) {}

    func movesenseDfuApiOnError(_ api: MovesenseDfuApi, error: MovesenseDfuError) {
        XCTFail(error.description)
    }
}

internal func copyTestPackageToMainBundle(_ from: AnyObject) {
    guard let bundleZipUrls: [URL] = Bundle(for: type(of: from)).urls(forResourcesWithExtension: "zip",
                                                                      subdirectory: nil) else {
        XCTFail("Couldn't get bundle for \(from.self)")
        return
    }

    bundleZipUrls.forEach {
        let mainPath = Bundle.main.bundlePath + "/\($0.lastPathComponent)"

        // Clean up first
        try? FileManager.default.removeItem(atPath: mainPath)

        do {
            try FileManager.default.copyItem(atPath: $0.path, toPath: mainPath)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}

internal func removePackagesFromMainBundle() {
    guard let bundleZipUrls: [URL] = Bundle.main.urls(forResourcesWithExtension: "zip",
                                                      subdirectory: nil) else { return }
    bundleZipUrls.forEach {
        try? FileManager.default.removeItem(atPath: $0.path)
    }
}

internal func copyTestPackageToDocuments(_ from: AnyObject) {
    guard let bundleZipUrls: [URL] = Bundle(for: type(of: from)).urls(forResourcesWithExtension: "zip",
                                                                      subdirectory: nil),
          let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {

        XCTFail("Error in copyTestPackageToDocuments for: \(from.self)")
        return
    }

    bundleZipUrls.forEach {
        let docPath = docUrl.path + "/\($0.lastPathComponent)"

        // Clean up first
        try? FileManager.default.removeItem(atPath: docPath)

        // Create Documents directory in case it's missing
        try? FileManager.default.createDirectory(at: docUrl, withIntermediateDirectories: false, attributes: nil)

        do {
            try FileManager.default.copyItem(atPath: $0.path, toPath: docPath)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}

internal func removePackagesFromDocuments() {
    guard let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
          let enumerator = FileManager.default.enumerator(atPath: docUrl.path) else {
        XCTFail("Error in removePackagesFromDocuments")
        return
    }

    enumerator.compactMap { $0 as? String }.forEach {
        let removePath = docUrl.path + "/\($0)"
        try? FileManager.default.removeItem(atPath: removePath)
    }
}
