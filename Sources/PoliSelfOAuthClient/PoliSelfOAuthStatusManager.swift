//
//  File.swift
//  
//
//  Created by Matteo Visotto on 20/09/22.
//

import Foundation
import UIKit

public protocol PoliSelfOAuthClientStatusManagerDelegate {
    func onStatusUpdate(appStatus: PoliSelfOAuthClient.AccountStatus)
}


class PoliSelfOAuthClientStatusManager {
    public static var isUrl: Bool = false
    public static var pin: String = ""
    private static var observers: [PoliSelfOAuthClientStatusManagerDelegate] = []
    private static var currentStatus: PoliSelfOAuthClient.AccountStatus = .UNLOGGED
    
    public static func registerForStatus(statusManagerDelegate: PoliSelfOAuthClientStatusManagerDelegate){
        self.observers.append(statusManagerDelegate)
        statusManagerDelegate.onStatusUpdate(appStatus: self.currentStatus)
    }
    
    public static func notifyStatusUpdate(status: PoliSelfOAuthClient.AccountStatus){
        self.currentStatus = status
        for o in self.observers {
            o.onStatusUpdate(appStatus: self.currentStatus)
        }
    }
    
    
    public func updateAppToken() {
        if (!PoliSelfOAuthClientSharedPreferencesManager.isUserLogged()) {return}
            if(!PoliSelfOAuthClientUtils.isTokenValid()){
                PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .TOKEN_NOT_VALID)
                if let refreshToken = PoliSelfOAuthClientSharedPreferencesManager.getRefreshToken(){
                    let parameters: [String:Any] = [
                        "grant_type" : "refresh_token",
                        "refresh_token" : refreshToken,
                        "client_id" : PoliSelfOAuthClientConst.CLIENT_ID,
                        "client_secret" : PoliSelfOAuthClientConst.CLIENT_SECRET,
                        "redirect_uri" : PoliSelfOAuthClientConst.REDIRECT_URI
                    ]
                    let task = PoliSelfOAuthClientTaskManager(url: URL(string: PoliSelfOAuthClientConst.TOKEN_SERVER)!, parameters: parameters)
                    task.delegate = self
                    task.execute()
                }
            } else {
                PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
            }
    }
    
    public func getAccessToken(usingAuthToken authToken: String){
        let parameters: [String: Any] = [
            "grant_type" : "authorization_code",
            "code" : authToken,
            "client_id" : PoliSelfOAuthClientConst.CLIENT_ID,
            "client_secret" : PoliSelfOAuthClientConst.CLIENT_SECRET,
            "redirect_uri" : PoliSelfOAuthClientConst.REDIRECT_URI
        ]
        let task = PoliSelfOAuthClientTaskManager(url: URL(string: PoliSelfOAuthClientConst.TOKEN_SERVER)!, parameters: parameters)
        task.delegate = self
        task.execute()
    }
    
}

extension PoliSelfOAuthClientStatusManager: PoliSelfOAuthClientTaskManagerDelegate {
    func taskManager(taskManager: PoliSelfOAuthClientTaskManager, didFinishWith result: Bool, stringContent: String) {
        if result{
            if let data = stringContent.data(using: .utf8) {
                do {
                    let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    if let json = response {
                        if let aToken = json["access_token"] as? String {
                            PoliSelfOAuthClientSharedPreferencesManager.setAccessToken(accessToken: aToken)
                            PoliSelfOAuthClientSharedPreferencesManager.setTokenExpire(expireAt: PoliSelfOAuthClientUtils.getNow23h())
                        } else {
                            PoliSelfOAuthClientSharedPreferencesManager.deletePreferences()
                            PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                            return
                        }
                        if let rToken = json["refresh_token"] as? String {
                            PoliSelfOAuthClientSharedPreferencesManager.setRefreshToken(refreshToken: rToken)
                        }
                        DispatchQueue.main.async {
                            PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
                        }
                    }
                } catch {
                    PoliSelfOAuthClientSharedPreferencesManager.deletePreferences()
                    PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                }
            }
        } else {
            DispatchQueue.main.async {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            if var topController = keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let alert = UIAlertController(title: "Error", message: stringContent, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                    topController.present(alert, animated: true, completion: {
                        PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                    })
                }
            }
        }
    }
}
