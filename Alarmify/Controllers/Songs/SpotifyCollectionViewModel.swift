//
//  SpotifyCollectionViewModel.swift
//  Alarmify
//
//  Created by David Smith on 6/17/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import RxSwift
import Spartan

enum FilterType {
    case tracks
    case playlists
    case artists
}

class SpotifyCollectionViewModel: NSObject {
    let filteredTracksObservable = PublishSubject<[PlaylistTrack]>()
    let spotifyPlaylistsObservable = PublishSubject<[SpotifyPlaylist]>()
    
    private var spotifyPlaylistsDisposable: Disposable?
    private(set) var spotifyPlaylists: [SpotifyPlaylist]?
   
    override init() {
        super.init()
        subscribeToSpotifyPlaylists()
    }
    
    deinit {
        unsubscribeToSpotifyPlaylists()
    }
    
    func subscribeToSpotifyPlaylists() {
        
        spotifyPlaylistsDisposable = SpotifyManager.instance.spotifyPlaylists.asObservable().subscribe {
            [weak self]
            event in
            switch(event) {
                case .next(let spotifyPlaylists):
                    self?.spotifyPlaylists = spotifyPlaylists
                    self?.spotifyPlaylistsObservable.onNext(spotifyPlaylists)
                case .error(let error):
                    print("Emission of Spotify Playlists failed: \(error.localizedDescription)")
                case .completed:
                    print("Spotify Manager completed emissions")
            }
        }
    }
    
    func unsubscribeToSpotifyPlaylists() {
        spotifyPlaylistsDisposable?.dispose()
    }
    
    func filterTracksBy(type: FilterType, searchText: String) -> [PlaylistTrack] {
        var filteredTracks = [PlaylistTrack]()
        guard let playlists = spotifyPlaylists else { return filteredTracks }
        
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        switch (type) {
            case .tracks:
                filteredTracks += playlists.flatMap { $0.tracks }.filter {
                    track in
                    track.track.name.lowercased().contains(searchText)
                }
            
            case .playlists:
                filteredTracks += playlists.filter {
                    playlist in
                    playlist.name.lowercased().contains(searchText)
                    }.flatMap { $0.tracks }
            
            case .artists:
                filteredTracks += playlists.flatMap { $0.tracks }.filter {
                    track in
                    track.track.artists.contains {
                        artist in
                        artist.name.lowercased().contains(searchText)
                    }
                }
        }
        return filteredTracks
    }
    
    func addAlarm(_ alarm: SpotifyAlarm, datePicker: UIDatePicker?) {
        guard let datePicker = datePicker else { return }
        let alarmData = UserDefaults.standard.object(forKey: alarm_key) as? NSData
        guard let finalAlarmData = alarmData,
            var spotifyAlarms = NSKeyedUnarchiver.unarchiveObject(with: finalAlarmData as Data) as? [SpotifyAlarm] else {
                var spotifyAlarms = [SpotifyAlarm]()
                spotifyAlarms.append(alarm)
                updateUserDefaults(with: spotifyAlarms)
                return
        }
        
        spotifyAlarms = spotifyAlarms.filter {
            alarm in
            alarm.date != datePicker.date
        }
        
        spotifyAlarms.append(alarm)
        updateUserDefaults(with: spotifyAlarms)
    }
    
    private func updateUserDefaults(with alarms: [SpotifyAlarm]) {
        let userData = NSKeyedArchiver.archivedData(withRootObject: alarms)
        UserDefaults.standard.set(userData, forKey: alarm_key)
    }
}
