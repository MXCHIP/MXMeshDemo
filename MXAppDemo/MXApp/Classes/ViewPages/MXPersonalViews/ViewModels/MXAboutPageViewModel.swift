
import Foundation

class MXAboutPageViewModel: NSObject {
    
    let model = MXAboutPageModel()
    
    var mxUpdatingViewClosure: ((_ model: MXAboutPageModel) -> Void)!
    
    func observe(handler:@escaping (_ model: MXAboutPageModel) -> Void) -> Void {
        self.mxUpdatingViewClosure = handler
    }
    
    func mxUpdateViews() -> Void {
        if let closure = mxUpdatingViewClosure {
            closure(model)
        }
    }
    
    func syncData() -> Void {
        
        if let info = Bundle.main.infoDictionary,
           let appVersion = info["CFBundleShortVersionString"] as? String,
           let buildVersion = info["CFBundleVersion"] as? String {
            model.currentVersion = "V" + appVersion + "(" + buildVersion + ")"
        }
        
        versionCheck()
    }
    
    
    func goToAppStore() -> Void {
        MXToastHUD.showInfo(status: localized(key: "暂无版本更新"))
    }
    
    
    func versionCheck() -> Void {
        self.mxUpdateViews()
    }
    
    func serviceAgreement() -> Void {
        MXResourcesManager.loadLocalAgreementUrl() { rootUrl in
            if let rootPath = rootUrl {
                let jumpUrl = "file://\(rootPath)/ServiceAgreement.html"
                let params = ["url": jumpUrl, "title": localized(key: "服务协议")]
                let url = "com.mxchip.bta/page/web"
                MXURLRouter.open(url: url, params: params)
            }
        }
    }
    
    func privacyPolicy() -> Void {
        MXResourcesManager.loadLocalAgreementUrl() { rootUrl in
            if let rootPath = rootUrl {
                let jumpUrl = "file://\(rootPath)/PrivacyStatement.html"
                let params = ["url": jumpUrl, "title": localized(key: localized(key: "隐私政策"))]
                let url = "com.mxchip.bta/page/web"
                MXURLRouter.open(url: url, params: params)
            }
        }
    }
    
    func showDocument(info: [String: Any]) -> Void {
        if let url = info["url"] as? String,
           let title = info["title"] as? String {
            
            let params = ["url": url, "title": title]
            let url = "com.mxchip.bta/page/web"
            
            MXURLRouter.open(url: url, params: params)
        }
    }
    
    
}
