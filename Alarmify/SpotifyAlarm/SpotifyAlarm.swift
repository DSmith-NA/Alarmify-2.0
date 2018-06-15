//
//  SpotifyAlarm.swift
//  Alarmify
//
//  Created by David on 4/8/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation

class SpotifyAlarm: NSObject, NSCoding {
    let date: Date
    let trackName: String
    let trackUri: String
    var shouldPlay = false
    
    init(date: Date, trackName: String, trackUri: String) {
        self.date = date
        self.trackName = trackName
        self.trackUri = trackUri
        super.init()
    }
    
    class func path() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let path = documentsPath?.appending(spotify_alarm_path)
        return path!
    }
    
    // MARK: Encoder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: spotify_date)
        aCoder.encode(trackName, forKey: spotify_track_name)
        aCoder.encode(trackUri, forKey: spotify_track_uri)
    }
    
    // MARK: Decoder
    convenience required init?(coder aDecoder: NSCoder) {
        guard let date = aDecoder.decodeObject(forKey: spotify_date) as? Date,
            let trackName = aDecoder.decodeObject(forKey: spotify_track_name) as? String,
            let trackUri = aDecoder.decodeObject(forKey: spotify_track_uri) as? String
            else {
                return nil
        }
        self.init(date: date, trackName: trackName, trackUri: trackUri)
    }
}
