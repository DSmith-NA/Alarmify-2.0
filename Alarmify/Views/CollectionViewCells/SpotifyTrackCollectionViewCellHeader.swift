//
//  SpotifyTrackCollectionViewCellHeader.swift
//  Alarmify
//
//  Created by David on 6/2/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit

class SpotifyTrackCollectionViewCellHeader: UICollectionReusableView {
    @IBOutlet weak var playlistTitle: UILabel!
    
    func configureHeader(isFiltered: Bool, nonFilteredName name: String) {
        playlistTitle.text = isFiltered ? "Search" : name
        playlistTitle.font = UIFont(name: sf_pro_semibold, size: 17)!
    }
}
