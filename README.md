# PoliSelfOAuthClient

Package to connect into PoliMi Online Services using university OAuth IdP and get pages HTML ready from scraping.<br/>
The package manages login and logout procedures, saves tokens and perform auto refresh of token when needed<br/>
Now also the new REST API of the official PoliMi App are supported. The web and the rest part uses different authentication methods but in this package both are automatically managed.<br/>
Note: Scraping library is alredy included in the package (SwiftSoup: https://github.com/scinfu/SwiftSoup)

## Usage
The package has to be initialized into AppDelegate into application didFinishLaunchingWithOptions method using:
```swift
PoliSelfOAuthClient.shared.initialize()
```
By default the REST API part is managed, you can desable by calling the initialize method with a false parameter<br/><br/>
This is needed to initialize the package and also to perform OAuth token refresh automatically if a user is alredy logged in
In order to receive update on authentication status you can implement PoliSelfOAuthClientStatusManagerDelegate, for example
```swift
class MyClass {
  init(){
    PoliSelfOAuthClient.shared.registerForStatusUpdate(statusManagerDelegate: self)
  }

}

extension MyClass: PoliSelfOAuthClientStatusManagerDelegate {
  public func onStatusUpdate(appStatus: AccountStatus) {
        // Your status management here
  }
  
  public func onRestStatusUpdate(appStatus: AccountStatus) {
        // Your rest status management here
  }
  
}
```
The login view with PoliMi is already embedded into the package, to start a new login use:
```swift
PoliSelfOAuthClient.shared.poliSelfLogin { result in
    //result:Bool true if successfully authenticated
}
```
In the same way you can perform logout (no result are given back)
```swift
PoliSelfOAuthClient.shared.logout()
```
Finally, to get the HTML content from a poliSelf page use the following function:
```swift
PoliSelfOAuthClient.shared.getServicePage(service: .carriera) { result, url, htmlString in
  // result: Bool -> True if completed successfully
  // url: URL? -> Optional value, contains the url of the page when result is success
  // htmlString: String -> Optional value, contains the HTML code of the page ready for scraping (or load into a WebView).
}
```
For the REST API an equialent function is available
```swift
PoliSelfOAuthClient.shared.getRestService(restEndpointUrl: "https://polimiapp.polimi.it/polimi_app/rest/jaf/internal/user") { result, jsonString in
  // result: Bool -> True if completed successfully
  // jsonString: String? -> Optional value, contains the stringified version of the JSON response.
}
```

## Functions
All this function and variable are available in the shared instance
```swift
(get) var accessToken: String?
(get) var isUserLogged: Bool
(get) var restAccessToken: String?
(get) var isRestUserLogged: Bool

func initialize(useRestService: Bool = true) -> Void
func registerForStatusUpdate(_ observer: PoliSelfOAuthClientStatusManagerDelegate) -> Void
func poliSelfLogin(completionHandler: @escaping (_ result: Bool)->()) -> Void
func logout() -> Void
func getServicePage(service: PoliSelfService.Service, completionHandler: @escaping (_ result: Bool, _ url: URL?, _ htmlString: String?)->()) -> Void
func getRestService(restEndpointUrl: String, completionHandler: @escaping (_ result: Bool, _ jsonString: String?) -> () ) -> Void
func reconstructPoliSession(completionHandler: @escaping (_ result: Bool, _ cookies: [HTTPCookie]?)->()) -> Void
func getPoliCookies() -> [HTTPCookie]?
```

## Cookie management
Once the PoliMi Online Service session has been reconstructed from the OAuth provider the session cookies can be extracted. If you are using package function this operation is not needed bacuse it is managed from the package itself. If, instead, you need to load the HTML on a WebView or you need to load directly a service on a WebView you may need to inject cookies to keep the user authenticated. At this scope you can get all cookies from PoliSelfOAuthClient as follow:
```swift
PoliSelfOAuthClient.shared.getPoliCookies()
```
Remember that the returned value is an optional, so you have to check if cookies are available or not.
<br/>
If the function returns nil, you can rebuilt the session using:
```swift
PoliSelfOAuthClient.shared.reconstructPoliSession { result, cookies in
  
}
```

## Notes about REST Service
The REST API tokens are created after the web login has completed while are refreshed differently. For that reason two status update functions have been created. We reccomend to check the status of each part before perform operations.
