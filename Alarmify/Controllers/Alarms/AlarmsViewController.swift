//
//  AlarmsViewController.swift
//  Alarmify
//
//  Created by David on 3/25/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import RxSwift

class AlarmsViewController: BasicViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = AlarmsViewModel()
    private var alarms: [SpotifyAlarm]?
    private var alarmDisposable: Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeToAlarms()
        viewModel.setAlarms()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeToAlarms()
    }

    private func initCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: alarm_view_collection_cell_id, bundle: nil), forCellWithReuseIdentifier: alarm_view_collection_cell_id)
        collectionView.backgroundView = BackgroundView(frame: view.frame)
    }
    
    private func subscribeToAlarms() {
        alarmDisposable = viewModel.alarmsObserver.subscribe {
            [weak self]
            event in
            switch (event) {
            case .next(let alarms):
                self?.alarms = alarms
                self?.collectionView.reloadData()
            case .error(let error):
                print("Failed to emit Alart Data \(error.localizedDescription)")
            case .completed:
                print("Emissions completed from Alarms Observer")
            }
        }
    }
    
    private func unsubscribeToAlarms() {
        alarmDisposable?.dispose()
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
        guard let alarms = alarms else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: alarm_view_collection_cell_id, for: indexPath) as! AlarmViewCollectionViewCell
        
        let alarm = alarms[indexPath.row]
        cell.dateLabel.text = viewModel.getFormattedStringFor(date: alarm.date, type: .date)
        cell.timeLabel.text = viewModel.getFormattedStringFor(date: alarm.date, type: .time)
        cell.trackLabel.text = alarm.trackName
        return cell
    }
}

// MARK: UICollectionViewDataSource
extension AlarmsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return alarms != nil ? alarms!.count : 0
    }
}
