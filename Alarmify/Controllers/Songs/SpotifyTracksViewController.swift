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
import PopupDialog

class SpotifyTracksViewController: BasicViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let viewModel = SpotifyCollectionViewModel()
    
    private var spotifyPlaylistsDisposable: Disposable?
    
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
        spotifyManager.fetchPlaylists()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObservers()
    }
    
    private func addObservers() {
        
        spotifyPlaylistsDisposable = viewModel.spotifyPlaylistsObservable.subscribe {
            [weak self]
            event in
            switch event {
                case .next(_):
                    self?.activityIndicator.stopAnimating()
                    self?.collectionView.reloadData()
                case .error(let error):
                    print("Failed to emit SpotifyPlaylists element: \(error.localizedDescription)")
                case .completed:
                    print("SpotifyCollectionViewModel stopped emitting events")
                }
        }
    }
    
    private func removeObservers() {
        spotifyPlaylistsDisposable?.dispose()
    }
    
    private func initCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: tracks_collection_cell_id, bundle: nil), forCellWithReuseIdentifier: tracks_collection_cell_id)
        collectionView.backgroundView = BackgroundView(frame: view.frame)
    }
    
    private func isFiltered() -> Bool {
        return filteredTracks.count > 0 && filteredTracks.count < spotifyManager.tracks.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UISearchBarDelegate
extension SpotifyTracksViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Filter by Tracks
        let tracksByName = viewModel.filterTracksBy(type: .tracks, searchText: searchText)
        self.filteredTracks = tracksByName
        
        // Filter By Playlist
        var filteredTracks = self.filteredTracks
        let tracksByPlaylistName = viewModel.filterTracksBy(type: .playlists, searchText: searchText).filter{!(filteredTracks as NSArray).contains($0)}
        self.filteredTracks += tracksByPlaylistName
        
        // Filter by Artist
        filteredTracks = self.filteredTracks
        let tracksByArtistsName = viewModel.filterTracksBy(type: .artists, searchText: searchText).filter{!(filteredTracks as NSArray).contains($0)}
        self.filteredTracks += tracksByArtistsName
        
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
        let playlistCount = viewModel.spotifyPlaylists != nil ? viewModel.spotifyPlaylists!.count : 1
        let count = isFiltered() ? 1 : playlistCount
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let playlists = viewModel.spotifyPlaylists else { return 0 }
        let tracks = playlists[section].tracks
        let count = isFiltered() ? filteredTracks.count : tracks.count
        return count
    }
}

// MARK: UICollectionViewDelegate
extension SpotifyTracksViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let playlists = viewModel.spotifyPlaylists else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tracks_collection_cell_id, for: indexPath) as! SpotifyTrackCollectionViewCell
        let tracks = playlists[indexPath.section].tracks
        let track = isFiltered() ? filteredTracks[indexPath.row] : tracks[indexPath.row]
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
        guard let playlists = viewModel.spotifyPlaylists else { return UICollectionReusableView() }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SpotifyTrackCollectionViewCellHeader", for: indexPath) as! SpotifyTrackCollectionViewCellHeader
        header.playlistTitle.text = isFiltered() ? "Search" :  playlists[indexPath.section].name
        header.playlistTitle.font = UIFont(name: "SFProText-Semibold", size: 17)!
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let playlists = viewModel.spotifyPlaylists,
            let datePicker = datePicker else { return }
        let tracks = playlists[indexPath.section].tracks
        let track = isFiltered() ? filteredTracks[indexPath.row] : tracks[indexPath.row]
        let trackURL = track.track.album.images[0].url
        let image: UIImage? = trackURL != nil ? try! UIImage.sd_image(with: Data(contentsOf: URL(string: trackURL!)!)) : nil
        let spotifyAlarm = SpotifyAlarm(date: datePicker.date, trackName: track.track.name, trackUri: track.track.uri, image: image)
        viewModel.addAlarm(spotifyAlarm, datePicker: datePicker)
        navigationController?.popToRootViewController(animated: true)
        showAlarmAddedPopup(spotifyAlarm)
    }
    
    private func showAlarmAddedPopup(_ alarm: SpotifyAlarm) {
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        let popup = PopupDialog(title: "You've added an alarm 🎉", message: alarm.trackName, image: alarm.image)
        popup.addButton(cancelButton)
        self.present(popup, animated: true, completion: nil)
    }
}
