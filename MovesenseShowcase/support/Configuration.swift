//
//  Configuration.swift
//  MovesenseShowcase
//
//  Copyright © 2018 Suunto. All rights reserved.
//

import Foundation

class Configuration {

    static let bundleIdentifier: String? = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    static let bundleDisplayName: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    static let bundleVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    static let bundleBuild: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

    static func getAppStoreVersion() -> String? {
        guard let bundleIdentifier = Configuration.bundleIdentifier,
              let appStoreUrl = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)"),
              let appStoreData = try? Data(contentsOf: appStoreUrl),
              let appStoreJson = (try? JSONSerialization.jsonObject(with: appStoreData,
                                                                    options: [.allowFragments])) as? [String: Any] else {

            NSLog("Unable to fetch data from App Store.")

            return nil
        }

        if let appStoreResult = (appStoreJson["results"] as? [Any])?.first as? [String: Any],
           let appStoreVersion = appStoreResult["version"] as? String {

            return appStoreVersion
        }

        NSLog("No results from App Store.")

        return nil
    }

    static func getInstallationDate() -> Date? {
        guard let urlToDocumentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
              let attributes = try? FileManager.default.attributesOfItem(atPath: urlToDocumentsFolder.path),
              let installationDate = attributes[FileAttributeKey.creationDate] as? Date else {

            return nil
        }

        return installationDate
    }

    static func getUpdateDate() -> Date? {
        guard let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let attributes = try? FileManager.default.attributesOfItem(atPath: infoPath),
              let updateDate = attributes[FileAttributeKey.modificationDate] as? Date else {

            return nil
        }

        return updateDate
    }
}
