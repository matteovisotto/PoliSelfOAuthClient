//
//  File.swift
//  
//
//  Created by Matteo Visotto on 20/09/22.
//

import Foundation
import UIKit

class PoliSelfOAuthClientConst {
    public static let AUTH_SERVER = "https://oauthidp.polimi.it/oauthidp/oauth2/auth?response_type=token&client_id=9978142015&client_secret=61760&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=openid+865+aule+orario+rubrica+webmail+beep+guasti+appelli+prenotazione+code+notifiche+esami+carriera+chat+webeep+polimi_app&access_type=offline"
    public static let AUTH_TOKEN_WEB = "https://oauthidp.polimi.it/oauthidp/oauth2/postLogin"
    public static let TOKEN_SERVER = "https://oauthidp.polimi.it/oauthidp/oauth2/token"
    public static let REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
    public static let CLIENT_ID = "9978142015"
    public static let CLIENT_SECRET = "61760"
    
    public static let REST_RETURN_URL = "https://polimiapp.polimi.it/polimi_app/app"
    public static let REST_AUTH_SERVER = "https://oauthidp.polimi.it/oauthidp/oauth2/auth?client_id=1057407812&redirect_uri=https%3A%2F%2Fpolimiapp.polimi.it%2Fpolimi_app%2Fapp&scope=openid%20polimi_app%20aule%20policard%20incarichi%20orario%20account%20webmail%20faqappmobile%20rubrica%20richass%20guasti%20prenotazione%20code%20carriera%20alumni%20webeep%20teamwork&access_type=offline&response_type=code&state=n"
    public static let REST_CODE_SERVER = "https://polimiapp.polimi.it/polimi_app/rest/jaf/oauth/token/get/"
    public static let REST_REFRESH_SERVER = "https://polimiapp.polimi.it/polimi_app/rest/jaf/oauth/token/refresh/"

}
