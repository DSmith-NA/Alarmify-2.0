//
//  Constants.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import PopupDialog

// TODO: Hide These Values
let client_id = "157d36bbc66b42869779f13f3a92a27a"
let client_secret = "d943b4d558244554a921657db583aac3"
let redirect_url = "alarmify-login://callback"

// MARK: CollectionViewCell ReuseId
let tracks_collection_cell_id = "SpotifyTrackCollectionViewCell"
let alarm_view_collection_cell_id = "AlarmViewCollectionViewCell"

// MARK: User Defaults
let alarm_key = "Alarm_Key"

// MARK: SpotifyAlarm Coding Variables
let spotify_date = "date"
let spotify_track_name = "trackName"
let spotify_track_uri = "trackUri"
let spotify_track_image = "trackImage"

// MARK: Misc
let weird_ass_font = "Zapf Dingbats"
let spotify_alarm_path = "/SpotifyAlarm"


// Popup DarkMode
func customizePopupViewForDarkMode() {
    // Customize dialog appearance
    let pv = PopupDialogDefaultView.appearance()
    pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
    pv.titleColor   = .white
    pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
    pv.messageColor = UIColor(white: 0.8, alpha: 1)
    
    // Customize the container view appearance
    let pcv = PopupDialogContainerView.appearance()
    pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
    pcv.cornerRadius    = 2
    pcv.shadowEnabled   = true
    pcv.shadowColor     = .black
    
    // Customize overlay appearance
    let ov = PopupDialogOverlayView.appearance()
    ov.blurEnabled     = true
    ov.blurRadius      = 30
    ov.liveBlurEnabled = true
    ov.opacity         = 0.7
    ov.color           = .black
    
    // Customize default button appearance
    let db = DefaultButton.appearance()
    db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
    db.titleColor     = .white
    db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
    db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    
    // Customize cancel button appearance
    let cb = CancelButton.appearance()
    cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
    cb.titleColor     = UIColor(white: 0.6, alpha: 1)
    cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
    cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
}
