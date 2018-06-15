//
//  Timers.swift
//  Alarmify
//
//  Created by David on 6/7/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import RxSwift

let fetchPlaylistTimer = Observable<Int64>.timer(RxTimeInterval(0), period: RxTimeInterval(300), scheduler: MainScheduler.instance)
let snoozeTimer = Observable<Int64>.timer(RxTimeInterval(300), period: RxTimeInterval(300), scheduler: MainScheduler.instance)
let vibrateTimer = Observable<Int64>.timer(RxTimeInterval(0), period: RxTimeInterval(1), scheduler: MainScheduler.instance)
let clockTimer = Observable<Int64>.timer(RxTimeInterval(0), period: RxTimeInterval(4), scheduler: MainScheduler.instance)
