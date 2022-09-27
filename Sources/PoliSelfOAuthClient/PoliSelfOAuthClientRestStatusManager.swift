
import Foundation
import UIKit

extension PoliSelfOAuthClientStatusManagerDelegate {
    func onRestStatusUpdate(appStatus: PoliSelfOAuthClient.AccountStatus) {}
}


class PoliSelfOAuthClientRestStatusManager {
    public static var isUrl: Bool = false
    private static var observers: [PoliSelfOAuthClientStatusManagerDelegate] = []
    private static var currentStatus: PoliSelfOAuthClient.AccountStatus = .UNLOGGED
    
    public static let shared: PoliSelfOAuthClientRestStatusManager = PoliSelfOAuthClientRestStatusManager()
    
    
    public static func registerForStatus(statusManagerDelegate: PoliSelfOAuthClientStatusManagerDelegate){
        self.observers.append(statusManagerDelegate)
        statusManagerDelegate.onRestStatusUpdate(appStatus: self.currentStatus)
    }
    
    public static func notifyStatusUpdate(status: PoliSelfOAuthClient.AccountStatus){
        self.currentStatus = status
        for o in self.observers {
            o.onRestStatusUpdate(appStatus: self.currentStatus)
        }
    }
    
    
    public func updateAppToken() {
        if (!PoliSelfOAuthClientSharedPreferencesManager.isRestUserLogged()) {return}
            if(!PoliSelfOAuthClientUtils.isTokenValid()){
                PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .TOKEN_NOT_VALID)
                guard let refreshToken = PoliSelfOAuthClientSharedPreferencesManager.getRestRefreshToken() else {PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED); return}
                PoliSelfRestService.refreshToken(using: refreshToken) { result, accessToken, refreshToken in
                    if !result {
                        DispatchQueue.main.async {
                            PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                        }
                        return
                    }
                    PoliSelfOAuthClientSharedPreferencesManager.setRestAccessToken(accessToken: accessToken)
                    if let refreshToken = refreshToken {
                        PoliSelfOAuthClientSharedPreferencesManager.setRestRefreshToken(refreshToken: refreshToken)
                    }
                    DispatchQueue.main.async {
                        PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
                    }
                }
            } else {
                PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
            }
    }
    
    public func loginIntoRestService() {
        PoliSelfOAuthClient.shared.reconstructPoliSession { result, cookies in
            if result {
                let oauthTask = URLSession.shared.dataTask(with: URLRequest(url: URL(string: PoliSelfOAuthClientConst.REST_AUTH_SERVER)!)) { data, response, error in
                    if let _ = error {
                        PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                        return
                    }
                    guard let data = data else {PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED); return}
                    guard let dataString = String(data: data, encoding: .utf8) else {PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED); return}
                    let aunica = AunicaloginTicketManager(htmlContent: dataString)
                    aunica.execute { result, url, htmlContent in
                        if !result {
                            PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                            return
                        }
                        guard let url = url else {PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED); return}
                        if url.absoluteString.starts(with: PoliSelfOAuthClientConst.REST_RETURN_URL) && url.absoluteString.contains("code=") {
                            guard let code = PoliSelfOAuthClientUtils.getQueryStringParameter(url: url.absoluteString, param: "code") else {PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED); return}
                            PoliSelfRestService.getAccessToken(using: code) { result, accessToken, refreshToken in
                                if result {
                                    PoliSelfOAuthClientSharedPreferencesManager.setRestAccessToken(accessToken: accessToken)
                                    if let refreshToken = refreshToken {
                                        PoliSelfOAuthClientSharedPreferencesManager.setRestRefreshToken(refreshToken: refreshToken)
                                    }
                                    DispatchQueue.main.async {
                                        PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .TOKEN_VALID)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                                    }
                                    return
                                }
                            }
                        } else {
                            PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                            return
                        }
                    }
                    
                }
                oauthTask.resume()
            } else {
                PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
                return
            }
        }
    }
    
    
}
