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
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToAlarms()
        viewModel.fetchAlarms()
    }

    private func initCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: alarm_view_collection_cell_id, bundle: nil), forCellWithReuseIdentifier: alarm_view_collection_cell_id)
        collectionView.backgroundView = BackgroundView(frame: view.frame)
    }
    
    private func subscribeToAlarms() {
        viewModel.alarms.bind{ [weak self] _ in
            self?.collectionView.reloadData()
        }.disposed(by: disposeBag)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: alarm_view_collection_cell_id, for: indexPath) as? AlarmViewCollectionViewCell
            else { return UICollectionViewCell() }
        let alarm = viewModel._alarms.value[indexPath.row]
        cell.configureCell(withAlarm: alarm)
        return cell
    }
}

// MARK: UICollectionViewDataSource
extension AlarmsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel._alarms.value.count
    }
}
