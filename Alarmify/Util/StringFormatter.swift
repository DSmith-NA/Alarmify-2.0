//
//  StringFormatter.swift
//  Alarmify
//
//  Created by David Smith on 9/10/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation

class StringFormatter {
    
    enum Formatter {
        case date
        case time
    }
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }()
    
    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static func getStringFor(date: Date, type: Formatter) -> String? {
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
