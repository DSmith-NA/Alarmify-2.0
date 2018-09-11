//
//  AppDelegate.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import SpotifyLogin
import Spartan
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {

    var window: UIWindow?
    let spotifyPlayer = SPTAudioStreamingController.sharedInstance()
    let spotifyLogin = SpotifyLogin.shared
    let spotifyManager = SpotifyManager.instance
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        customizePopupViewForDarkMode()
        spotifyLogin.configure(clientID: client_id, clientSecret: client_secret, redirectURL: URL(string: redirect_url)!)
        spotifyPlayer?.delegate = self
        spotifyPlayer?.playbackDelegate = self
        try? spotifyPlayer?.start(withClientId: client_id)
        getAccessTokenIfAvailable()
        let alarmData = UserDefaults.standard.object(forKey: alarm_key) as? NSData
        guard let finalAlarmData = alarmData,
            let spotifyAlarms = NSKeyedUnarchiver.unarchiveObject(with: finalAlarmData as Data) as? [SpotifyAlarm] else {
                spotifyManager.spotifyAlarmList = [SpotifyAlarm]()
                return true
        }
        spotifyManager.spotifyAlarmList = spotifyAlarms
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = spotifyLogin.applicationOpenURL(url) { (error) in
            if error != nil {
                let errorAlert = UIAlertController(title: "Login Unsuccessful", message: "Failed to Login to Spotify", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "😢", style: .default, handler: nil))
                self.window?.rootViewController?.presentedViewController?.present(errorAlert, animated: true, completion: nil)
                return
            }
            self.getAccessTokenIfAvailable()
        }
        return handled
    }
    
    private func getAccessTokenIfAvailable() {
        spotifyLogin.getAccessToken(completion: { (accessToken, error) in
            if error != nil {
                self.window?.rootViewController = LoginViewController()
                return
            }
            Spartan.authorizationToken = accessToken
            self.spotifyPlayer?.login(withAccessToken: accessToken)
            self.switchToTabBarController()
        })
    }
    
    private func switchToTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - SPTAudioStreamingPlaybackDelegate
extension AppDelegate: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        let avAudioSession = AVAudioSession.sharedInstance()
        try! avAudioSession.setCategory(AVAudioSessionCategoryPlayback)
        try! avAudioSession.setActive(isPlaying)
    }
}
