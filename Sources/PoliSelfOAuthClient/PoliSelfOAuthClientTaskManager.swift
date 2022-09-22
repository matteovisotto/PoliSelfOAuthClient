//
//  TaskManager.swift
//  PoliBrowser
//
//

import Foundation
import UIKit

protocol PoliSelfOAuthClientTaskManagerDelegate {
    func taskManager(taskManager: PoliSelfOAuthClientTaskManager, didFinishWith result: Bool, stringContent: String) -> Void
}

class PoliSelfOAuthClientTaskManager: NSObject {
    open var delegate: PoliSelfOAuthClientTaskManagerDelegate? = nil
    private var url: URL!
    private var parameters: [String: Any]!
    
    required init(url: URL, parameters: [String: Any]) {
        self.url = url
        self.parameters = parameters
    }
    
    public func execute() {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.httpBody = self.parameters.percentEncoded()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: error.localizedDescription)
                return
            }
            let response = response as! HTTPURLResponse
            let status = response.statusCode
            guard (200...299).contains(status) else {
                self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: "Error: \(status)")
                return
            }
            if let d = data {
                if let s = String(data: d, encoding: .utf8) {
                    self.delegate?.taskManager(taskManager: self, didFinishWith: true, stringContent: s)
                } else {
                    self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: "Data conversion error")
                }
            } else {
                self.delegate?.taskManager(taskManager: self, didFinishWith: false, stringContent: "Data reading error")
            }
        }
        task.resume()
    }
    
}

extension PoliSelfOAuthClientTaskManagerDelegate {
    func taskManager(taskManager: PoliSelfOAuthClientTaskManager, didFinishWith result: Bool, stringContent: String) -> Void {}
}
