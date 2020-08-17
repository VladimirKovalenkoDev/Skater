//
//  LinkViewController.swift
//  Skater
//
//  Created by Владимир Коваленко on 17.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import WebKit

class LinkViewController: UIViewController, WKUIDelegate  {
    
   var backButton: UIBarButtonItem?
   var webView: WKWebView!
    
  
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://www.facebook.com/liza.prokudina.7")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
 
}
