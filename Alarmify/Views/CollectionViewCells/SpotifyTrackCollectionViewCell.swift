//
//  SpotifyTrackCollectionViewCell.swift
//  Alarmify
//
//  Created by David on 3/4/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import Spartan

class SpotifyTrackCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    @IBOutlet weak var albumArtwork: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(withTrack track: PlaylistTrack) {
        trackLabel.text = track.track.name
        var artistLabel = ""
        track.track.artists.filter{ artist in
            artist != track.track.artists.last
        }.forEach{ artist in
            artistLabel += artist.name + ", "
        }
        artistLabel += track.track.artists.last!.name
        artistsLabel.text = artistLabel
        guard let albumUrl = track.track.album.images[0].url else { return }
        albumArtwork.sd_setImage(with: URL(string: albumUrl), completed: nil)
    }
}
