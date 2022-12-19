//
// MovesenseEvent.swift
// MovesenseApi
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

// Request events
public enum MovesenseEvent {

    case acc(MovesenseRequest, MovesenseAcc)
    case ecg(MovesenseRequest, MovesenseEcg)
    case gyroscope(MovesenseRequest, MovesenseGyro)
    case heartRate(MovesenseRequest, MovesenseHeartRate)
}

extension MovesenseEvent: CustomStringConvertible {

    public var description: String {
        switch self {
        case .acc(let request, let acc): return "request\n\(request)\nacc\n\(acc)"
        case .ecg(let request, let ecg): return "request\n\(request)\necg\n\(ecg)"
        case .gyroscope(let request, let ecg): return "request\n\(request)\ngyro\n\(ecg)"
        case .heartRate(let request, let hr): return "request\n\(request)\n\(hr.average) \(hr.rrData)"
        }
    }
}

extension MovesenseEvent: Codable {

    private enum CodingKeys: String, CodingKey {
        case acc
        case ecg
        case gyroscope
        case heartRate
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .acc(_, let acc):
            try container.encode(acc, forKey: .acc)
        case .ecg(_, let ecg):
            try container.encode(ecg, forKey: .ecg)
        case .gyroscope(_, let gyro):
            try container.encode(gyro, forKey: .gyroscope)
        case .heartRate(_, let hr):
            try container.encode(hr, forKey: .heartRate)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let acc = try? container.decode(MovesenseAcc.self, forKey: .acc) {
            self = MovesenseEvent.acc(MovesenseRequest(resourceType: .acc,
                                                       method: .subscribe,
                                                       parameters: nil),
                                      acc)
            return
        }

        if let ecg = try? container.decode(MovesenseEcg.self, forKey: .ecg) {
            self = MovesenseEvent.ecg(MovesenseRequest(resourceType: .ecg,
                                                       method: .subscribe,
                                                       parameters: nil),
                                      ecg)
            return
        }

        if let gyro = try? container.decode(MovesenseGyro.self, forKey: .gyroscope) {
            self = MovesenseEvent.gyroscope(MovesenseRequest(resourceType: .gyro,
                                                             method: .subscribe,
                                                             parameters: nil),
                                            gyro)
            return
        }

        if let hr = try? container.decode(MovesenseHeartRate.self, forKey: .heartRate) {
            self = MovesenseEvent.heartRate(MovesenseRequest(resourceType: .heartRate,
                                                             method: .subscribe,
                                                             parameters: nil),
                                            hr)
            return
        }

        throw MovesenseError.decodingError("Decoding Error: \(container)")
    }
}
