//
//  AlarmsViewModel.swift
//  Alarmify
//
//  Created by David Smith on 6/16/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import RxSwift

class AlarmsViewModel {
    
    private(set) var _alarms = Variable<[SpotifyAlarm]>([])
    var alarms: Observable<[SpotifyAlarm]> {
        return _alarms.asObservable().flatMapLatest{ (alarms) -> Observable<[SpotifyAlarm]> in
            let filteredAlarms = alarms.filter{ alarm in
                alarm.date.timeIntervalSinceNow.sign == .plus
                }.sorted{ alarm1, alarm2 in
                    alarm1.date.compare(alarm2.date) == .orderedAscending
            }
            return Observable.just(filteredAlarms)
        }
    }
    
    // TODO: This should be refactored to update whenever the spotifyAlarmList changes
    func fetchAlarms() {
        guard let alarmData = UserDefaults.standard.object(forKey: alarm_key) as? NSData,
            let spotifyAlarms = NSKeyedUnarchiver.unarchiveObject(with: alarmData as Data) as? [SpotifyAlarm] else { return }
        _alarms.value = spotifyAlarms
    }
}
