//
//  SpotifyTrackCollectionViewCell.swift
//  Alarmify
//
//  Created by David on 3/4/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit

class SpotifyTrackCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistsLabel: UILabel!
    @IBOutlet weak var albumArtwork: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
