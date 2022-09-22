//
//  PoliServiceOAuthLogin.swift
//  poliOrarioTest
//
//  Created by Matteo Visotto on 19/09/22.
//

import Foundation


class PoliServiceOAuthLogin {
    
    enum AuthResponse: String {
        case aunicalogin = "Aunicalogin"
        case shibboleth = "Shibboleth IdP"
        case aunicaloginSession = "Aunicalogin Session"
        case unknown = "Unknown"
    }
    
    private var OAUTH_BASE_URL = "https://aunicalogin.polimi.it/aunicalogin/getservizioOAuth.xml"
    
    private var serviceId: String!
    private var accessToken: String!
    
    private var session: URLSession = URLSession.shared
    private var request: URLRequest!
    
    init(serviceId: String, accessToken: String) {
        self.serviceId = serviceId
        self.accessToken = accessToken
        prepareRequest()
    }
    
    private func prepareRequest() -> Void {
        let urlString = OAUTH_BASE_URL + "?id_servizio=" + self.serviceId + "&lang=it&access_token=" + self.accessToken
        self.request = URLRequest(url: URL(string: urlString)!)
    }
    
    func executeFlow(completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlString: String?)->()) -> Void {
        let oauthTask = self.session.dataTask(with: self.request) { data, response, error in
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
        oauthTask.resume()
    }
    
}
