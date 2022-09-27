//
//  PoliSelfRestService.swift
//  
//
//  Created by Matteo Visotto on 27/09/22.
//

import Foundation

class PoliSelfRestService {
    
    public static func getAccessToken(using code: String, completionHandler: @escaping (_ result: Bool, _ accessToken: String, _ refreshToken: String?)->()) -> Void {
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: PoliSelfOAuthClientConst.REST_CODE_SERVER+code)!)) { data, response, error in
            self.parseResponse(data: data, response: response, error: error, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    public static func refreshToken(using code: String, completionHandler: @escaping (_ result: Bool, _ accessToken: String, _ refreshToken: String?)->()) -> Void {
        let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: PoliSelfOAuthClientConst.REST_REFRESH_SERVER+code)!)) { data, response, error in
            self.parseResponse(data: data, response: response, error: error, completionHandler: completionHandler)
        }
        task.resume()
    }
    
    private static func parseResponse(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (_ result: Bool, _ accessToken: String, _ refreshToken: String?)->()){
        if let _ = error {
            completionHandler(false, "", nil)
            return
        }
        guard let data = data else { completionHandler(false, "", nil); return}
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                var aT = ""
                var rT: String? = nil
                if let json = response {
                    if let aToken = json["accessToken"] as? String {
                        aT = aToken
                    } else {
                        completionHandler(false, "", nil)
                        return
                    }
                    if let rToken = json["refreshToken"] as? String {
                        rT = rToken
                    }
                    completionHandler(true, aT, rT)
                    return
                }
            } catch {
                completionHandler(false, "", nil)
                return
            }
    }
    
    private var restUrl: String!
    private var aToken: String!
    
    init(restEndpoint: String, accessToken: String) {
        self.restUrl = restEndpoint
        self.aToken = accessToken
    }
    
    func getJson(completionHandler: @escaping (_ result: Bool, _ jsonString: String?) -> ()) -> Void {
        var request = URLRequest(url: URL(string: self.restUrl)!)
        request.setValue( "Bearer " + self.aToken, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completionHandler(false, nil)
                return
            }
            guard let data = data else {completionHandler(false, nil); return}
            guard let s = String(data: data, encoding: .utf8) else {completionHandler(false, nil); return}
            completionHandler(true, s)
        }
        task.resume()
    }
}
