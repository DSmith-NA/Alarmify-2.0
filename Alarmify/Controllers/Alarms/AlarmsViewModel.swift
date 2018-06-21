//
//  AlarmsViewModel.swift
//  Alarmify
//
//  Created by David Smith on 6/16/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import RxSwift

enum Formatter {
    case date
    case time
}

private let dateFormatter = DateFormatter()
private let timeFormatter = DateFormatter()

class AlarmsViewModel: NSObject {
    
    override init() {
        dateFormatter.dateFormat = "MMM dd"
        timeFormatter.dateFormat = "h:mm a"
    }
    
    let alarmsObserver = PublishSubject<[SpotifyAlarm]?>()
    
    private(set) var alarms: [SpotifyAlarm]? {
        didSet {
            let filteredAlarms = alarms?.filter {
                alarm in
                alarm.date.timeIntervalSinceNow.sign == .plus
                }.sorted {
                    alarm1, alarm2 in
                    alarm1.date.compare(alarm2.date) == .orderedAscending
            }
            alarmsObserver.onNext(filteredAlarms)
        }
    }
    
    // TODO: This should be refactored to update whenever the spotifyAlarmList changes
    func fetchAlarms() {
        let alarmData = UserDefaults.standard.object(forKey: alarm_key) as? NSData
        guard let finalAlarmData = alarmData,
            let spotifyAlarms = NSKeyedUnarchiver.unarchiveObject(with: finalAlarmData as Data) as? [SpotifyAlarm] else { return }
        alarms = spotifyAlarms
    }
    
    func getFormattedStringFor(date: Date, type: Formatter) -> String? {
        var result: String?
        switch (type) {
            case .date:
                result = dateFormatter.string(from: date)
            case .time:
                result = timeFormatter.string(from: date)
        }
        return result
    }
}
