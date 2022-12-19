//
// CsvEncodingTests.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import XCTest
@testable import MovesenseApi

let accJson: String = """
                      {"acc":{"Timestamp":599025762,"ArrayAcc":[{"x":0.31347095966339111,"y":-0.31347095966339111,"z":9.9281759262084961},{"x":0.28475606441497803,"y":-0.31586387753486633,"z":9.949711799621582},{"x":0.33022132515907288,"y":-0.26800569891929626,"z":9.9353542327880859},{"x":0.33022132515907288,"y":-0.28236314654350281,"z":9.8922824859619141}]}}
                      """

let ecgJson: String = """
                      {"ecg":{"Timestamp":601488596,"Samples":[-74,-79,-79,-76,-75,-76,-75,-74,-72,-74,-80,-82,-80,-80,-85,-83]}}
                      """

class CsvEncodingTests: XCTestCase {
    var csvEncoder: CsvEncoder!

    override func setUp() {
        self.csvEncoder = CsvEncoder()
    }

    func testEncodeNil() {
        let optional: Int? = nil
        let value = try! csvEncoder.encode(optional)

        XCTAssertEqual(value, "".data(using: .utf8))
    }

    func testEncodeArrayOfNils() {
        let optional: [Int?] = [nil, nil, nil]
        let value = try! csvEncoder.encode(optional)

        let valueString = String(bytes: value, encoding: .utf8)!

        XCTAssertEqual(valueString, "\n,\n,")
    }

    func testEncodeFalse() {
        let value = try! csvEncoder.encode(false)
        XCTAssertEqual(value, "0".data(using: .utf8))
    }

    func testEncodeTrue() {
        let value = try! csvEncoder.encode(true)
        XCTAssertEqual(value, "1".data(using: .utf8))
    }

    func testEncodeInt() {
        let value = try! csvEncoder.encode(Int.max)
        XCTAssertEqual(value, String(Int.max).data(using: .utf8))
    }

    func testEncodeUInt() {
        let value = try! csvEncoder.encode(UInt.max)
        XCTAssertEqual(value, String(UInt.max).data(using: .utf8))
    }

    func testEncodeFloat() {
        let value = try! csvEncoder.encode(Float.pi)
        XCTAssertEqual(value, String(Float.pi).data(using: .utf8))
    }

    func testEncodeDouble() {
        let value = try! csvEncoder.encode(Double.pi)
        XCTAssertEqual(value, String(Double.pi).data(using: .utf8))
    }

    func testEncodeArray() {
        let value = try! csvEncoder.encode([1, 2, 3])

        let valueString = String(bytes: value, encoding: .utf8)!

        XCTAssertEqual(valueString, "1\n,2\n,3")
    }

    func testEncodeDictionary() {
        let dictionary = ["a": 1, "b": 2, "c": 3]
        let value = try! csvEncoder.encode(dictionary)

        let encodedString = String(bytes: value, encoding: .utf8)!
        let splitString = encodedString.split(separator: ",")

        XCTAssert(splitString.contains("1"))
        XCTAssert(splitString.contains("2"))
        XCTAssert(splitString.contains("3"))
    }

    func testEncodeEmptyEcg() {
        let event = MovesenseEcg(timestamp: 0, samples: [])
        let value = try! csvEncoder.encode(event)

        XCTAssertEqual(value, "0,".data(using: .utf8))
    }

    func testEncodeEcg() {
        let event = MovesenseEcg(timestamp: 1234567, samples: [1, 2, 3, 4, 5, 6, 7])
        let value = try! csvEncoder.encode(event)

        let valueString = String(bytes: value, encoding: .utf8)!

        XCTAssertEqual(valueString, "1234567,1\n,2\n,3\n,4\n,5\n,6\n,7")
    }

    func testEncodeEmptyAcc() {
        let vectors: [MovesenseVector3D] = []
        let event = MovesenseAcc(timestamp: 0, vectors: vectors)
        let value = try! csvEncoder.encode(event)

        let valueString = String(bytes: value, encoding: .utf8)!

        XCTAssertEqual(valueString, "0,")
    }

    func testEncodeSingleAccVector() {
        let vectors: [MovesenseVector3D] = [MovesenseVector3D(x: 0.0, y: 0.0, z: 0.0)]
        let event = MovesenseAcc(timestamp: 0, vectors: vectors)
        let value = try! csvEncoder.encode(event)

        let valueString = String(bytes: value, encoding: .utf8)!

        XCTAssertEqual(valueString, "0,0.0,0.0,0.0")
    }

    func testEncodeTwoAccVectors() {
        let vectors: [MovesenseVector3D] = [MovesenseVector3D(x: 0.0, y: 0.0, z: 0.0),
                                            MovesenseVector3D(x: 1.0, y: 2.0, z: 3.0)]
        let event = MovesenseAcc(timestamp: 0, vectors: vectors)
        let value = try! csvEncoder.encode(event)

        let valueString = String(bytes: value, encoding: .utf8)!

        XCTAssertEqual(valueString, "0,0.0,0.0,0.0\n,1.0,2.0,3.0")
    }

    func testDecodeEncodeEcgJson() {
        let jsonDecoder: JSONDecoder = JSONDecoder()
        let jsonData: Data = ecgJson.data(using: .utf8)!
        let decoded = try! jsonDecoder.decode(MovesenseEvent.self, from: jsonData)
        let encoded = try! csvEncoder.encode(decoded)

        let valueString = String(bytes: encoded, encoding: .utf8)!

        XCTAssertEqual(valueString, "601488596,-74\n,-79\n,-79\n,-76\n,-75\n,-76\n,-75\n,-74\n,-72\n,-74\n,-80\n,-82\n,-80\n,-80\n,-85\n,-83")
    }

    func testDecodeEncodeAccJson() {
        let jsonDecoder: JSONDecoder = JSONDecoder()
        let jsonData: Data = accJson.data(using: .utf8)!
        let decoded = try! jsonDecoder.decode(MovesenseEvent.self, from: jsonData)
        let encoded = try! csvEncoder.encode(decoded)

        let valueString = String(bytes: encoded, encoding: .utf8)!

        XCTAssertEqual(valueString, "599025762,0.31347096,-0.31347096,9.928176\n,0.28475606,-0.31586388,9.949712\n,0.33022133,-0.2680057,9.935354\n,0.33022133,-0.28236315,9.8922825")
    }
}
