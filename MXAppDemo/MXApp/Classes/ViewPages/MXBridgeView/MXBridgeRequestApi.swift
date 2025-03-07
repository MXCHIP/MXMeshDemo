
import Foundation
import dsBridge

@objc
class MXBridgeRequestApi: NSObject {
    
    public var device: MXDeviceInfo?
    
    @objc func fetchOwnServer(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        guard let url = arg["url"] as? String else {
            return
        }
        
        if url.contains("app/v3/device/info") || url.contains("app/v3/device/group/info") {
            if let info = self.device, var params = MXDeviceInfo.mx_keyValue(info) {
                params["nick_name"] = info.name
                var result = [String : Any]()
                result["data"] = params
                result["code"] = 0
                result["message"] = ""
                callback(result, true)
            }
            return;
        } else if url.contains("app/v3/device/thingModel") {
            var result = [String : Any]()
            result["data"] = [String: Any]()
            result["code"] = 10404
            result["message"] = ""
            callback(result, true)
            return;
        }
    }
    
    @objc func getDeviceInfo(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        if let info = self.device, var params = MXDeviceInfo.mx_keyValue(info) {
            params["nick_name"] = info.name
            var result = [String : Any]()
            result["data"] = params
            result["code"] = 0
            result["message"] = ""
            callback(result, true)
        }
    }
}
