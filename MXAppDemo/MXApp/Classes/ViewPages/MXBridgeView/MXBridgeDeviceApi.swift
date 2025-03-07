
import Foundation
import dsBridge
import MeshSDK

@objc
class MXBridgeDeviceApi: NSObject {
    
    public var device : MXDeviceInfo?
    
    var hanlder: JSCallback?
    
    var messageNeedDelay: Bool = true
    var isSupportHex: Bool = false
    var msgTimestamp: TimeInterval = 0
    var lastMsgPamras : [String: Any]!
    
    var meshInfo:MXMeshInfo?
    
    public var remoteStatus : Bool = false
    public var locateStatus : Bool = false
    
    
    var localWorkItem : DispatchWorkItem?
    
    convenience init(meshInfo:MXMeshInfo?) {
        self.init()
        self.meshInfo = meshInfo
        
        if self.meshInfo?.meshAddress != nil, self.meshInfo?.uuid == nil {  
            self.remoteStatus = true
            self.locateStatus = true
        } else {
            if let uuidStr = self.meshInfo?.uuid, uuidStr.count > 0 {
                NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeLocate(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromLocate"), object: nil)
                
                self.locateStatus = MeshSDK.sharedInstance.isConnected()
            }
        }
    }
    
    deinit {
        self.localWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func registThing(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.hanlder = callback
        if  let needDelay = arg["messageControl"] as? Bool {
            self.messageNeedDelay = needDelay
        }
        if let isHex = arg["hex"] as? Bool {
            self.isSupportHex = isHex
        }
        
        self.refreshDeviceStatus()
    }
    
    
    @objc func meshConnectChange(notif: Notification) {
        guard let uuidStr = self.meshInfo?.uuid, uuidStr.count > 0 else {
            return
        }
        let value = MeshSDK.sharedInstance.isConnected()
        if self.locateStatus != value {
            self.locateStatus = value
            self.refreshDeviceStatus()
        }
    }
    
    func refreshDeviceStatus() {
        var retDic = [String : Any]()
        retDic["type"] = "status"
        var status = [String : Any]()
        status["value"] = (self.remoteStatus || self.locateStatus) ? 1 : 0
        status["remoteStatus"] = self.remoteStatus ? 1 : 0
        status["localStatus"] = self.locateStatus ? 1 : 0
        retDic["data"] = status
        self.hanlder?(retDic, false)
    }
    
    @objc func getStatus(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        self.locateStatus = MeshSDK.sharedInstance.isConnected()
        var status = [String : Any]()
        status["status"] = (self.remoteStatus || self.locateStatus) ? 1 : 0
        status["remoteStatus"] = self.remoteStatus ? 1 : 0
        status["localStatus"] = self.locateStatus ? 1 : 0
        
        callback(status, true)
        
    }
    
    @objc func getPropertiesFull(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var device_uuid = self.meshInfo?.uuid
        if self.device?.objType == 1, let info = self.device?.subDevices?.first {  
            device_uuid = info.meshInfo?.uuid
        }
        if let uuidStr = device_uuid, uuidStr.count > 0, MeshSDK.sharedInstance.isConnected() {
            if self.isSupportHex, let hexStr = arg["hex"] as? String {
                MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: hexStr, timeout: 5.0) { (result :[String : Any]) in
                    guard  let attrStr = result["message"] as? String else {
                        callback([String : Any](), true)
                        return
                    }
                    callback(attrStr, true)
                }
                return
            }
            
            guard let curSet = arg["data"] as? [String] else {
                MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: "", timeout: 5.0) { (result :[String : Any]) in
                    var resultParams = [String : Any]()
                    if let attrHex = result["message"] as? String {
                        resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrHex)
                    }
                    var newResult = [String :Any]()
                    for key in resultParams.keys {
                        newResult[key] = ["value": resultParams[key]]
                    }
                    callback(newResult, true)
                }
                return
            }
            var attrStr = String()
            for name in curSet {
                if let type = MXMeshMessageHandle.identifierConvertToAttrType(identifier: name) {
                    attrStr.append(type)
                }
            }
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: attrStr, timeout: 5.0) { (result :[String : Any]) in
                var resultParams = [String : Any]()
                if let attrHex = result["message"] as? String {
                    resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrHex)
                }
                var newResult = [String :Any]()
                for key in resultParams.keys {
                    newResult[key] = ["value": resultParams[key]]
                }
                callback(newResult, true)
            }
        }
    }
    
    @objc func setProperties(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        
        guard MeshSDK.sharedInstance.isConnected(), let nk = MXHomeManager.shard.currentHome?.networkKey else {
            return
        }
        
        var messageOpCode : String! = "11"
        if (arg["messageType"] as? String) == "unack" {
            messageOpCode = "12"
        }
        
        
        self.msgTimestamp = Date().timeIntervalSince1970
        
        var attrStr = String()
        if self.isSupportHex,let hexStr = arg["hex"] as? String {
            attrStr = hexStr
        } else if let curSet = arg["data"] as? [String : Any] {
            for name in curSet.keys {
                let value = curSet[name] as Any
                if let msgHex = MXMeshMessageHandle.properiesToMessageHex(identifier: name, value: value) {
                    attrStr.append(msgHex)
                }
            }
        }
        
        if let uuidStr = self.meshInfo?.uuid, uuidStr.count > 0 {
            if let low = self.device?.productInfo?.not_receive_message, low { //设备收不到消息
                let address = MeshSDK.sharedInstance.getNodeAddress(uuid: uuidStr)
                let parameters = "0010".littleEndian + address.littleEndian + attrStr
                MeshSDK.sharedInstance.sendMessage(address: "D003", opCode: "12", message: parameters, networkKey: nk, repeatNum: 2)
            } else {
                MeshSDK.sharedInstance.sendMeshMessage(opCode: messageOpCode, uuid: uuidStr, message: attrStr) { (result :[String : Any]) in
                    var resultParams = [String : Any]()
                    if let attrHex = result["message"] as? String {
                        resultParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrHex)
                    }
                    callback(resultParams, true)
                }
            }
        } else if let meshAddress = self.meshInfo?.meshAddress {
            let mesh_address = String(format: "%04X", meshAddress)
            MeshSDK.sharedInstance.sendMessage(address: mesh_address, opCode: "12", message: attrStr, networkKey: nk, repeatNum: 2)
            callback([String : Any](), true)
        }
    }
    
    @objc func sendMeshMessage(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        
        
        guard var meshAddress = self.meshInfo?.meshAddress else {
            
            return
        }
        
        var isFromNetwork = false
        if let fromNetwork = arg["isFromNetwork"] as? Bool {
            isFromNetwork = fromNetwork
        }
        
        var opCode = "12"
        var msgBody = ""
        if let mesh_opCode = arg["opCode"] as? String {
            opCode = mesh_opCode
        }
        if let mesh_message = arg["msgBody"] as? String {
            msgBody = mesh_message
        }
        var mesh_address = String(format: "%04X", meshAddress)
        var repeatNum: Int = 1
        if let meshAddress = arg["groupAddress"] as? String {  
            mesh_address = meshAddress
            repeatNum = 2
        }
        if let num = arg["repeatNum"] as? Int {  
            repeatNum = num
        }
        
        if MeshSDK.sharedInstance.isConnected(), let nk = MXHomeManager.shard.currentHome?.networkKey {
            MeshSDK.sharedInstance.sendMessage(address: mesh_address, opCode: opCode, message: msgBody, networkKey: nk, repeatNum: repeatNum)
        }
    }
    
    @objc func actionLinkage(_ arg: Dictionary<String,Any>, callback: @escaping JSCallback) {
        var isFromNetwork = false
        if let fromNetwork = arg["isFromNetwork"] as? Bool {
            isFromNetwork = fromNetwork
        }
        if let uuidStr = self.meshInfo?.uuid, uuidStr.count > 0, let nk = MXHomeManager.shard.currentHome?.networkKey {
            if let dict = arg["data"] as? [String : Any] {
                guard let opCode = dict["opCode"] as? String else {
                    return
                }
                var value: Int = 0
                if let dataValue = dict["specKey"] as? Int {
                    value = dataValue
                } else if let key = dict["specKey"] as? String, let dataValue = Int(key) {
                    value = dataValue
                }
                let valueNum = String(format: "%02X", value)
                
                let address = MeshSDK.sharedInstance.getNodeAddress(uuid: uuidStr)
                let parameters = "0010".littleEndian + address.littleEndian + opCode.littleEndian + valueNum
                if MeshSDK.sharedInstance.isConnected(), !isFromNetwork {
                    MeshSDK.sharedInstance.sendMessage(address: "D003", opCode: "12", message: parameters, networkKey: nk, repeatNum: 2)
                }
            }
        }
    }
    
}

extension MXBridgeDeviceApi {
    
    @objc func devicePropertyChangeLocate(notif: Notification) {
        guard let uuidStr = self.meshInfo?.uuid, uuidStr.count > 0 else {
            return
        }
        guard let dic = notif.object as? [String : Any] else {
            return
        }
        guard let msgDict = dic[uuidStr] as? [String : Any]  else {
            return
        }
        guard let attrStr = msgDict["message"] as? String  else {
            return
        }
        if self.isSupportHex {
            let retDict = ["type":"hex","data":attrStr]
            self.hanlder?(retDict, false)
        } else {
            let result = MXMeshMessageHandle.resolveMeshMessageToProperties(message: attrStr)
            var newResult = [String : Any]()
            for key in result.keys {
                newResult[key] = ["value": result[key]]
            }
            
            if self.lastMsgPamras == nil {
                self.lastMsgPamras = [String : Any]()
            }
            for key in newResult.keys {
                self.lastMsgPamras[key] = newResult[key]
            }
            self.meshMessageHandle()
        }
    }
    
    func meshMessageHandle() {
        guard let params = self.lastMsgPamras, params.count > 0 else {
            return
        }
        
        if self.msgTimestamp > 0, self.messageNeedDelay {
            let msgDuration = Date().timeIntervalSince1970 - self.msgTimestamp
            if msgDuration < 3 {
                
                self.localWorkItem?.cancel()
                self.localWorkItem = nil
                self.localWorkItem = DispatchWorkItem { [weak self] in
                    self?.meshMessageHandle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (3.0-msgDuration), execute: self.localWorkItem!)
                return
            }
        }
        
        let result = ["type":"property","data":params] as [String : Any]
        print("回调给H5的数据： \(result)")
        self.hanlder?(result, false)
        self.lastMsgPamras = nil
        self.msgTimestamp = 0
    }
}
