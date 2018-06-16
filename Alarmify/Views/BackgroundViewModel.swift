//
//  BackgroundViewModel.swift
//  Alarmify
//
//  Created by David Smith on 6/16/18.
//  Copyright © 2018 DSmith. All rights reserved.
//

import Foundation
import RxSwift

private let stars = ("stars", "gif")

enum WebViewType<UIWebView> {
    case started(UIWebView)
    case finished(UIWebView)
}

class BackgroundViewModel: NSObject {
    var image: Data? {
        let filePath = Bundle.main.path(forResource:stars.0, ofType: stars.1)
        return filePath != nil ? try? NSData(contentsOfFile: filePath!) as Data : nil
    }
    
    let webViewLoad = PublishSubject<WebViewType<UIWebView>>()
}

// MARK: UIWebViewDelegate
extension BackgroundViewModel: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        webViewLoad.onNext(.started(webView))
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webViewLoad.onNext(.finished(webView))
    }
}
