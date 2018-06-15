//
//  ClockViewController.swift
//  Alarmify
//
//  Created by David on 3/4/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import RxSwift
import TransitionButton

class ClockViewController: BasicViewController {
    private let alarmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateAlarmViewController")
    private let timeFormatter = DateFormatter()
    private var clockSubscriber: Disposable?
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func createAlarmTapped(_ button: TransitionButton) {
        button.startAnimation()
        spotifyManager.fetchPlaylists()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            sleep(1)
            DispatchQueue.main.async(execute: { () -> Void in
                button.stopAnimation(animationStyle: .normal, completion: {
                    self.navigationController?.pushViewController(self.alarmVC, animated: true)
                })
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToClock()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToClock()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeSubscriber()
        super.viewDidDisappear(animated)
    }
    
    private func subscribeToClock() {
        clockSubscriber = clockTimer.subscribe {
            [weak self]
            _ in
            self?.timeLabel.text = self?.timeFormatter.string(from: Date())
        }
    }
    
    private func disposeSubscriber() {
        clockSubscriber?.dispose()
        clockSubscriber = nil
    }
}
