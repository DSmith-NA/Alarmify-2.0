//
//  CreateAlarmViewController.swift
//  Alarmify
//
//  Created by David on 3/25/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import TransitionButton

class CreateAlarmViewController: BasicViewController {
    
    private let tracksVC: SpotifyTracksViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpotifyTracksViewController") as? SpotifyTracksViewController
    
    @IBOutlet weak var setATimeLabel: UILabel!
    @IBOutlet weak var timeSelector: UIDatePicker!
    @IBOutlet weak var chooseMusicButton: TransitionButton!
    @IBOutlet weak var cancelButton: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeSelector.setValue(UIColor.white, forKey: "textColor")
        timeSelector.minimumDate = Date()
        chooseMusicButton.addTarget(self, action: #selector(chooseMusic), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
    }
    
    @objc private func chooseMusic() {
        guard let tracksVC = tracksVC else { return }
        tracksVC.datePicker = timeSelector
        self.navigationController?.pushViewController(tracksVC, animated: true)
    }
    
    @objc private func dismissView() {
        navigationController?.popViewController(animated: true)
    }
}
