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
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
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
        let filePath = Bundle.main.path(forResource: "stars", ofType: "gif")
        image = filePath != nil ? try? NSData(contentsOfFile: filePath!) as Data : nil
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
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        spinner.isHidden = false
        spinner.center = webView.center
        webView.addSubview(spinner)
        webView.bringSubview(toFront: spinner)
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        spinner.stopAnimating()
    }
}
