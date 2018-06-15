//
//  SpotifyManager.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import Spartan
import SpotifyLogin
import RxSwift
import AudioToolbox.AudioServices

class SpotifyManager {
    static let instance = SpotifyManager()
    private let playlistPubSub = PublishSubject<[SimplifiedPlaylist]>()
    private weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private var appStartTime: Date
    
    private(set) var playlists: [SimplifiedPlaylist]?
    private(set) var tracks = Variable<[PlaylistTrack]>([])
    private(set) var playlistTrackMap = Variable<[SimplifiedPlaylist : [PlaylistTrack]]>([:])
    
    private(set) var vibrateDisposable: Disposable?
    private(set) var snoozeDisposable: Disposable?
    
    var spotifyAlarmList = [SpotifyAlarm]()
    
    private init() {
        appStartTime = Date()
        subscribeToPubSub()
        monitorForAlarm()
    }
    
    deinit {
        unsubscribeToPubSub()
        subscribeForSnooze(alarm: nil, shouldSubscribe: false)
        subscribeForVibrate(false)
    }
    
    private func subscribeToPubSub() {
       _ = playlistPubSub.subscribe {
            [weak self]
            event in
            switch event {
            case .next(let value):
                self?.playlists = value
                self?.fetchTracks()
            case .error(let error):
                print(error)
            case .completed:
                print("Playlist PubSub no longer emitting events")
            }
        }
    }
    
    public func unsubscribeToPubSub() {
        playlistPubSub.dispose()
    }
    
    public func fetchPlaylists() {
        _ = fetchPlaylistTimer.subscribe {
            _ in
            Spartan.getMyPlaylists(success: {
                [weak self]
                pagingObject in
                self?.playlistPubSub.onNext(pagingObject.items)
                }, failure: {
                    spartanError in
                    print(spartanError)
            })
        }
    }
    
    private func fetchTracks() {
        self.playlists?.forEach {
            playlist in
            getPlaylistTracks(playlist: playlist) {
                [weak self]
                playlistTracks in
                let sortedPlaylistTracks = playlistTracks.sorted {
                    playlistTrack1, playlistTrack2 in
                    playlistTrack1.track.name < playlistTrack2.track.name
                }
                self?.playlistTrackMap.value.updateValue(sortedPlaylistTracks, forKey: playlist)
                self?.tracks.value.append(contentsOf: sortedPlaylistTracks)
                _ = self?.tracks.value.sorted {
                    (playlistTrack1, playlistTrack2) in
                    playlistTrack1.track.name < playlistTrack2.track.name
                }
            }
        }
    }
    
    private func getPlaylistTracks(playlist: SimplifiedPlaylist, completion: @escaping ([PlaylistTrack]) -> ()) {
        Spartan.getPlaylistTracks(userId: playlist.owner.id as! String, playlistId: playlist.id as! String, success: {
            [weak self]
            pagingObject in
            let filteredTracks = pagingObject.items.filter {
                playlistTrack in
                self != nil && !(self!.tracks.value as NSArray).contains(playlistTrack)
            }
            completion(filteredTracks)
            }, failure: {
                spartanError in
                print(spartanError)
        })
    }
    
    private func monitorForAlarm() {
        _ = clockTimer.subscribe {
            [weak self]
            _ in
            guard let strongSelf = self else { return }
            let filteredList = strongSelf.spotifyAlarmList.filter {
                alarm in
                alarm.date.timeIntervalSinceNow.sign == .minus
                }.filter {
                    alarm in
                    !alarm.shouldPlay
            }
            guard filteredList.count > 0 else { return }
            let alarm = filteredList.first!
            let index = strongSelf.spotifyAlarmList.index(of: alarm)
            alarm.shouldPlay = true
            strongSelf.spotifyAlarmList.remove(at: index!)
            let userData = NSKeyedArchiver.archivedData(withRootObject: strongSelf.spotifyAlarmList)
            UserDefaults.standard.set(userData, forKey: alarm_key)
            if (alarm.date < strongSelf.appStartTime) { return }
            strongSelf.appDelegate?.spotifyPlayer?.playSpotifyURI(alarm.trackUri, startingWith: 0, startingWithPosition: 0, callback: nil)
            strongSelf.presentDismissAlarm(alarm)
        }
    }
    
    private func presentDismissAlarm(_ alarm: SpotifyAlarm) {
        let alertsVC = UIAlertController(title: "⏰", message: alarm.trackName, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "😡", style: .destructive) {
            [weak self]
            _ in
            self?.stopPlayer()
            self?.subscribeForSnooze(alarm: alarm, shouldSubscribe: false)
        }
        let snoozeAction = UIAlertAction(title: "😴", style: .default) {
            [weak self]
            _ in
            self?.stopPlayer()
            self?.subscribeForSnooze(alarm: alarm, shouldSubscribe: true)
        }
        alertsVC.addAction(snoozeAction)
        alertsVC.addAction(dismissAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertsVC, animated: true, completion: nil)
        subscribeForVibrate(true)
    }
    
    private func stopPlayer() {
        appDelegate?.spotifyPlayer?.setIsPlaying(false, callback: nil)
        subscribeForVibrate(false)
    }
    
    private func subscribeForVibrate(_ shouldSubscribe: Bool) {
        if shouldSubscribe {
            vibrateDisposable = vibrateTimer.subscribe {
                _ in
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        } else {
            vibrateDisposable?.dispose()
        }
    }
    
    private func subscribeForSnooze(alarm: SpotifyAlarm?, shouldSubscribe: Bool) {
        if shouldSubscribe {
            guard let alarm = alarm else { return }
            snoozeDisposable = snoozeTimer.subscribe {
                [weak self]
                _ in
                self?.appDelegate?.spotifyPlayer?.playSpotifyURI(alarm.trackUri, startingWith: 0, startingWithPosition: 0, callback: nil)
                self?.presentDismissAlarm(alarm)
            }
        } else {
            snoozeDisposable?.dispose()
        }
    }
}
