
import Foundation
import MeshSDK

class MXDeviceManager: NSObject {
    public static var shard = MXDeviceManager()
    
    override init() {
        super.init()
    }
    
    func loadDevices(roomId:Int = 0, type: Int = 0) -> [MXDeviceInfo] {
        var device_list = [MXDeviceInfo]()
        if type == 0 {
            MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
                room.devices.forEach { (device:MXDeviceInfo) in
                    if device.isFavorite {
                        device_list.append(device)
                    }
                }
            })
        } else if type == 3, let rooms = MXHomeManager.shard.currentHome?.rooms {
            if roomId == 0 {  
                for room in rooms {
                    device_list.append(contentsOf: room.devices)
                }
            } else {
                if let room = rooms.first(where: {$0.roomId == roomId}) {
                    device_list.append(contentsOf: room.devices)
                }
            }
        }
        return device_list
    }
    
    
    func add(device:MXDeviceInfo, isSave:Bool = true) {
        self.delete(device: device, isSave: false)
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            if room.roomId == device.roomId {
                room.devices.append(device)
            }
        })
        if device.objType == 1, let subList = device.subDevices {
            subList.forEach { (item:MXDeviceInfo) in
                self.removeToGroup(device: item)
                item.roomId = device.roomId
                item.roomName = device.roomName
            }
        }

        if isSave {
            MXHomeManager.shard.updateHomeList()
        }
    }
    
    
    func removeToGroup(device:MXDeviceInfo) {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            room.devices.removeAll(where: {$0.isSameFrom(device)})
        })
    }
    
    
    func delete(device:MXDeviceInfo, isSave:Bool = true) {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            if room.devices.first(where: {$0.isSameFrom(device)}) != nil {
                room.devices.removeAll(where: {$0.isSameFrom(device)})
                if device.objType == 1, let subList = device.subDevices {
                    subList.forEach { (item:MXDeviceInfo) in
                        if room.devices.first(where: {$0.isSameFrom(item)}) == nil {
                            room.devices.append(item)
                        }
                    }
                }
            } else {
                room.devices.forEach { (item:MXDeviceInfo) in
                    if item.objType == 1, var subList = item.subDevices, subList.first(where: {$0.isSameFrom(device)}) != nil {
                        subList.removeAll(where: {$0.isSameFrom(device)})
                        item.subDevices = subList
                    }
                }
            }
            
            
        })
        
        MXHomeManager.shard.currentHome?.scenes.forEach({ (scene:MXSceneInfo) in
            scene.actions.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo {
                    if params.isSameFrom(device) {
                        params.isValid = false
                        if device.objType == 1 {
                            params.subDevices?.forEach({ (item:MXDeviceInfo) in
                                item.status = 3
                                item.writtenStatus = 0
                            })
                        }
                    } else if params.objType == 1, device.objType == 0, var subList = params.subDevices {
                        if let subDevice = subList.first(where: {$0.isSameFrom(device)}) {
                            subDevice.isValid = false
                        }
                        subList.removeAll(where: {!$0.isValid})
                        if subList.count <= 0 {
                            params.isValid = false
                        }
                        params.subDevices = subList
                    }
                }
            }
        })
        
        MXHomeManager.shard.currentHome?.autoScenes.forEach({ (scene:MXSceneInfo) in
            scene.conditions.items?.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo, params.isSameFrom(device) { 
                    scene.isValid = false
                    return
                }
            }
            scene.actions.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo {
                    if params.isSameFrom(device) {
                        params.isValid = false
                        if device.objType == 1 {
                            params.subDevices?.forEach({ (item:MXDeviceInfo) in
                                item.status = 3
                                item.writtenStatus = 0
                            })
                        }
                    } else if params.objType == 1, device.objType == 0, var subList = params.subDevices {
                        if let subDevice = subList.first(where: {$0.isSameFrom(device)}) {
                            subDevice.isValid = false
                        }
                        subList.removeAll(where: {!$0.isValid})
                        if subList.count <= 0 {
                            params.isValid = false
                        }
                        params.subDevices = subList
                    }
                }
            }
        })
        if isSave {
            MXHomeManager.shard.updateHomeList()
            
            NotificationCenter.default.post(name: NSNotification.Name("kMeshConnectStatusChange"), object: nil)
        }
    }
    
    func update(device:MXDeviceInfo) {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            if let newDevice = room.devices.first(where:{$0.isSameFrom(device)}) {
                newDevice.name = device.name
                newDevice.isFavorite = device.isFavorite
                if device.objType == 1 {
                    
                    var add_list = [MXDeviceInfo]()
                    device.subDevices?.forEach({ (item:MXDeviceInfo) in
                        if newDevice.subDevices?.first(where: {$0.isSameFrom(item)}) == nil {
                            add_list.append(item)
                        }
                    })
                    
                    var remove_list = [MXDeviceInfo]()
                    newDevice.subDevices?.forEach({ (item:MXDeviceInfo) in
                        if device.subDevices?.first(where: {$0.isSameFrom(item)}) == nil {
                            remove_list.append(item)
                        }
                    })
                    newDevice.subDevices = device.subDevices
                    newDevice.subDevices?.forEach({ (item:MXDeviceInfo) in
                        item.roomId = newDevice.roomId
                        item.roomName = newDevice.roomName
                    })
                    add_list.forEach { (item:MXDeviceInfo) in
                        self.removeToGroup(device: item)
                    }
                    room.devices.append(contentsOf: remove_list)
                }
                return
            }
        })
        
        MXHomeManager.shard.currentHome?.scenes.forEach({ (scene:MXSceneInfo) in
            var isSame = false
            scene.actions.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo, params.isSameFrom(device) {
                    isSame = true
                    params.name = device.name
                    if device.objType == 1 {
                        device.subDevices?.forEach({ (item:MXDeviceInfo) in
                            if params.subDevices?.first(where: {$0.isSameFrom(item)}) == nil {
                                item.status = 0
                                item.writtenStatus = 0
                                params.subDevices?.append(item)
                            }
                        })
                        params.subDevices?.forEach({ (item:MXDeviceInfo) in
                            if device.subDevices?.first(where: {$0.isSameFrom(item)}) == nil {
                                item.status = 3
                                item.writtenStatus = 0
                            }
                        })
                    }
                    return
                }
            }
            if isSame, device.objType == 1 {
                scene.actions.removeAll { (tac:MXSceneTACItem) in
                    if let params = tac.params as? MXDeviceInfo, device.subDevices?.first(where: {$0.isSameFrom(params)}) != nil {
                        return true
                    }
                    return false
                }
            }
        })
        
        MXHomeManager.shard.currentHome?.autoScenes.forEach({ (scene:MXSceneInfo) in
            var isSame = false
            scene.conditions.items?.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo, params.isSameFrom(device) {
                    params.name = device.name
                }
            }
            
            scene.actions.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo, params.isSameFrom(device) {
                    isSame = true
                    params.name = device.name
                    if device.objType == 1 {
                        device.subDevices?.forEach({ (item:MXDeviceInfo) in
                            if params.subDevices?.first(where: {$0.isSameFrom(item)}) == nil {
                                item.status = 0
                                item.writtenStatus = 0
                                params.subDevices?.append(item)
                            }
                        })
                        params.subDevices?.forEach({ (item:MXDeviceInfo) in
                            if device.subDevices?.first(where: {$0.isSameFrom(item)}) == nil {
                                item.status = 3
                                item.writtenStatus = 0
                            }
                        })
                    }
                }
                if isSame, device.objType == 1 {
                    scene.actions.removeAll { (tac:MXSceneTACItem) in
                        if let params = tac.params as? MXDeviceInfo, device.subDevices?.first(where: {$0.isSameFrom(params)}) != nil {
                            return true
                        }
                        return false
                    }
                }
            }
        })
        
        MXHomeManager.shard.updateHomeList()
    }
    
    
    func syncDeviceSettingInfo(device:MXDeviceInfo, handler:@escaping (_ isSuccess: Bool) -> Void) {
        if let uuidStr = device.meshInfo?.uuid {
            
            let attrType = UInt16(bigEndian: 0x0017)
            let attrStr = String(format: "%04X", attrType.littleEndian) + "02"
            MeshSDK.sharedInstance.sendMeshMessage(opCode: VendorMessageOpCode.VendorMessage_Attr_Set.rawValue, uuid: uuidStr, message: attrStr, timeout: 2.0) { (result: [String : Any]) in
                MXSceneManager.shard.getDeviceRuleInfo(device: device) { rules in
                    if let rule_list = rules {
                        MXSceneManager.shard.writeRuleToDevice(uuid: uuidStr, rules: rule_list) { isSuccess in
                            handler(isSuccess)
                        }
                    } else {
                        handler(true)
                    }
                }
            }
        } else {
            handler(true)
        }
    }
    
    static func isSupportH5Plan(_ device: MXDeviceInfo?) -> Bool {
        if let cId = device?.productInfo?.category_id {
            if cId > 100100, cId < 100107 { 
                return true
            } else if  cId > 100300, cId < 100320 { 
                return true
            } else if  cId >= 100320, cId < 100326 { 
                return true
            }
        }
        return false
    }
}

extension MXDeviceManager {
    
    static func gotoControlPanel(with device: MXDeviceInfo, testUrl:String? = nil) -> Void {
        if device.productInfo?.node_type_v2 == "gateway", device.productInfo?.category_id != 140301 {
            var params = [String : Any]()
            params["device"] = device
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
        } else if let h5_name = device.productInfo?.h5_plan_name, h5_name.count > 0 {
            var params = [String : Any]()
            params["device"] = device
            params["testUrl"] = testUrl
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/plan", params: params)
        } else if let plan_url = device.productInfo?.plan_url, plan_url.count > 0 {
            var params = [String : Any]()
            params["device"] = device
            MXURLRouter.open(url: "com.mxchip.bta/" + plan_url, params: params)
        } else {
            var params = [String : Any]()
            params["device"] = device
            if device.objType == 1 {
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/group_info", params: params)
            } else {
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
            }
        }
    }
    
    static func setProperty(with device: MXDeviceInfo, pInfo: MXPropertyInfo) {
        
        AppUIConfiguration.feedbackGenerator()
        guard MeshSDK.sharedInstance.isConnected(),
              let nk = MXHomeManager.shard.currentHome?.networkKey,
              let identifierStr = pInfo.identifier else {
            return
        }
        
        var newValue = 0
        if let pValue = pInfo.value as? Int {
            newValue = pValue
        }
        if let uuidStr = device.meshInfo?.uuid, uuidStr.count > 0 {
            if let specs = pInfo.dataType?.specs as? [String: String], specs.count > 0 {
                let sList = specs.keys.sorted { (s1:String, s2:String) in
                    return (Int(s1) ?? 0) < (Int(s2) ?? 0) ? true : false
                }
                if let index = sList.firstIndex(where: {Int($0) == newValue}) {
                    let nextIndex = index + 1
                    if sList.count > nextIndex {
                        newValue = Int(sList[nextIndex]) ?? 0
                    } else {
                        newValue = Int(sList[0]) ?? 0
                    }
                } else {
                    newValue = Int(sList[0]) ?? 0
                }
            } else {
                if newValue == 0 {
                    newValue = 1
                } else {
                    newValue = 0
                }
            }
            if let typeStr = MXMeshMessageHandle.identifierConvertToAttrType(identifier: identifierStr),
               let typeHex = UInt16(typeStr.littleEndian, radix: 16),
                (typeHex & 0x0FFF) == 0x0100 {
                newValue = 2
            }
            if let msgHex = MXMeshMessageHandle.properiesToMessageHex(identifier: identifierStr, value: newValue) {
                MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: msgHex)
            }
        } else if let meshAddress = device.meshInfo?.meshAddress {
            if let msgHex = MXMeshMessageHandle.properiesToMessageHex(identifier: identifierStr, value: newValue) {
                let address = String(format: "%04X", meshAddress)
                MeshSDK.sharedInstance.sendMessage(address: address, opCode: "12", message: msgHex, networkKey: nk)
            }
        }
    }
    
    static func showLaconic(with device: MXDeviceInfo) -> Void {
        if !MeshSDK.sharedInstance.isConnected() {
            MXToastHUD.showError(status: localized(key:"Room_设备离线描述"))
            return
        }
        
        guard let pList = device.properties?.filter({$0.isSupportQuickControl}) else {
            return
        }
        
        let nameStr = device.showName
        
        let cv = MXHomeDeviceControlView(title: nameStr, dataList: pList)
        cv.deviceInfo = device
        cv.didOptionCallback = {
            MXDeviceManager.gotoControlPanel(with: device)
        }
        cv.didSelectedCallback = {(info: MXDeviceInfo, pInfo: MXPropertyInfo) in
            MXDeviceManager.setProperty(with: info, pInfo: pInfo)
        }
        cv.show()
    }
}
