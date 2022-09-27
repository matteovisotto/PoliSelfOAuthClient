import Foundation
import UIKit

public class PoliSelfOAuthClient {
    
    public enum AccountStatus: String {
        case UNLOGGED = "Non autenticato"
        case TOKEN_VALID = "Token valido"
        case TOKEN_NOT_VALID = "Token scaduto"
    }
    
    public static let shared: PoliSelfOAuthClient = PoliSelfOAuthClient()
    
    private var isRestEnabled: Bool = false
    
    private var currentStatus: PoliSelfOAuthClient.AccountStatus = .UNLOGGED
    private var currentRestStatus: PoliSelfOAuthClient.AccountStatus = .UNLOGGED
    
    private var statusManager: PoliSelfOAuthClientStatusManager = PoliSelfOAuthClientStatusManager.shared
    private var restStatusManager: PoliSelfOAuthClientRestStatusManager = PoliSelfOAuthClientRestStatusManager.shared
    
    public var accessToken: String? {
        get {
            return PoliSelfOAuthClientSharedPreferencesManager.getAccessToken()
        }
    }
    
    public var restAccessToken: String? {
        get {
            return PoliSelfOAuthClientSharedPreferencesManager.getRestAccessToken()
        }
    }
    
    public var isUserLogged: Bool {
        get {
            return self.currentStatus == .TOKEN_VALID
        }
    }
    
    public var isRestUserLogged: Bool {
        get {
            return self.currentRestStatus == .TOKEN_VALID
        }
    }
    
    init(){
        PoliSelfOAuthClientStatusManager.registerForStatus(statusManagerDelegate: self)
        if(isRestEnabled){
            PoliSelfOAuthClientRestStatusManager.registerForStatus(statusManagerDelegate: self)
        }
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
        //completionHandler(false)
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
    
    public func getRestService(restEndpointUrl: String, completionHandler: @escaping (_ result: Bool, _ jsonString: String?) -> () ) -> Void {
        if(self.currentRestStatus == .TOKEN_VALID){
            guard let accessToken = self.restAccessToken else {completionHandler(false, "No access token"); return}
            let restService = PoliSelfRestService(restEndpoint: restEndpointUrl, accessToken: accessToken)
            restService.getJson(completionHandler: completionHandler)
        } else {
            completionHandler(false, "no token valid")
        }
    }
    
    public func initialize(useRestService: Bool = false) -> Void {
        self.isRestEnabled = useRestService
        self.statusManager.updateAppToken()
        if useRestService {
            self.restStatusManager.updateAppToken()
        }
    }
    
    public func registerForStatusUpdate(_ observer: PoliSelfOAuthClientStatusManagerDelegate) -> Void {
        PoliSelfOAuthClientStatusManager.registerForStatus(statusManagerDelegate: observer)
        if self.isRestEnabled{
            PoliSelfOAuthClientRestStatusManager.registerForStatus(statusManagerDelegate: observer)
        }
    }
    
    
    
    public func logout() -> Void {
        PoliSelfOAuthClientSharedPreferencesManager.deletePreferences()
        PoliSelfOAuthClientStatusManager.notifyStatusUpdate(status: .UNLOGGED)
        PoliSelfOAuthClientRestStatusManager.notifyStatusUpdate(status: .UNLOGGED)
    }
    
    public func getPoliCookies() -> [HTTPCookie]? {
        if !statusManager.isSessionReconstructed {
            return nil
        }
        let cookies = HTTPCookieStorage.shared.cookies ?? []
        return cookies
    }
    
    public func reconstructPoliSession(completionHandler: @escaping (_ result: Bool, _ cookies: [HTTPCookie]?)->()) -> Void {
        if(self.currentStatus == .TOKEN_VALID){
            guard let accessToken = self.accessToken else {completionHandler(false, nil); return}
            let poliSelf = PoliSelfService(service: .carriera, accessToken: accessToken)
            poliSelf.reconstructSession { result in
                if result {
                    completionHandler(true, self.getPoliCookies())
                } else {
                    completionHandler(false, nil)
                }
            }
        }
    }
    
    
}

extension PoliSelfOAuthClient: PoliSelfOAuthClientStatusManagerDelegate {
    public func onStatusUpdate(appStatus: AccountStatus) {
        self.currentStatus = appStatus
        if appStatus == .TOKEN_VALID && self.isRestEnabled && !PoliSelfOAuthClientSharedPreferencesManager.isRestUserLogged(){
            self.restStatusManager.loginIntoRestService()
        }
    }
    
    public func onRestStatusUpdate(appStatus: AccountStatus) {
        self.currentRestStatus = appStatus
    }
}

