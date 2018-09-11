//
//  AlarmViewCollectionViewCell.swift
//  Alarmify
//
//  Created by David on 3/25/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit

class AlarmViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    func configureCell(withAlarm alarm: SpotifyAlarm) {
        dateLabel.text = StringFormatter.getStringFor(date: alarm.date, type: .date)
        timeLabel.text = StringFormatter.getStringFor(date: alarm.date, type: .time)
        trackLabel.text = alarm.trackName
    }
}
