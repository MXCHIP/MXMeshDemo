//
//  MXDeviceManager+Provisioning.swift
//  MXApp
//
//  Created by huafeng on 2023/12/11.
//

import Foundation

extension MXDeviceManager {
    //获取网关连接状态
    static public func requestGatewayStatus(uuid: String, handler:@escaping (_ result: [String: Int]) -> Void) {
        let attrStr = "001B".littleEndian + "01"
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuid, message: attrStr) { (result:[String : Any]) in
            guard  let resultMsg = result["message"] as? String else {
                handler([String: Int]())
                return
            }
            let resultData = [UInt8](Data(hex: resultMsg))
            var resultParams = [String: Int]()
            if resultData.count > 4 {
                let subType1 = String(format: "%02X", resultData[3])
                let subValue1 = String(format: "%02X", resultData[4])
                resultParams[subType1] = Int(subValue1, radix: 16)
            }
            if resultData.count > 6 {
                let subType2 = String(format: "%02X", resultData[5])
                let subValue2 = String(format: "%02X", resultData[6])
                resultParams[subType2] = Int(subValue2, radix: 16)
            }
            handler(resultParams)
        }
    }
    //请求has password
    static public func requestHasPassword(uuid:String, handler:@escaping (_ result: String?) -> Void) {
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuid, message: "1A00") { (result:[String : Any]) in
            guard  let resultMsg = result["message"] as? String else {
                handler(nil)
                return
            }
            if resultMsg.count > 4 {
                let attrValue = String(resultMsg.suffix(resultMsg.count-4))
                if let text = String(data: Data(hex: attrValue), encoding: .utf8) {
                    handler(text)
                    return
                }
            }
            handler(nil)
        }
    }
    
    //请求网关IP
    static public func requestGatewayIp(type: Int = 2, uuid:String, handler:@escaping (_ result: String?) -> Void) {
        let attrStr = "001B".littleEndian + "02" + String(format: "%02X", type)
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuid, message: attrStr) { (result:[String : Any]) in
            guard  let resultMsg = result["message"] as? String else {
                if type == 2 {
                    MXDeviceManager.requestGatewayIp(type: 1, uuid: uuid, handler: handler)
                    return
                }
                handler(nil)
                return
            }
            let resultData = [UInt8](Data(hex: resultMsg))
            if resultData.count > 6, resultData[3] > 0 {
                let ipStr = String(resultData[3]) + "." + String(resultData[4]) + "." + String(resultData[5]) + "." + String(resultData[6])
                print("获取到网关的IP地址：\(ipStr)")
                handler(ipStr)
                return
            } else if type == 2 {
                MXDeviceManager.requestGatewayIp(type: 1, uuid: uuid, handler: handler)
                return
            }
            handler(nil)
        }
    }
}
