//
// RecordingsViewModel.swift
// MovesenseShowcase
//
// Copyright (c) 2018 Suunto. All rights reserved.
//

import Foundation
import MovesenseApi

struct RecordingViewModel {

    let uuid: UUID
    let sensorSerial: String
    let resourceName: String
    let resourceAbbreviation: String
    let duration: String
    let parameters: [(String, String)]
    let dateShort: String
    let dateLong: String
    let dateLongYear: String
    let timeShort: String
    let streamSize: String
}

class RecordingsViewModel: Observable {

    internal var observations: [Observation] = [Observation]()
    private(set) var observationQueue: DispatchQueue = DispatchQueue.global()

    private let sectionDateFormatter: DateFormatter = DateFormatter()
    private let dateShortFormatter: DateFormatter = DateFormatter()
    private let dateLongFormatter: DateFormatter = DateFormatter()
    private let dateLongYearFormatter: DateFormatter = DateFormatter()
    private let timeShortFormatter: DateFormatter = DateFormatter()
    private let durationFormatter: DateComponentsFormatter = DateComponentsFormatter()
    private let sizeFormatter: ByteCountFormatter = ByteCountFormatter()

    private var recorderFiles: [RecorderFile]

    init() {
        recorderFiles = RecorderApi.instance.getRecords().sorted { $0.startDate > $1.startDate }

        sectionDateFormatter.dateFormat = "dd MMMM YYYY"
        dateShortFormatter.dateFormat = "dd MMM"
        dateLongFormatter.dateFormat = "dd MMMM"
        dateLongYearFormatter.dateFormat = "dd MMMM YYYY"
        timeShortFormatter.dateFormat = "HH:mm"

        durationFormatter.maximumUnitCount = 3
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute, .second]

        sizeFormatter.allowedUnits = [.useKB, .useMB]

        RecorderApi.instance.addObserver(self)
    }

    func getRecordSectionCount() -> Int {
        return getRecords().count
    }

    func getRecordCount(in section: Int) -> Int {
        guard let sectionRecordCount = getRecords()[safe: section]?.1.count else {
            return 0
        }

        return sectionRecordCount
    }

    // TODO: Cache viewmodels?
    func getRecord(_ indexPath: IndexPath) -> RecordingViewModel? {
        return getRecords()[safe: indexPath.section]?.items[safe: indexPath.item]
    }

    func getRecords() -> [(section: String, items: [RecordingViewModel])] {
        let records: [Date: [RecordingViewModel]] = recorderFiles.reduce(into: [:]) { months, file in
            let sectionComponents = Calendar.current.dateComponents([.year, .month, .day], from: file.startDate)
            guard let sectionDate = DateComponents(calendar: Calendar.current, year: sectionComponents.year,
                                                   month: sectionComponents.month,
                                                   day: sectionComponents.day).date else { return }

            let viewModel = RecordingViewModel(
                uuid: file.uuid,
                sensorSerial: file.serialNumber,
                resourceName: file.resourceType.resourceName,
                resourceAbbreviation: file.resourceType.resourceAbbreviation,
                duration: durationFormatter.string(from: file.startDate, to: file.endDate) ?? "N/A",
                parameters: file.parameters?.map { ($0.key + ":", $0.value) } ?? [],
                dateShort: dateShortFormatter.string(from: file.startDate),
                dateLong: dateLongFormatter.string(from: file.startDate),
                dateLongYear: dateLongYearFormatter.string(from: file.startDate),
                timeShort: timeShortFormatter.string(from: file.startDate),
                streamSize: sizeFormatter.string(fromByteCount: file.fileSize))

            months[sectionDate, default: [RecordingViewModel]()].append(viewModel)
        }

        return records.map { ($0.key, $0.value) }.sorted { $0.0 > $1.0 }.map { (date, viewModels) in
            return (sectionDateFormatter.string(from: date), viewModels)
        }
    }

    func tempCopyRecord(_ record: RecordingViewModel) -> URL? {
        guard let recorderFile = (recorderFiles.first { $0.uuid == record.uuid }) else { return nil }

        return RecorderApi.instance.tempCopyRecord(recorderFile)
    }

    func tempCopyRecords(indexPaths: [IndexPath]) -> [URL] {
        let recorderFiles = indexPaths.compactMap { getRecorderFile(with: $0) }

        return recorderFiles.compactMap { RecorderApi.instance.tempCopyRecord($0) }
    }

    func tempClear() {
        RecorderApi.instance.tempClear()
    }

    func removeRecord(_ indexPath: IndexPath) {
        guard let record = getRecords()[safe: indexPath.section]?.items[safe: indexPath.item],
              let recorderFile = (recorderFiles.first { $0.uuid == record.uuid }) else {

            return
        }

        RecorderApi.instance.removeRecord(recorderFile)
    }

    private func getRecorderFile(with indexPath: IndexPath) -> RecorderFile? {
        guard let record = getRecords()[safe: indexPath.section]?.items[safe: indexPath.item],
              let recorderFile = (recorderFiles.first { $0.uuid == record.uuid }) else {

            return nil
        }

        return recorderFile
    }

    private func updateRecords() {
        DispatchQueue.global().async { [weak self] in
            self?.recorderFiles = RecorderApi.instance.getRecords().sorted { $0.startDate > $1.startDate }
            self?.notifyObservers(RecorderObserverEvent.recordsUpdated)
        }
    }
}

extension RecordingsViewModel: Observer {

    func handleEvent(_ event: ObserverEvent) {
        guard let event = event as? RecorderObserverEvent else { return }

        switch event {
        case .idle: updateRecords()
        case .recordsUpdated: updateRecords()
        case .recorderError(let error): NSLog("RecordsViewModel:recorderError: \(error)")
        default: return
        }
    }
}
