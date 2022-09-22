import Foundation
import UIKit

class PoliSelfOAuthClient {
    
    enum AccountStatus: String {
        case UNLOGGED = "Non autenticato"
        case TOKEN_VALID = "Token valido"
        case TOKEN_NOT_VALID = "Token scaduto"
    }
    
    public static let shared: PoliSelfOAuthClient = PoliSelfOAuthClient()
    
    private var currentStatus: PoliSelfOAuthClient.AccountStatus = .UNLOGGED
    
    private var statusManager: PoliSelfOAuthClientStatusManager = PoliSelfOAuthClientStatusManager()
    
    var accessToken: String? {
        get {
            return PoliSelfOAuthClientSharedPreferencesManager.getAccessToken()
        }
    }
    
    init(){
        PoliSelfOAuthClientStatusManager.registerForStatus(statusManagerDelegate: self)
    }
    
    public func poliSelfLogin(completionHandler: @escaping (_ result: Bool)->()) -> Void {
        
    }
    
}

extension PoliSelfOAuthClient: PoliSelfOAuthClientStatusManagerDelegate {
    func onStatusUpdate(appStatus: AccountStatus) {
        self.currentStatus = appStatus
    }
}

