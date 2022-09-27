//
//  AunicaloginSessionManager.swift
//  poliOrarioTest
//
//  Created by Matteo Visotto on 19/09/22.
//

import Foundation
import SwiftSoup

class AunicaloginSessionManager {
    private var content: String!
    
    private var session: URLSession = URLSession.shared
    
    private var request: URLRequest!
    
    init(htmlContent: String) {
        self.content = htmlContent
        prepareRequest()
    }
    
    private func prepareRequest() {
        let p = parsePage(self.content)
        self.request = URLRequest(url: URL(string: p)!)
        request.httpMethod = "GET"
    }
    
    public func execute(_ completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlContent: String?)->()) -> Void {
        let aunicaTask = self.session.dataTask(with: self.request) { data, response, error in
            if let _ = error {
                completionHandler(false, nil, nil)
                return
            }
            let responseURL = (response as! HTTPURLResponse).url
            if let d = data {
                if let str = String(data: d, encoding: .utf8) {
                    completionHandler(true, responseURL, str)
                    return
                }
                if let str = String(data: d, encoding: .isoLatin2) {
                    completionHandler(true, responseURL, str)
                    return
                }
            }
            completionHandler(false, nil, nil)
        }
        aunicaTask.resume()
    }
    
    private func parsePage(_ content: String) -> String{
        var url = ""
        do {
            let doc: Document = try SwiftSoup.parse(content)
            let a: Element = try doc.select("a").last()!
            url = try a.attr("href")
        } catch {
            print("AunicaSession parsing error")
        }
       return url
    }
}
