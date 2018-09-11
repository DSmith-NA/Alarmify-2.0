//
//  LoginViewController.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import SpotifyLogin

class LoginViewController: BasicViewController {
    
    private lazy var spotifyLoginButton: SpotifyLoginButton = { [unowned self] _ in
        let button = SpotifyLoginButton(viewController: self, scopes: [.streaming, .userLibraryRead])
        button.center = self.view.center
        return button
    }(self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(BackgroundView(frame: view.frame))
        view.addSubview(spotifyLoginButton)
    }
}
