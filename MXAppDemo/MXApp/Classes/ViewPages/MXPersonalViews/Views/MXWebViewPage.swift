
import Foundation
import WebKit

class MXWebViewPage: MXBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.navTitle
        contentView.addSubview(webView)
        
        let group = DispatchGroup()
        group.enter()
        self.webView.evaluateJavaScript("navigator.userAgent") { (result: Any?, error: Error?) in
            let oldUA = (result as? String) ?? ""
            let appBuildID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
            let language = MXAccountManager.shared.language ?? Locale.preferredLanguages[0]
            var userInterfaceStyleString = "light"
            if #available(iOS 13, *) {
                userInterfaceStyleString = (UITraitCollection.current.userInterfaceStyle == .dark) ? "dark" : "light"
            }
            if MXAccountManager.shared.darkMode == 1 {
                userInterfaceStyleString = "light"
            } else if MXAccountManager.shared.darkMode == 2 {
                userInterfaceStyleString = "dark"
            }
            let newUA = "\(oldUA) mxchip app/\(appBuildID) lang/\(language) theme/\(userInterfaceStyleString) productType/virtual"
            self.webView.customUserAgent = newUA
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            if let url = URL(string: self.url) {
                if url.isFileURL {
                    self.webView.loadFileURL(url, allowingReadAccessTo: MXResourcesManager.loadAgreementRootUrl())
                } else {
                    self.webView.load(URLRequest(url: url))
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.pin.all()
    }
    
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    var url = ""
    var navTitle = ""
}


extension MXWebViewPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXWebViewPage()
        if let title = params["title"] as? String,
           let url = params["url"] as? String {
            vc.navTitle = title
            let language = MXAccountManager.shared.language ?? Locale.preferredLanguages[0]
            let themeColor = "FF33D1FF"
            var userInterfaceStyleString = "light"
            if #available(iOS 13, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    userInterfaceStyleString = "dark"
                }
            }
            if MXAccountManager.shared.darkMode == 1 {
                userInterfaceStyleString = "light"
            } else if MXAccountManager.shared.darkMode == 2 {
                userInterfaceStyleString = "dark"
            }
            if url.contains("?") {
                vc.url = url + "&themecolor=\(themeColor)&lang=\(language)&theme=\(userInterfaceStyleString)"
            } else {
                vc.url = url + "?themecolor=\(themeColor)&lang=\(language)&theme=\(userInterfaceStyleString)"
            }
        }
        return vc
    }
    
}
