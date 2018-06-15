//
//  LoginBackgroundView.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit

class LoginBackgroundView: UIView {
    private var image: Data?
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage()
        setAsView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImage()
        setAsView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setImage() {
        spinner.startAnimating()
        let filePath = Bundle.main.path(forResource: "stars", ofType: "gif")
        image = filePath != nil ? try? NSData(contentsOfFile: filePath!) as Data : nil
    }
    
    private func setSpinner() {
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.center = center
        addSubview(spinner)
    }

    private func setAsView() {
        guard let image = image else { return }
        let webView = UIWebView(frame: self.frame)
        webView.load(image, mimeType: "image/gif", textEncodingName: String(), baseURL: NSURL() as URL)
        webView.isUserInteractionEnabled = false
        webView.frame = self.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.delegate = self
        addSubview(webView)
    }
}

extension LoginBackgroundView: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
    }
}
