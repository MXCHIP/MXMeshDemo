//
//  AppDelegate.swift
//  MXApp
//
//  Created by 华峰 on 2022/11/4.
//

@_exported import UIKit
@_exported import MeshSDK
@_exported import MXURLRouter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        //页面路由注册
        MXRouterManager.registerRouter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(signedIn(notification:)), name: NSNotification.Name(rawValue: "MXNotificationUserSignedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(signedOut(notification:)), name: NSNotification.Name(rawValue: "MXNotificationUserSignedOut"), object: nil)
        
        MXResourcesManager.checkAppResources()
        
        if MXAccountManager.shared.ifAgreeProtocols {
            self.SDKInitialization()
        }
        
        if let token = MXAccountManager.shared.token {
            let mainView = MXMainTabBarController()
            self.window?.rootViewController = MXNavigationController(rootViewController: mainView)
        } else {
            let nav = UINavigationController(rootViewController: MXLaunchedPage())
            self.window!.rootViewController = nav
        }
        
        self.window?.makeKeyAndVisible()
        
        if MXAccountManager.shared.darkMode == 2 {
            UIApplication.shared.windows.forEach { window in
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .dark
                }
            }
        } else if MXAccountManager.shared.darkMode == 1 {
            UIApplication.shared.windows.forEach { window in
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .light
                }
            }
        }
        
        return true
    }
    
    func SDKInitialization() {
        // MesshSDK
//        let meshConfig = ["companyId": 2338, "proxyRSSI": -75, "isSegmented": false, "heartTimeout": 240.0, "cacheInvalid": 5.0] as [String : Any]
        let meshConfig = ["cacheInvalid": 5.0] as [String : Any]
        MeshSDK.sharedInstance.setup(config: meshConfig)
        
        self.createFirmwaresPath()
    }
    
    // 登录成功
    @objc func signedIn(notification: NSNotification) -> Void {
        MXAccountManager.shared.token = "login"
        let mainView = MXMainTabBarController()
        self.window?.rootViewController = MXNavigationController(rootViewController: mainView)
    }
    
    // 退出登录
    @objc func signedOut(notification: NSNotification) -> Void {
        MXAccountManager.shared.token = nil
        MeshSDK.sharedInstance.disconnect()
        
        let lauchView = MXLaunchedPage()
        self.window?.rootViewController = MXNavigationController(rootViewController: lauchView)
    }
    
    func createFirmwaresPath() {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let s = "\(path)/firmwares"
        try? FileManager.default.createDirectory(atPath: s, withIntermediateDirectories: true)
    }

}

