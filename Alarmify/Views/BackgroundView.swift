//
//  LoginBackgroundView.swift
//  Alarmify
//
//  Created by David on 3/3/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import UIKit
import RxSwift

private let mimeType = "image/gif"

class BackgroundView: UIView {
    private(set) var viewModel = BackgroundViewModel()
    private let disposeBag = DisposeBag()
    
    private lazy var webView: UIWebView = { [weak self] _ in
        let webView = UIWebView(frame: (self?.frame ?? CGRect.zero))
        webView.delegate = self?.viewModel
        webView.isUserInteractionEnabled = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        if let image = self?.viewModel.image {
            webView.load(image, mimeType: "image/gif", textEncodingName: String(), baseURL: NSURL() as URL)
        }
        return webView
    }(self)
    
    private lazy var spinner: UIActivityIndicatorView = { [weak self] _ in
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = self?.webView.center ?? CGPoint.zero
        spinner.hidesWhenStopped = true
        return spinner
    }(self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        subscribeToWebViewLoader()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubviews()
        subscribeToWebViewLoader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addSubviews() {
        addSubview(webView)
        webView.addSubview(spinner)
        webView.bringSubview(toFront: spinner)
    }
    
    private func showSpinner(_ shouldShow: Bool) {
        if shouldShow {
           spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
        spinner.isHidden = !shouldShow
    }
    
    private func subscribeToWebViewLoader() {
        viewModel.webViewLoad.bind{ [weak self] event in
            switch event {
            case .started:
                self?.showSpinner(true)
            case .finished:
                self?.showSpinner(false)
            }
        }.disposed(by: disposeBag)
    }
}
