//
//  AunicaloginTicketManager.swift
//  poliOrarioTest
//
//  Created by Matteo Visotto on 19/09/22.
//

import Foundation
import SwiftSoup

class AunicaloginTicketManager {
    
    private var content: String!
    
    private var session: URLSession = URLSession.shared
    
    private var request: URLRequest!
    
    init(htmlContent: String) {
        self.content = htmlContent
        prepareRequest()
    }
    
    private func prepareRequest() {
        let p = parseAuthForm(self.content)
        self.request = URLRequest(url: URL(string: p.postUrl)!)
        request.httpMethod = "POST"
        request.httpBody = p.fields.percentEncoded()
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
    
    private func parseAuthForm(_ content: String) -> PoliAuthFormData{
        var scrapedData: [String: String] = [:]
        var data: PoliAuthFormData = PoliAuthFormData(postUrl: "", fields: [:])
        do {
            let doc: Document = try SwiftSoup.parse(content)
            let form: Element = try doc.select("form").first()!
            data.postUrl = try form.attr("action")
            let fields = try form.getElementsByTag("input")
            for f in fields.array() {
                let name = try f.attr("name")
                let value = try f.attr("value")
                scrapedData[name] = value
            }
            data.fields = scrapedData
        } catch {
            print("AunicaTiket parsing error")
        }
        if (data.postUrl.starts(with: "aunicalogin/controller")){
            data.postUrl = "https://aunicalogin.polimi.it/aunicalogin/"+data.postUrl
        }
        return data
    }
}
