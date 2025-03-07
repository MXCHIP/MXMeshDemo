
import Foundation
import dsBridge
import UIKit

@objc
class MXBridgeLightApi: NSObject {
    public var device : MXDeviceInfo?
   
    
    @objc func getLightConfig(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var params = [String: Any]()
        params["isSupportTracing"] = false  //追光
        params["isSupportColoring"] = false //拍照取色
        params["isSupportRhythm"] = false //音乐律动
        callback(params, true)
    }
}
