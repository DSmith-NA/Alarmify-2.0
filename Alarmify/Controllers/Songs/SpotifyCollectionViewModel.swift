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
    let playlistMapObservable = PublishSubject<SpotifyMap>()
    let filteredTracksObservable = PublishSubject<[PlaylistTrack]>()
    
    private(set) var playlistMap: SpotifyMap?
    private var playlistMapDisposable: Disposable?
   
    override init() {
        super.init()
        subscribeToPlaylistMap()
    }
    
    deinit {
        unsubscribeToPlaylistMap()
    }
    
    func subscribeToPlaylistMap() {
        playlistMapDisposable = SpotifyManager.instance.playlistTrackMap.asObservable().subscribe {
            [weak self]
            event in
            switch(event) {
                case .next(let spotifyMap):
                    self?.playlistMap = spotifyMap
                    self?.playlistMapObservable.onNext(spotifyMap)
                case .error(let error):
                    print("Emission of Playlist Map failed: \(error.localizedDescription)")
                case .completed:
                    print("Spotify Manager completed emissions")
            }
        }
    }
    
    func unsubscribeToPlaylistMap() {
        playlistMapDisposable?.dispose()
    }
    
    func filterTracksBy(type: FilterType, searchText: String) -> [PlaylistTrack] {
        var filteredTracks = [PlaylistTrack]()
        guard let playlistMap = playlistMap else { return filteredTracks }
        
        let searchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        switch (type) {
            case .tracks:
                filteredTracks += playlistMap.values.flatMap { $0 }.filter {
                    track in
                    track.track.name.lowercased().contains(searchText)
                }
            
            case .playlists:
                filteredTracks += playlistMap.filter {
                    playlist in
                    playlist.key.name.lowercased().contains(searchText)
                    }.values.flatMap { $0 }
            
            case .artists:
                filteredTracks += playlistMap.values.flatMap { $0 }.filter {
                    track in
                    track.track.artists.contains {
                        artist in
                        artist.name.lowercased().contains(searchText)
                    }
                }
        }
        return filteredTracks
    }
}
