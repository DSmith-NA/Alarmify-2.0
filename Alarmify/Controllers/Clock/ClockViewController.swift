//
//  ClockViewController.swift
//  Alarmify
//
//  Created by David on 3/4/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import TransitionButton

class ClockViewController: BasicViewController {
    private let alarmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateAlarmViewController")
    private let disposeBag = DisposeBag()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func createAlarmTapped(_ button: TransitionButton) {
        button.startAnimation()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            sleep(1)
            DispatchQueue.main.async(execute: { () -> Void in
                button.stopAnimation(animationStyle: .normal, completion: {
                    self.navigationController?.pushViewController(self.alarmVC, animated: true)
                })
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToClock()
    }
    
    private func subscribeToClock() {
        clockTimer.bind{ [weak self] _ in
            self?.timeLabel.text = self?.timeFormatter.string(from: Date())
        }.disposed(by: disposeBag)
    }
}
