import Foundation
import UIKit

public class PoliSelfOAuthClient {
    
    public enum AccountStatus: String {
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
        let webLogin = PoliSelfOAuthLoginViewController(inNavigationController: false)
        webLogin.onCompletion = completionHandler
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(webLogin, animated: true, completion: nil)
        }
        completionHandler(false)
    }
    
    public func getServicePage(service: PoliSelfService.Service, completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlString: String?)->()) {
        if(self.currentStatus == .TOKEN_VALID){
            guard let accessToken = self.accessToken else {completionHandler(false, nil, nil); return}
            let poliService = PoliSelfService(service: service, accessToken: accessToken)
            poliService.getServicePage(completionHandler: completionHandler)
        } else {
            completionHandler(false, nil, nil)
        }
    }
    
    public func initialize() -> Void {
        self.statusManager.updateAppToken()
    }
    
}

extension PoliSelfOAuthClient: PoliSelfOAuthClientStatusManagerDelegate {
    func onStatusUpdate(appStatus: AccountStatus) {
        self.currentStatus = appStatus
    }
}

