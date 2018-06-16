//
//  SpotifyTracksCollectionViewController.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import Spartan
import RxSwift
import SDWebImage

class SpotifyTracksViewController: BasicViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var spotifyTracksDisposable: Disposable?
    var datePicker: UIDatePicker?
    var filteredTracks = [PlaylistTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        searchBar.delegate = self
        initCollectionView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }
    
    private func addObservers() {
        spotifyTracksDisposable = spotifyManager.tracks.asObservable().subscribe {
            [weak self]
            event in
            switch event {
            case .next:
                self?.activityIndicator.stopAnimating()
                self?.collectionView?.reloadData()
            case .error(let error):
                print(error)
            case .completed:
                print("SpotifyTracks stopped emissions")
            }
        }
    }
    
    private func removeObservers() {
        spotifyTracksDisposable?.dispose()
        spotifyTracksDisposable = nil
    }
    
    private func initCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: tracks_collection_cell_id, bundle: nil), forCellWithReuseIdentifier: tracks_collection_cell_id)
        collectionView.backgroundView = BackgroundView(frame: view.frame)
    }
    
    private func isFiltered() -> Bool {
        return filteredTracks.count > 0 && filteredTracks.count < spotifyManager.tracks.value.count
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UISearchBarDelegate
extension SpotifyTracksViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTracks = spotifyManager.tracks.value.filter {
            track in
            track.track.name.lowercased().contains(searchText.lowercased())
        }
        
        filteredTracks += spotifyManager.tracks.value.filter {
            track in
            !track.track.artists.filter {
                artist in
                artist.name.lowercased().contains(searchText.lowercased())
            }.isEmpty
        }
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension SpotifyTracksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width, height: 80)
    }
}

// MARK: UICollectionViewDataSource
extension SpotifyTracksViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let playlistCount = spotifyManager.playlists != nil ? spotifyManager.playlists!.count : 1
        let count = isFiltered() ? 1 : playlistCount
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let playlists = spotifyManager.playlists else { return 0 }
        guard let tracks = spotifyManager.playlistTrackMap.value[playlists[section]] else { return 0 }
        let count = isFiltered() ? filteredTracks.count : tracks.count
        return count
    }
}

// MARK: UICollectionViewDelegate
extension SpotifyTracksViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tracks_collection_cell_id, for: indexPath) as! SpotifyTrackCollectionViewCell
        let playlist = spotifyManager.playlists![indexPath.section]
        let tracks = spotifyManager.playlistTrackMap.value[playlist]
        let track = isFiltered() ? filteredTracks[indexPath.row] : tracks![indexPath.row] //spotifyManager.tracks.value[indexPath.row]
        cell.trackLabel.text = track.track.name
        var artistLabel = ""
        track.track.artists.filter {
            artist in
            artist != track.track.artists.last
            }.forEach {
                artist in
                artistLabel += artist.name + ", "
        }
        artistLabel += track.track.artists.last!.name
        cell.artistsLabel.text = artistLabel
        guard let albumUrl = track.track.album.images[0].url else {return cell}
        cell.albumArtwork.sd_setImage(with: URL(string: albumUrl), completed: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SpotifyTrackCollectionViewCellHeader", for: indexPath) as! SpotifyTrackCollectionViewCellHeader
        header.playlistTitle.text = spotifyManager.playlists?[indexPath.section].name
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = spotifyManager.playlists![indexPath.section]
        let tracks = spotifyManager.playlistTrackMap.value[playlist]
        let track = isFiltered() ? filteredTracks[indexPath.row] : tracks![indexPath.row]
        guard let datePicker = datePicker else { return }
        let spotifyAlarm = SpotifyAlarm(date: datePicker.date, trackName: track.track.name, trackUri: track.track.uri)
        spotifyManager.spotifyAlarmList = spotifyManager.spotifyAlarmList.filter {
            alarm in
            alarm.date != datePicker.date
        }
        spotifyManager.spotifyAlarmList.append(spotifyAlarm)
        let userData = NSKeyedArchiver.archivedData(withRootObject: spotifyManager.spotifyAlarmList)
        UserDefaults.standard.set(userData, forKey: alarm_key)
        navigationController?.popToRootViewController(animated: true)
    }
}
