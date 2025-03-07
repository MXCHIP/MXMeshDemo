
import Foundation
import UIKit
import WebKit
import dsBridge


class MXBridgeWebViewController: UIViewController {
    
    public var device: MXDeviceInfo?
    public var testUrl : String?
    
    var zipName: String = ""
    
    var devicePage : MXBridgeDeviceApi!
    var apiPage : MXBridgePageApi!
    var requestApi : MXBridgeRequestApi!
    var lightApi : MXBridgeLightApi!
    
    var webview : DWKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let h5Name = self.device?.productInfo?.h5_plan_name {
            self.zipName = h5Name
        }
        
        let config = WKWebViewConfiguration.init()
        
        let _webview = DWKWebView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height),configuration: config)
        
        _webview.configuration.preferences.setValue(1, forKey: "allowFileAccessFromFileURLs")
        _webview.configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        _webview.configuration.preferences.javaScriptEnabled = true;
        _webview.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true;
        
        if #available(iOS 11, *) {
            _webview.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        }
        _webview.scrollView.showsVerticalScrollIndicator = false
        _webview.scrollView.showsHorizontalScrollIndicator = false
        _webview.scrollView.bounces = false
        _webview.dsuiDelegate = self
        self.webview = _webview
        
        
        self.view.backgroundColor = UIColor.gray
        
        let group = DispatchGroup()
        group.enter()
        self.webview.evaluateJavaScript("navigator.userAgent") { (result: Any?, error: Error?) in
            let oldUA = (result as? String) ?? ""
            let appBuildID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
            var language = NSLocale.preferredLanguages.first!
            if let currentLanguage = MXAccountManager.shared.language {
                language = currentLanguage
            }
            var userInterfaceStyleString = "light"
            if #available(iOS 13, *) {
                userInterfaceStyleString = (UITraitCollection.current.userInterfaceStyle == .dark) ? "dark" : "light"
            }
            if MXAccountManager.shared.darkMode == 1 {
                userInterfaceStyleString = "light"
            } else if MXAccountManager.shared.darkMode == 2 {
                userInterfaceStyleString = "dark"
            }
            let newUA = "\(oldUA) mxchip app/\(appBuildID) lang/\(language) theme/\(userInterfaceStyleString))"
            print("UA = \(newUA)")
            self.webview.customUserAgent = newUA
            group.leave()
        }
        
        self.view.addSubview(self.webview)
        self.webview.pin.all()
        
        self.view.addSubview(self.progress)
        
        self.devicePage = MXBridgeDeviceApi.init(meshInfo: self.device?.meshInfo)
        self.devicePage.device = self.device
        
        self.apiPage = MXBridgePageApi.init()
        self.apiPage.device = self.device
        self.apiPage.navigationController = self.navigationController
        self.apiPage.navigationItem = self.navigationItem
        self.apiPage.closeWebViewBlock = { [weak self] () in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.requestApi = MXBridgeRequestApi.init()
        self.requestApi.device = self.device
        
        self.lightApi = MXBridgeLightApi.init()
        self.lightApi.device = self.device
        
        self.webview.addJavascriptObject(self.devicePage, namespace: "device")
        self.webview.addJavascriptObject(self.apiPage, namespace: "page")
        self.webview.addJavascriptObject(self.requestApi, namespace: "request")
        self.webview.addJavascriptObject(self.lightApi, namespace: "light")
        
        group.notify(queue: DispatchQueue.main) {
            if let url = self.testUrl, url.count > 0  {
                let htmlURLStr = "http://\(String(describing: url))?productKey=\(self.device?.productKey ?? "")&category_id=\(String(self.device?.productInfo?.category_id ?? 0))&app=\(AppUIConfiguration.appType)&offline=1#/"
                self.webview.loadUrl(htmlURLStr)
            } else {
                self.loadWebView()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webview.pin.all()
        self.progress.pin.left().right().top(AppUIConfiguration.statusBarH).height(2.0)
    }
    
    public lazy var progress :UIProgressView = {
        
        let _progress = UIProgressView(frame: CGRect(x: 0, y: AppUIConfiguration.statusBarH, width: self.view.frame.size.width, height: 2.0))
        _progress.progressTintColor = AppUIConfiguration.MainColor.C0
        _progress.trackTintColor = UIColor.gray
        _progress.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        _progress.isHidden = true
        return _progress
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webview.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        let newInfo = ["type": "cycle", "data": "viewWillAppear"] as [String : Any]
        self.devicePage.hanlder?(newInfo, true)
        self.webview.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    deinit {
        if self.webview != nil {
            self.webview.removeJavascriptObject("page")
            self.webview.removeJavascriptObject("device")
            self.webview.removeJavascriptObject("request")
            self.webview.removeJavascriptObject("light")
            self.webview.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            if keyPath == "estimatedProgress" {
                if (object as? DWKWebView) == self.webview{
                    self.progress.isHidden = false
                    self.progress.alpha = 1.0
                    let pValue = self.webview.estimatedProgress
                    self.progress.setProgress(Float(pValue), animated: true)
                    if pValue >= 1.0 {
                        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut) {
                            self.progress.alpha = 0.0
                        } completion: { (finished: Bool) in
                            self.progress.setProgress(0.0, animated: false)
                            self.progress.isHidden = true
                        }

                    }
                    
                } else {
                    super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                }
            }
        }
    }
}

extension MXBridgeWebViewController {
    
    func showErrorMsg() {
        let alert = UIAlertController(title: nil, message: localized(key:"页面加载失败"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: localized(key:"退出"), style: .cancel) { (action:UIAlertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        }
        let comfirmAction = UIAlertAction(title: localized(key:"重试"), style: .default) { (action:UIAlertAction) in
            self.loadWebView()
        }
        alert.addAction(cancelAction)
        alert.addAction(comfirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadWebView() {
        MXResourcesManager.loadLocalZipResourcesUrl(name: self.zipName) { (filePath:String?) in
            if let path = filePath {
                let rootAppURL = MXResourcesManager.loadHtmlLocalRootUrl()
                DispatchQueue.main.async {
                    var htmlURLStr = "file://\(path)/index.html?productKey=\(self.device?.productKey ?? "")&category_id=\(String(self.device?.productInfo?.category_id ?? 0))&app=\(AppUIConfiguration.appType)&offline=1"
                    htmlURLStr = htmlURLStr + "#/"
                    print("加载的URL = \(htmlURLStr)")
                    if let htmlUrl = URL(string: htmlURLStr) {
                        self.webview.loadFileURL(htmlUrl, allowingReadAccessTo: rootAppURL)
                    } else {
                        self.showErrorMsg()
                    }
                }
            } else {
                self.showErrorMsg()
            }
        }
    }
    
}

extension MXBridgeWebViewController: WKNavigationDelegate {
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.webview.reload()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.webview.reload()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.webview.reload()
    }
}

extension MXBridgeWebViewController: WKUIDelegate, MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXBridgeWebViewController()
        controller.device = params["device"] as? MXDeviceInfo
        controller.testUrl = params["testUrl"] as? String
        return controller
    }
}
