//
//  File.swift
//  
//
//  Created by Matteo Visotto on 22/09/22.
//

import Foundation
import UIKit
import WebKit

class PoliSelfOAuthLoginViewController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = WKWebView()
    private var loader = Loader()
    private let navigationBar = UINavigationBar()
    private var inNavigationController: Bool!
    
    var onCompletion: (_ result: Bool) -> () = {_ in}
    
    convenience init(inNavigationController: Bool = false) {
        self.init()
        self.inNavigationController = inNavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!self.inNavigationController){
            addNavigationBar()
        }
        addWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request = URLRequest(url: URL(string: PoliSelfOAuthClientConst.AUTH_SERVER)!)
        webView.load(request)
        webView.navigationDelegate = self
    }
    
    
    private func addNavigationBar() -> Void {
        /*if #available(iOS 13.0, *) {
            navigationBar.barTintColor = UIColor.systemBackground
        } else {
            
        }*/
        self.view.addSubview(navigationBar)
        self.navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        navigationBar.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC))

        let navigationItem = UINavigationItem(title: NSLocalizedString("PoliMi Login", comment: ""))
        navigationItem.leftBarButtonItem = cancelButton
        navigationBar.items = [navigationItem]
    }
    
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
        self.onCompletion(false)
    }
    
    private func addWebView() -> Void {
        self.view.addSubview(self.webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        if(!self.inNavigationController){
            webView.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor).isActive = true
        } else {
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let currentUrl = webView.url?.absoluteString else {return}
        if(currentUrl.starts(with: PoliSelfOAuthClientConst.AUTH_TOKEN_WEB)){
            DispatchQueue.main.async {
                self.loader = CircleLoader.createGeometricLoader()
                self.loader.startAnimation()
            }
            webView.evaluateJavaScript("document.getElementsByTagName('input')[0].value",
                                       completionHandler: { (content: Any?, error: Error?) in
                if let auth_token = content as? String {
                    let statusManager = PoliSelfOAuthClientStatusManager()
                    statusManager.getAccessToken(usingAuthToken: auth_token)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        self.onCompletion(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Unable to get your access token, please retry", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                            self.onCompletion(false)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
}
