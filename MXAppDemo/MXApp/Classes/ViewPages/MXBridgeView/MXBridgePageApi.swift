
import Foundation
import dsBridge

@objc
class MXBridgePageApi: NSObject {
    public var device : MXDeviceInfo?
    public var navigationController: UINavigationController!
    public var navigationItem : UINavigationItem!
    public typealias CloseWebViewBlock = () -> ()
    public var closeWebViewBlock : CloseWebViewBlock!
    
    @objc func getToken(_ callback: @escaping JSCallback) {
        let accessToken = MXAccountManager.shared.token
        callback(accessToken,true)
    }
    
    @objc func getPlatformInfo(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        guard let infoDic = Bundle.main.infoDictionary else {
            return
        }
        if let app_Version = infoDic["CFBundleShortVersionString"] as? String {
            let result = ["platform":"ios","version":app_Version]
            callback(result,true)
        }
    }
    
    @objc func closeWebView(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.closeWebViewBlock?()
        callback("success", true)
    }
    
    @objc func has(_ path: String, callback: @escaping JSCallback) {
        let enable = MXURLRouterService.canOpen(url: String(format: "https://com.mxchip.bta/%@", path))
        let status = enable ? "1" : ""
        callback(status, true)
    }
    
    @objc func go(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        guard var path = arg["path"] as? String else {
            return
        }
        guard var query = arg["query"] as? [String : Any] else {
            return
        }
        
        if path == "page/scene/settingProperty" {  
            if !MXHomeManager.shard.operationAuthorityCheck() {
                return
            }
        }
        if path == "page/device/detail", self.device?.objType == 1 {
            path = "page/device/group_info"
        }
        query["device"] = self.device
        MXURLRouter.open(url: String(format: "https://com.mxchip.bta/%@", path), params: query)
        callback("success", true)
    }
    
    @objc func getBarColor(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var alpha = 1.0 as Float
        if let newAlpha = arg["alpha"] as? Float {
            alpha = newAlpha
        }
        guard let rgb = arg["rgb"] as? String else {
            return
        }
        let bridgeVC = self.navigationController.viewControllers.first
        bridgeVC?.view.backgroundColor = UIColor(hex: rgb, alpha: alpha)
    }
    
    @objc func getBarHeight(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        let h = UIApplication.shared.statusBarFrame.size.height
        let result = ["bottom":0,"top":h]
        callback(result, true)
    }
    
    @objc func setTitle(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        if let title = arg["title"] as? String {
            self.navigationItem?.title = title
        }
    }
}
