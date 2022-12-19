//
// Settings.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation

class Settings {

    private static let firstLaunchKey: String = "com.movesense.firstLaunch"
    private static let termsAcceptedKey: String = "com.movesense.termsAccepted"
    private static let previousSensorsKey: String = "com.movesense.previousSensors"
    private static let previousDashboardLaunchDateKey: String = "com.movesense.previousDashboardLaunchDate"

    static var isFirstLaunch: Bool {
        get {
            return UserDefaults.standard.value(forKey: firstLaunchKey) as? Bool ?? true
        }

        set {
            UserDefaults.standard.set(newValue, forKey: firstLaunchKey)
        }
    }

    static var isTermsAccepted: Bool {
        get {
            return UserDefaults.standard.value(forKey: termsAcceptedKey) as? Bool ?? false
        }

        set {
            UserDefaults.standard.set(newValue, forKey: termsAcceptedKey)
        }
    }

    static var previousSensors: [DeviceViewModel] {
        get {
            let decoder = PropertyListDecoder()
            let devicesData = UserDefaults.standard.value(forKey: previousSensorsKey) as? [Data] ?? []
            let decodedDevices = devicesData.compactMap { try? decoder.decode(DeviceViewModel.self, from: $0) }

            return decodedDevices
        }

        set(newValue) {
            let encoder = PropertyListEncoder()
            let encodedDevices = newValue.compactMap { try? encoder.encode($0) }

            UserDefaults.standard.set(encodedDevices, forKey: previousSensorsKey)
        }
    }

    static var previousDashboardLaunchDate: Date {
        get {
            return UserDefaults.standard.value(forKey: previousDashboardLaunchDateKey) as? Date ?? Date()
        }

        set {
            UserDefaults.standard.set(newValue, forKey: previousDashboardLaunchDateKey)
        }
    }
}
