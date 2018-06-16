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
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var webViewDisposable: Disposable?
    private(set) var viewModel = BackgroundViewModel() // TODO: Inject this value somehow
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setWebView(UIWebView(frame: self.frame))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setWebView(UIWebView(frame: self.frame))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setWebView(_ webView: UIWebView) {
        guard let image = viewModel.image else { return }
        subscribeToWebViewLoader()
        webView.delegate = viewModel
        webView.load(image, mimeType: mimeType, textEncodingName: String(), baseURL: NSURL() as URL)
        webView.isUserInteractionEnabled = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(webView)
    }
    
    private func setSpinner(_ webView: UIWebView?, stopSpinner: Bool) {
        guard let webView = webView, !stopSpinner else { spinner.stopAnimating(); return }
        spinner.isHidden = false
        spinner.center = webView.center
        spinner.hidesWhenStopped = true
        webView.addSubview(spinner)
        webView.bringSubview(toFront: spinner)
        spinner.startAnimating()
    }
    
    private func subscribeToWebViewLoader() {
        webViewDisposable = viewModel.webViewLoad.subscribe {
            [weak self]
            event in
            switch (event) {
            case .next(let type):
                switch (type) {
                case .started(let webView):
                    self?.setSpinner(webView, stopSpinner: false)
                case .finished(let webView):
                    self?.setSpinner(webView, stopSpinner: true)
                }
            case .error(let error):
                print("Failed to emit WebViewType event \(error.localizedDescription)")
            case .completed:
                print("WebView finished emitting events")
            }
        }
    }
}
