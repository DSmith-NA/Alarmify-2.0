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
    private var disposeBag = DisposeBag()
    
    var datePicker: UIDatePicker?
    var filteredTracks = [PlaylistTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
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
        disposeBag = DisposeBag()
        super.viewDidDisappear(animated)
    }
    
    private func addObservers() {
        viewModel.spotifyPlaylists.asObservable().bind{ [weak self] playlists in
            guard !playlists.isEmpty else { return }
            self?.activityIndicator.stopAnimating()
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
        
        viewModel.spotifyAlarm.bind{ [weak self] item in
            guard let alarm = item else { return }
            self?.showAlarmAddedPopup(alarm)
        }.disposed(by: disposeBag)
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
        let playlistCount = viewModel.spotifyPlaylists.value.count
        let count = isFiltered() ? 1 : playlistCount
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let tracks = viewModel.spotifyPlaylists.value[section].tracks
        let count = isFiltered() ? filteredTracks.count : tracks.count
        return count
    }
}

// MARK: UICollectionViewDelegate
extension SpotifyTracksViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tracks_collection_cell_id, for: indexPath) as? SpotifyTrackCollectionViewCell
            else { return UICollectionViewCell() }
        let tracks = viewModel.spotifyPlaylists.value[indexPath.section].tracks
        let track = isFiltered() ? filteredTracks[indexPath.row] : tracks[indexPath.row]
        cell.configureCell(withTrack: track)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SpotifyTrackCollectionViewCellHeader", for: indexPath) as? SpotifyTrackCollectionViewCellHeader else { return UICollectionReusableView() }
        header.configureHeader(isFiltered: isFiltered(), nonFilteredName: viewModel.spotifyPlaylists.value[indexPath.section].name)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let datePicker = datePicker else { return }
        let tracks = viewModel.spotifyPlaylists.value[indexPath.section].tracks
        let track = isFiltered() ? filteredTracks[indexPath.row] : tracks[indexPath.row]
        navigationController?.popToRootViewController(animated: true)
        guard let alarm = viewModel.addAlarm(fromTrack: track, datePicker: datePicker) else { return }
        showAlarmAddedPopup(alarm)
    }
    
    private func showAlarmAddedPopup(_ alarm: SpotifyAlarm) {
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        let popup = PopupDialog(title: "You've added an alarm 🎉", message: alarm.trackName, image: alarm.image)
        popup.addButton(cancelButton)
        self.present(popup, animated: true, completion: nil)
    }
}
