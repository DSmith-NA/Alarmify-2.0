//
//  AlarmsViewController.swift
//  Alarmify
//
//  Created by David on 3/25/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit

class AlarmsViewController: BasicViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var alarms: [SpotifyAlarm]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd"
        timeFormatter.dateFormat = "h:mm a"
        initCollectionView()
        setAlarmsArray()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setAlarmsArray()
        collectionView.reloadData()
    }

    private func initCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: alarm_view_collection_cell_id, bundle: nil), forCellWithReuseIdentifier: alarm_view_collection_cell_id)
        collectionView.backgroundView = LoginBackgroundView(frame: view.frame)
    }
    
    private func setAlarmsArray() {
        alarms = spotifyManager.spotifyAlarmList
        alarms = alarms!.filter {
            spotifyAlarm in
            spotifyAlarm.date.timeIntervalSinceNow.sign != .minus
        }
        alarms!.sort(by: {
            alarm1, alarm2 in
            alarm1.date.compare(alarm2.date) == .orderedAscending
        })
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension AlarmsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width, height: 80)
    }
}

// MARK: UICollectionViewDelegate
extension AlarmsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: alarm_view_collection_cell_id, for: indexPath) as! AlarmViewCollectionViewCell
        let alarm = alarms![indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: alarm.date)
        cell.timeLabel.text = timeFormatter.string(from: alarm.date)
        cell.trackLabel.text = alarm.trackName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

// MARK: UICollectionViewDataSource
extension AlarmsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alarms!.count
    }
}
