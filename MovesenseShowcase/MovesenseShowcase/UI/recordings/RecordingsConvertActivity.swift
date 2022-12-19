//
// RecordingsConvertActivity.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import UIKit

class RecordingsConvertActivity: UIActivity {

    override class var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return UIActivity.ActivityType(rawValue: RecordingsConvertTargetType.csv.rawValue)
    }

    override var activityTitle: String? {
        return NSLocalizedString("RECORDINGS_CONVERT_CSV_TITLE", comment: "")
    }

    override var activityImage: UIImage? {
        return UIImage(named: "icon_csv")
    }

    var preparedActivityViewController: UIViewController?
    override var activityViewController: UIViewController? {
        return preparedActivityViewController
    }

    override init() {
        super.init()
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        let recorderFiles = activityItems.compactMap { $0 as? URL }

        if recorderFiles.isEmpty {
            return false
        }

        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        let recorderFiles = activityItems.compactMap { $0 as? URL }

        if recorderFiles.isEmpty {
            activityDidFinish(false)
            return
        }

        preparedActivityViewController = RecordingsConvertViewController(activity: self, sourceFiles: recorderFiles,
                                                                         targetType: .csv)
    }

    override func activityDidFinish(_ completed: Bool) {
        super.activityDidFinish(completed)

        preparedActivityViewController = nil
    }
}
