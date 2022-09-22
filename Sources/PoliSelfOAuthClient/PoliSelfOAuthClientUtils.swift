//
//  Utils.swift
//  PoliBrowser
//
//

import Foundation
import UIKit
import CommonCrypto

class PoliSelfOAuthClientUtils {
    public static func getNow23h() -> String {
        var date = ""
        let now23 = Date().addingTimeInterval(23*60*60)
        let formatter = DateFormatter()
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        date = formatter.string(from: now23)
        return date
    }
    
    public static func isTokenValid() -> Bool{
        let formatter = DateFormatter()
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let savedDate = formatter.date(from: PoliSelfOAuthClientSharedPreferencesManager.getExpiration()!){
            if(savedDate > Date()){
                return true
            }
        }
        return false
    }
    
}

extension Data{
    public func sha256() -> String{
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

public extension String {
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}
