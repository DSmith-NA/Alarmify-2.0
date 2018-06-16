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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(BackgroundView(frame: view.frame))
        setupLoginButton()
    }
    
    private func setupLoginButton() {
        let loginButton = SpotifyLoginButton(viewController: self, scopes: [.streaming, .userLibraryRead])
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
}
