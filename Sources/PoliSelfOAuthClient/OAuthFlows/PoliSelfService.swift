//
//  PoliSelfService.swift
//  poliOrarioTest
//
//  Created by Matteo Visotto on 19/09/22.
//

import Foundation

public class PoliSelfService {
    
    public enum Service: String {
        case webeep = "2270"
        case recman = "2314"
        case carriera = "2161"
        case rubrica = "1252"
        case tasse = "1478"
        case orarioLezioni = "398"
        case esitiEsami = "661"
        case iscrizioneEsami = "1918"
    }
    
    static func getResponseType(from stringURL: String) -> PoliServiceOAuthLogin.AuthResponse {
        if(stringURL.starts(with: "https://shibidp.polimi.it")){
            return .shibboleth
        } else if (stringURL.starts(with: "https://aunicalogin.polimi.it") && !stringURL.starts(with: "https://aunicalogin.polimi.it/aunicalogin/aunicalogin/controller/logout/SessioneTerminata.do")) {
            return .aunicalogin
        } else if (stringURL.starts(with: "https://aunicalogin.polimi.it/aunicalogin/aunicalogin/controller/logout/SessioneTerminata.do?jaf_currentWFID=main&EVN_DEFAULT=evento")){
            return .aunicaloginSession
        }
        return .unknown
    }
    
    static func selectAuthStep(url: URL, htmlContent: String, completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlString: String?)->()) {
        switch getResponseType(from: url.absoluteString) {
            case .aunicalogin:
                let aunicaManager = AunicaloginTicketManager(htmlContent: htmlContent)
                aunicaManager.execute { result, url, htmlContent in
                    if result {
                        if let u = url, let html = htmlContent {
                            self.selectAuthStep(url: u, htmlContent: html, completionHandler: completionHandler)
                            return
                        }
                    }
                    completionHandler(false, nil, nil)
                }
                break
            case .shibboleth:
                let shibManager = ShibbolethResponseManager(htmlContent: htmlContent)
                shibManager.execute { result, url, htmlContent in
                    if result {
                        if let u = url, let html = htmlContent {
                            self.selectAuthStep(url: u, htmlContent: html, completionHandler: completionHandler)
                            return
                        }
                    }
                    completionHandler(false, nil, nil)
                }
                break
                case .aunicaloginSession:
                let aunicaSession = AunicaloginSessionManager(htmlContent: htmlContent)
                aunicaSession.execute { result, url, htmlContent in
                    if result {
                        if let u = url, let html = htmlContent {
                            self.selectAuthStep(url: u, htmlContent: html, completionHandler: completionHandler)
                            return
                        }
                    }
                    completionHandler(false, nil, nil)
                }
                break
            default:
                completionHandler(true, url, htmlContent)
                break
        }
        
    }
    
    private let POLISELF_SERVICE_BASE_URL = "https://servizionline.polimi.it/portaleservizi/portaleservizi/controller/servizi/Servizi.do?evn_srv=evento&idServizio="
    
    private var service: PoliSelfService.Service!
    private var accessToken: String!
    
    init(service: PoliSelfService.Service, accessToken: String) {
        self.service = service
        self.accessToken = accessToken
    }
    
    public func getServicePage(completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlString: String?) -> ()) -> Void {
        if self.service == .webeep || self.service == .orarioLezioni {
            let poliOAuth = PoliServiceOAuthLogin(serviceId: self.service.rawValue, accessToken: self.accessToken)
            poliOAuth.executeFlow(completionHandler: completionHandler)
        } else {
            if (PoliSelfOAuthClientStatusManager.shared.isSessionReconstructed) {
                self.serviceTask(completionHandler: completionHandler)
            } else {
                reconstructSession { result in
                    if result {
                        self.serviceTask(completionHandler: completionHandler)
                    } else {
                        completionHandler(false, nil, nil)
                    }
                }
            }
        }
    }
    
    public func reconstructSession(completionHandler: @escaping (_ result: Bool)->()) -> Void {
        let webeep = PoliServiceOAuthLogin(serviceId: PoliSelfService.Service.webeep.rawValue, accessToken: self.accessToken)
        webeep.executeFlow { result, url, htmlString in
            if(result){
                if let u = url {
                    if u.absoluteString.starts(with: "https://webeep.polimi.it"){
                        self.getPoliService(completionHandler: completionHandler)
                        return
                    }
                }
            }
            completionHandler(false)
        }
    }
    
    private func getPoliService(completionHandler: @escaping (_ result: Bool) -> ()) {
            let urlString = "https://servizionline.polimi.it/portaleservizi/"
            let poliSelfTask = URLSession.shared.dataTask(with: URLRequest(url: URL(string: urlString)!)) { data, response, error in
                if let _ = error {
                    completionHandler(false)
                    return
                }
                
                if let d = data {
                    if let string = String(data: d, encoding: .utf8) {
                        if let url = (response as! HTTPURLResponse).url {
                            PoliSelfService.selectAuthStep(url: url, htmlContent: string) { result, url, htmString in
                                if result {
                                    if let u = url {
                                        if u.absoluteString.starts(with: "https://servizionline.polimi.it/portaleservizi/portaleservizi/controller/Portale.do?jaf_currentWFID=main&EVN_SHOW_PORTALE=evento") {
                                            PoliSelfOAuthClientStatusManager.shared.updateLastSession()
                                            completionHandler(true)
                                            return
                                        }
                                    }
                                }
                                completionHandler(false)
                            }
                            return
                        }
                    }
                }
                completionHandler(false)
                return
            }
            poliSelfTask.resume()
    }
    
    private func serviceTask(completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlString: String?) -> ()) {
        let urlString = self.POLISELF_SERVICE_BASE_URL + self.service.rawValue
        let poliServizioTask = URLSession.shared.dataTask(with: URLRequest(url: URL(string: urlString)!)) { data, response, error in
            if let _ = error {
                completionHandler(false, nil, nil)
                return
            }
            
            if let d = data {
                if let string = String(data: d, encoding: .utf8) {
                    if let url = (response as! HTTPURLResponse).url {
                        PoliSelfService.selectAuthStep(url: url, htmlContent: string, completionHandler: completionHandler)
                        return
                    }
                }
            }
            completionHandler(false, nil, nil)
            return
        }
        poliServizioTask.resume()
        return
    }
    
}
