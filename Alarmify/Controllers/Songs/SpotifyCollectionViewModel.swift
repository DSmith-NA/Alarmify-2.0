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
    
    private(set) var spotifyPlaylists = Variable<[SpotifyPlaylist]>([])
    private var disposeBag = DisposeBag()
   
    private var _spotifyAlarm = Variable<SpotifyAlarm?>(nil)
    var spotifyAlarm: Observable<SpotifyAlarm?> { return _spotifyAlarm.asObservable().distinctUntilChanged() }
    
    override init() {
        super.init()
        subscribeToSpotifyPlaylists()
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
    
    func subscribeToSpotifyPlaylists() {
        SpotifyManager.instance.spotifyPlaylists.asObservable().bind{ [weak self] playlists in
            self?.spotifyPlaylists.value = playlists
        }.disposed(by: disposeBag)
    }
    
    func filterTracksBy(type: FilterType, searchText: String) -> [PlaylistTrack] {
        var filteredTracks = [PlaylistTrack]()
        
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        switch (type) {
            case .tracks:
                filteredTracks += spotifyPlaylists.value.flatMap { $0.tracks }.filter {
                    track in
                    track.track.name.lowercased().contains(searchText)
                }
            
            case .playlists:
                filteredTracks += spotifyPlaylists.value.filter {
                    playlist in
                    playlist.name.lowercased().contains(searchText)
                    }.flatMap { $0.tracks }
            
            case .artists:
                filteredTracks += spotifyPlaylists.value.flatMap { $0.tracks }.filter {
                    track in
                    track.track.artists.contains {
                        artist in
                        artist.name.lowercased().contains(searchText)
                    }
                }
        }
        return filteredTracks
    }
    
    func addAlarm(fromTrack track: PlaylistTrack, datePicker: UIDatePicker?) -> SpotifyAlarm? {
        guard let datePicker = datePicker else { return nil }
        let trackURL = track.track.album.images[0].url
        let image: UIImage? = trackURL != nil ? try! UIImage.sd_image(with: Data(contentsOf: URL(string: trackURL!)!)) : nil
        let data = UserDefaults.standard.object(forKey: alarm_key) as? NSData
        let alarm = SpotifyAlarm(date: datePicker.date, trackName: track.track.name, trackUri: track.track.uri, image: image)
        
        guard let alarmData = data,
            var spotifyAlarms = NSKeyedUnarchiver.unarchiveObject(with: alarmData as Data) as? [SpotifyAlarm]
            else {
                var spotifyAlarms = [SpotifyAlarm]()
                spotifyAlarms.append(alarm)
                updateUserDefaults(with: spotifyAlarms)
                return alarm
        }
        
        spotifyAlarms = spotifyAlarms.filter {
            alarm in
            alarm.date != datePicker.date
        }
        
        spotifyAlarms.append(alarm)
        updateUserDefaults(with: spotifyAlarms)
        return alarm
    }
    
    private func updateUserDefaults(with alarms: [SpotifyAlarm]) {
        let userData = NSKeyedArchiver.archivedData(withRootObject: alarms)
        UserDefaults.standard.set(userData, forKey: alarm_key)
    }
}
