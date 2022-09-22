//
//  SharedPreferencesManager.swift
//  PoliBrowser
//
//

import Foundation
import UIKit

class PoliSelfOAuthClientSharedPreferencesManager {
    
    public static func setAccessToken(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "poliselfoauthclient.pref.access_token")
    }
    
    public static func setRefreshToken(refreshToken: String) {
        UserDefaults.standard.set(refreshToken, forKey: "poliselfoauthclient.pref.refresh_token")
    }
    
    public static func setTokenExpire(expireAt: String) {
        UserDefaults.standard.set(expireAt, forKey: "poliselfoauthclient.pref.token_expire")
    }
    
    public static func isUserLogged() -> Bool {
        return !(UserDefaults.standard.string(forKey: "poliselfoauthclient.pref.access_token") == nil ? true : false)
    }
    
    
    public static func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "poliselfoauthclient.pref.access_token")
    }
    
    public static func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: "poliselfoauthclient.pref.refresh_token")
    }
    
    public static func getExpiration() -> String? {
        return UserDefaults.standard.string(forKey: "poliselfoauthclient.pref.token_expire")
    }
    
    public static func deletePreferences() {
        UserDefaults.standard.removeObject(forKey: "poliselfoauthclient.pref.token_expire")
        UserDefaults.standard.removeObject(forKey: "poliselfoauthclient.pref.refresh_token")
        UserDefaults.standard.removeObject(forKey: "poliselfoauthclient.pref.access_token")
    }
}
