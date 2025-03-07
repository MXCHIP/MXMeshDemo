
import Foundation
import MeshSDK

class MXSceneManager: NSObject {
    
    public typealias MXDeviceRuleSettingCallback = (Bool) -> ()
    
    public static var shard = MXSceneManager()
    
    override init() {
        super.init()
        self.loadMXTemplateData()
    }
    
    let deviceWrittenView: MXSceneDeviceStatusView = MXSceneDeviceStatusView.shard
    var needWrittenDeviceList = [MXDeviceInfo]()
    var currenWrittenIndex: Int = 0
    var currentScene: MXSceneInfo? = nil
    
    public var lightTemplateList = [MXSceneTemplateInfo]()
    
    func loadRoomScenes(roomDevices:[MXDeviceInfo]) -> [MXSceneInfo] {
        var scene_list = [MXSceneInfo]()
        MXHomeManager.shard.currentHome?.scenes.forEach({ (scene:MXSceneInfo) in
            if scene.isValid, scene.actions.first(where: { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo, let _ = roomDevices.first(where: {$0.isSameFrom(obj)}) {
                    return true
                }
                return false
            }) != nil {
                scene_list.append(scene)
                return
            }
        })
        return scene_list
    }
    
    func delete(scene:MXSceneInfo) {
        
        if let newScene = MXHomeManager.shard.currentHome?.scenes.first(where: {$0.sceneId == scene.sceneId}) {
            newScene.actions.forEach { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo {
                    if obj.objType == 0 {
                        obj.status = 3
                    } else if let nodes = obj.subDevices {
                        nodes.forEach { (device:MXDeviceInfo) in
                            device.status = 3
                        }
                        obj.subDevices = nodes
                    }
                }
            }
            newScene.actions.removeAll { (info:MXSceneTACItem) in
                if let obj = info.params as? MXDeviceInfo, obj.isValid {
                    return false
                }
                return true
            }
            newScene.isValid = false  
        } else if let newScene = MXHomeManager.shard.currentHome?.autoScenes.first(where: {$0.sceneId == scene.sceneId}) {
            newScene.actions.forEach { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo {
                    if obj.objType == 0 {
                        obj.status = 3
                    } else if let nodes = obj.subDevices {
                        nodes.forEach { (device:MXDeviceInfo) in
                            device.status = 3
                        }
                        obj.subDevices = nodes
                    }
                }
            }
            newScene.actions.removeAll { (info:MXSceneTACItem) in
                if let obj = info.params as? MXDeviceInfo, obj.isValid {
                    return false
                }
                return true
            }
            
        }
        MXHomeManager.shard.currentHome?.scenes.removeAll(where: {$0.actions.count == 0})
        MXHomeManager.shard.currentHome?.autoScenes.removeAll(where: {$0.actions.count == 0})
        MXHomeManager.shard.updateHomeList()
    }
    
    func add(scene:MXSceneInfo) {
        var lastId = 1
        let cache_sceneId = UserDefaults.standard.integer(forKey: "MXNextSceneId")
        if cache_sceneId > lastId {
            lastId = cache_sceneId
        }
        if let last = MXHomeManager.shard.currentHome?.scenes.max(by: {$0.sceneId < $1.sceneId}) {
            if last.sceneId >= lastId {
                lastId = last.sceneId + 1
            }
        }
        if let last = MXHomeManager.shard.currentHome?.autoScenes.max(by: {$0.sceneId < $1.sceneId}) {
            if last.sceneId >= lastId {
                lastId = last.sceneId + 1
            }
        }
        UserDefaults.standard.set(lastId + 1, forKey: "MXNextSceneId")
        scene.sceneId = lastId
        scene.vid = MXHomeManager.shard.getNextAvailableVid()
        if scene.type == "one_click" {
            MXHomeManager.shard.currentHome?.scenes.append(scene)
        } else {
            MXHomeManager.shard.currentHome?.autoScenes.append(scene)
        }
        MXHomeManager.shard.updateHomeList()
    }
    
    func update(scene:MXSceneInfo) {
        if scene.type == "one_click", let index = MXHomeManager.shard.currentHome?.scenes.firstIndex(where: {$0.sceneId == scene.sceneId}) {
            MXHomeManager.shard.currentHome?.scenes[index] = scene
            MXHomeManager.shard.updateHomeList()
        } else if let index = MXHomeManager.shard.currentHome?.autoScenes.firstIndex(where: {$0.sceneId == scene.sceneId}) {
            MXHomeManager.shard.currentHome?.autoScenes[index] = scene
            MXHomeManager.shard.updateHomeList()
        }
    }
    
    func updateSceneDeviceStatus(device:MXDeviceInfo, scene: MXSceneInfo? = nil) {
        MXHomeManager.shard.currentHome?.scenes.forEach({ (scene_item:MXSceneInfo) in
            scene_item.actions.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo {
                    if params.objType == 0, params.isSameFrom(device) {
                        if  params.status != 3 {  
                            if let newScene = scene {
                                if scene_item.sceneId == newScene.sceneId {
                                    params.status = 1
                                }
                            } else {
                                params.status = 1
                            }
                        }
                    } else if params.objType == 1, var nodes = params.subDevices {  
                        nodes.forEach { (item:MXDeviceInfo) in
                            if item.isSameFrom(device) {
                                if  item.status != 3 {  
                                    if let newScene = scene {
                                        if scene_item.sceneId == newScene.sceneId {
                                            item.status = 1
                                        }
                                    } else {
                                        item.status = 1
                                    }
                                }
                            }
                        }
                        nodes.removeAll(where: {$0.status == 3 && $0.isSameFrom(device)})
                        params.subDevices = nodes
                    }
                    return
                }
            }
            scene_item.actions.removeAll { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo {
                    if params.objType == 0, params.isSameFrom(device), params.status == 3 {
                        return true
                    } else if params.objType == 1, let nodes = params.subDevices, nodes.count <= 0 {  
                        return true
                    }
                }
                return false
            }
        })
        MXHomeManager.shard.currentHome?.scenes.removeAll(where: {$0.actions.count == 0})
        MXHomeManager.shard.currentHome?.autoScenes.forEach({ (scene_item:MXSceneInfo) in
            scene_item.actions.forEach { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo {
                    if params.objType == 0, params.isSameFrom(device) {
                        if  params.status != 3 {  
                            if let newScene = scene {
                                if scene_item.sceneId == newScene.sceneId {
                                    params.status = 1
                                }
                            } else {
                                params.status = 1
                            }
                        }
                    } else if params.objType == 1, var nodes = params.subDevices {  
                        nodes.forEach { (item:MXDeviceInfo) in
                            if item.isSameFrom(device) {
                                if  item.status != 3 {  
                                    if let newScene = scene {
                                        if scene_item.sceneId == newScene.sceneId {
                                            item.status = 1
                                        }
                                    } else {
                                        item.status = 1
                                    }
                                }
                            }
                        }
                        nodes.removeAll(where: {$0.status == 3 && $0.isSameFrom(device)})
                        params.subDevices = nodes
                    }
                    return
                }
            }
            scene_item.actions.removeAll { (tac:MXSceneTACItem) in
                if let params = tac.params as? MXDeviceInfo {
                    if params.objType == 0, params.isSameFrom(device), params.status == 3 {
                        return true
                    } else if params.objType == 1, let nodes = params.subDevices, nodes.count <= 0 {  
                        return true
                    }
                }
                return false
            }
        })
        MXHomeManager.shard.currentHome?.autoScenes.removeAll(where: {$0.actions.count == 0})
        
    }
    
    
    
    static public func checkSceneIsInvalid(scene: MXSceneInfo) -> Bool {
        if let list = scene.conditions.items {
            for actionInfo in list {
                if let obj = actionInfo.params as? MXDeviceInfo, obj.objType == 0, !obj.isValid { 
                    return true
                }
            }
        }
        for actionInfo in scene.actions {
            if let obj = actionInfo.params as? MXDeviceInfo { 
                if obj.isValid {
                    return false
                }
            } else if let obj = actionInfo.params as? MXSceneInfo { 
                if obj.isValid {
                    return false
                }
            } else {  
                return false
            }
        }
        return true
    }
    
    
    static public func checkSceneHasUnsynchronized(scene: MXSceneInfo) -> Bool {
        
        for actionInfo in scene.actions {
            if let obj = actionInfo.params as? MXDeviceInfo { 
                if obj.objType == 0, !obj.isValid {
                    return true
                } else if obj.objType == 1, let nodes = obj.subDevices { 
                    for device in nodes {
                        if !device.isValid {
                            return true
                        }
                    }
                }
            } else if let obj = actionInfo.params as? MXSceneInfo, !obj.isValid { 
                return true
            }
        }
        
        if scene.type != "cloud_auto" { 
            for actionInfo in scene.actions {
                if let obj = actionInfo.params as? MXDeviceInfo { 
                    if obj.objType == 0 {  
                        if obj.status != 1 {
                            return true
                        }
                    } else if obj.objType == 1, let nodes = obj.subDevices {
                        for device in nodes {
                            if device.status != 1 {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    
    static public func createSceneActionDesc(item: MXSceneTACItem) -> NSAttributedString? {
        if let obj = item.params as? MXDeviceInfo, let objName = obj.name, let property_list = obj.properties, property_list.count > 0 {
            let desStr = NSMutableAttributedString()
            property_list.forEach { (property:MXPropertyInfo) in
                guard let type = property.dataType?.type, let pName = property.name else {
                    return
                }
                if type == "bool" || type == "enum" {
                    if let dataValue = property.value as? Int, let specsParams = property.dataType?.specs as? [String: String] {
                        let acitonStr = objName + "-" + pName + "-" + (specsParams[String(dataValue)] ?? "")
                        let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        desStr.append(des_str)
                    }
                } else if type == "struct" {
                    guard let dataValue = property.value as? [String:Int] else {
                        return
                    }
                    if let p_identifier = property.identifier, p_identifier == "HSVColor", let hValue = dataValue["Hue"], let sValue = dataValue["Saturation"], let vValue = dataValue["Value"] {
                        let nameStr = NSAttributedString(string: objName + "-" + pName, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        desStr.append(nameStr)
                        let valueStr = NSAttributedString(string: "\u{e72e}", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0),.baselineOffset:-4])
                        desStr.append(valueStr)
                    }
                } else {
                    if let p_identifier = property.identifier, p_identifier == "HSVColorHex", let dataValue = property.value as? Int32 {
                        let nameStr = NSAttributedString(string: objName + "-" + pName, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        desStr.append(nameStr)
                        let valueStr = NSAttributedString(string: "\u{e72e}", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:MXHSVColorHandle.colorFromHSVColor(value: dataValue),.baselineOffset:-4])
                        desStr.append(valueStr)
                    } else if let dataValue = property.value as? Int {
                        var compareType = property.compare_type
                        if compareType == "==" {
                            compareType = "-"
                        }
                        let acitonStr = objName + "-" + pName + compareType + String(dataValue)
                        let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        desStr.append(des_str)
                    } else if let dataValue = property.value as? Double {
                        var compareType = property.compare_type
                        if compareType == "==" {
                            compareType = "-"
                        }
                        var floatNum = 0
                        if let stepStr = property.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                            if step < 0.1 {
                                floatNum = 2
                            } else if step < 1 {
                                floatNum = 1
                            }
                        }
                        let acitonStr = objName + "-" + pName + compareType + String(format: "%.\(floatNum)f", dataValue) + " "
                        let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        desStr.append(des_str)
                    }
                }
                let spaceStr = NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                desStr.append(spaceStr)
            }
            return desStr
        } else if let obj = item.params as? MXSceneInfo, let objName = obj.name, obj.sceneId > 0  {  
            let acitonStr = localized(key:"执行") + " " + objName + " "
            let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
            return des_str
        } else if let obj = item.params as? MXSceneInfo, let objName = obj.name, obj.sceneId > 0  {  
            let acitonStr = (obj.enable ? localized(key:"开启") : localized(key:"关闭")) + " " + objName + " "
            let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
            return des_str
        } else if let obj = item.params as? [String: String], let msgStr = obj["message"], msgStr.count > 0  {  
            let acitonStr = localized(key:"发送通知") + "-" + msgStr + " "
            let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
            return des_str
        }
        return nil
    }
    
    
    static public func checkSceneDeviceIsInvalid(scene: MXSceneInfo) -> Bool {
        for actionInfo in scene.actions {
            if let obj = actionInfo.params as? MXDeviceInfo { 
                if !obj.isValid {
                    return true
                } else if obj.objType == 1, let nodes = obj.subDevices {
                    for device in nodes {
                        if !device.isValid {
                            return true
                        }
                    }
                }
            } else if let obj = actionInfo.params as? MXSceneInfo, !obj.isValid { 
                return true
            }
        }
        return false
    }
    
    
    static public func checkSceneConditionDeviceIsInvalid(scene: MXSceneInfo) -> Bool {
        guard let list = scene.conditions.items else {
            return false
        }
        
        for actionInfo in list {
            if let obj = actionInfo.params as? MXDeviceInfo, !obj.isValid { 
                return true
            }
        }
        return false
    }
    
    
    func didActionScene(scene: MXSceneInfo) {
        
        guard MeshSDK.sharedInstance.isConnected(), let nk = MXHomeManager.shard.currentHome?.networkKey  else {  
            return
        }
        
        if scene.isInvalid {  
            return
        }
        
        var devicList = [MXDeviceInfo]()  
        
        for actionInfo in scene.actions { 
            if let obj = actionInfo.params as? MXDeviceInfo {
                if obj.objType == 0, obj.status != 1, obj.status != 3, let property_list = obj.properties, obj.isValid {
                    let device = MXDeviceInfo()
                    device.meshInfo = obj.meshInfo
                    device.properties = property_list
                    devicList.append(device)
                } else if obj.objType == 1, let nodes = obj.subDevices, let property_list = obj.properties, obj.isValid {
                    nodes.forEach({ (device:MXDeviceInfo) in
                        if device.status != 1,
                           device.status != 3 {//群组存在未写入的设备
                            let device = MXDeviceInfo()
                            device.meshInfo = obj.meshInfo
                            device.properties = property_list
                            devicList.append(device)
                            return
                        }
                    })
                }
            }
        }
        
        MeshSDK.sharedInstance.triggerVirtualButton(vid: String(format: "%02lX", scene.vid), networkKey:nk , repeatNum: 3)
        
        for device in devicList {  
            
            if let propertyList = device.properties {
                var params = [String : Any]()
                propertyList.forEach { (item:MXPropertyInfo) in
                    if let pName = item.identifier, let pValue = item.value {
                        params[pName] = pValue
                    }
                }
                var attrStr = String()
                for identifier_name in params.keys {
                    if let property_value = params[identifier_name],
                        let msgHex = MXMeshMessageHandle.properiesToMessageHex(identifier: identifier_name, value: property_value) {
                        attrStr.append(msgHex)
                    }
                }
                if let uuidStr = device.meshInfo?.uuid, uuidStr.count > 0 {  
                    MeshSDK.sharedInstance.sendMeshMessage(opCode: "12", uuid: uuidStr, message: attrStr, callback: nil)
                } else if let meshAddress = device.meshInfo?.meshAddress {
                    let mesh_address = String(format: "%04X", meshAddress)
                    MeshSDK.sharedInstance.sendMessage(address: mesh_address, opCode: "12", message: attrStr, networkKey: nk, repeatNum: 2)
                }
                
            }
        }
    }
}

extension MXSceneManager {
    
    func filterNeedWriteRuleDevice(scene:MXSceneInfo?, oldScene:MXSceneInfo?) -> [MXDeviceInfo]  {
        
        var devices = [MXDeviceInfo]()
        scene?.actions.forEach { (item:MXSceneTACItem) in
            if let params = item.params as?  MXDeviceInfo, params.status != 1 {
                if params.isValid, params.objType == 0 { 
                    if devices.first(where: {$0.isSameFrom(params)}) == nil {
                        params.writtenStatus = 0
                        devices.append(params)
                    }
                } else if params.objType == 1, let nodes = params.subDevices {  
                    nodes.forEach { (node:MXDeviceInfo) in
                        if node.status != 1, devices.first(where: {$0.isSameFrom(params)}) == nil {
                            devices.append(node)
                        }
                    }
                }
            }
        }
        
        oldScene?.actions.forEach { (item:MXSceneTACItem) in
            if let params = item.params as? MXDeviceInfo, scene?.actions.first(where: { (tca:MXSceneTACItem) in
                if let newParams = tca.params as? MXDeviceInfo, newParams.isSameFrom(params) {
                    return true
                }
                return false
            }) == nil {
                if params.isValid, params.objType == 0 { 
                    if devices.first(where: {$0.isSameFrom(params)}) == nil {
                        devices.append(params)
                    }
                } else if params.objType == 1, let nodes = params.subDevices {  
                    nodes.forEach { (node:MXDeviceInfo) in
                        if devices.first(where: {$0.isSameFrom(params)}) == nil {
                            devices.append(node)
                        }
                    }
                }
            }
        }
        return devices
    }
    
    public func showSyncSettingView(devices:[MXDeviceInfo], scene:MXSceneInfo? = nil, handler:@escaping (_ isFinish: Bool) -> Void) {
        
        devices.forEach { (item:MXDeviceInfo) in
            item.writtenStatus = 0
        }
        self.needWrittenDeviceList = devices
        self.currenWrittenIndex = 0
        self.currentScene = scene
        if self.needWrittenDeviceList.count > 0 {
            self.deviceWrittenView.isGroupSetting = false
            self.deviceWrittenView.dataList = self.needWrittenDeviceList
            self.deviceWrittenView.sureActionCallback = {
                handler(true)
            }
            self.deviceWrittenView.retryCallback = { [weak self] in
                if let newList = self?.needWrittenDeviceList.filter({$0.writtenStatus == 3}) {
                    newList.forEach { (info:MXDeviceInfo) in
                        info.writtenStatus = 0
                    }
                    self?.showSyncSettingView(devices: newList, scene: self?.currentScene, handler: handler)
                }
            }
            self.deviceWrittenView.show()
            self.updateSceneRule()
        } else {
            handler(true)
        }
    }
    
    
    func updateSceneRule() {
        guard self.needWrittenDeviceList.count > self.currenWrittenIndex else {
            self.deviceWrittenView.isFinish = true
            self.needWrittenDeviceList.forEach { (device:MXDeviceInfo) in
                if device.writtenStatus == 2 { 
                    self.updateSceneDeviceStatus(device: device, scene: self.currentScene)
                }
            }
            MXHomeManager.shard.updateHomeList()
            return
        }
        
        let info = self.needWrittenDeviceList[self.currenWrittenIndex]
        info.writtenStatus = 1
        self.deviceWrittenView.updateWrittenStatus()
        if let uuidStr = info.meshInfo?.uuid, uuidStr.count > 0 {
            self.getDeviceRuleInfo(device: info, scene: self.currentScene) { rules in
                if let rule_list = rules {
                    self.writeRuleToDevice(uuid: uuidStr, rules: rule_list) { isSuccess in
                        info.writtenStatus = isSuccess ? 2 : 3
                        self.deviceWrittenView.updateWrittenStatus()
                        self.currenWrittenIndex += 1
                        self.updateSceneRule()
                    }
                } else {
                    info.writtenStatus = 2
                    self.deviceWrittenView.updateWrittenStatus()
                    self.currenWrittenIndex += 1
                    self.updateSceneRule()
                }
            }
        } else {
            info.writtenStatus = 2
            self.deviceWrittenView.updateWrittenStatus()
            self.currenWrittenIndex += 1
            self.updateSceneRule()
        }
    }
    
    
    func getDeviceRuleInfo(device: MXDeviceInfo, scene: MXSceneInfo? = nil, handler:@escaping (_ rules:[Int: String]?) -> Void) {
        var ruleParams = [Int:String]()
        MXHomeManager.shard.currentHome?.scenes.forEach({ (scene_item:MXSceneInfo) in
            scene_item.actions.forEach { (item:MXSceneTACItem) in
                if let params = item.params as? MXDeviceInfo, let pList = params.properties {
                    if params.objType == 0, params.isSameFrom(device) {
                        if params.status != 3 {
                            if let newScene = scene {  
                                if scene_item.sceneId == newScene.sceneId {
                                    let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                    ruleParams[scene_item.vid] = ruleStr
                                }
                            } else {
                                let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                ruleParams[scene_item.vid] = ruleStr
                            }
                        } else {
                            if scene != nil {
                                ruleParams[scene_item.vid] = ""
                            }
                        }
                        return
                    } else if params.objType == 1, let nodes = params.subDevices {
                        for node in nodes {
                            if node.isSameFrom(device) {
                                if node.status != 3 {
                                    if let newScene = scene {  
                                        if scene_item.sceneId == newScene.sceneId {
                                            let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                            ruleParams[scene_item.vid] = ruleStr
                                        }
                                    } else {
                                        let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                        ruleParams[scene_item.vid] = ruleStr
                                    }
                                } else {
                                    if scene != nil {
                                        ruleParams[scene_item.vid] = ""
                                    }
                                }
                                return
                            }
                        }
                    }
                }
            }
        })
        MXHomeManager.shard.currentHome?.autoScenes.forEach({ (scene_item:MXSceneInfo) in
            scene_item.actions.forEach { (item:MXSceneTACItem) in
                if let params = item.params as? MXDeviceInfo, let pList = params.properties {
                    if params.objType == 0, params.isSameFrom(device) {
                        if params.status != 3 {
                            if let newScene = scene {  
                                if scene_item.sceneId == newScene.sceneId {
                                    let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                    ruleParams[scene_item.vid] = ruleStr
                                }
                            } else {
                                let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                ruleParams[scene_item.vid] = ruleStr
                            }
                        } else {
                            if scene != nil {
                                ruleParams[scene_item.vid] = ""
                            }
                        }
                        return
                    } else if params.objType == 1, let nodes = params.subDevices {
                        for node in nodes {
                            if node.isSameFrom(device) {
                                if node.status != 3 {
                                    if let newScene = scene {  
                                        if scene_item.sceneId == newScene.sceneId {
                                            let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                            ruleParams[scene_item.vid] = ruleStr
                                        }
                                    } else {
                                        let ruleStr = self.createRule(scene: scene_item, properties: pList)
                                        ruleParams[scene_item.vid] = ruleStr
                                    }
                                } else {
                                    if scene != nil {
                                        ruleParams[scene_item.vid] = ""
                                    }
                                }
                                return
                            }
                        }
                    }
                }
            }
        })
        handler(ruleParams)
    }
    
    
    func writeRuleToDevice(uuid: String, rules: [Int:String], handler:@escaping (_ isSuccess: Bool) -> Void) {
        
        var ruleParams: [Int:String] = rules
        if ruleParams.keys.count > 0, let ruleId = ruleParams.keys.first { 
            if let ruleStr: String = ruleParams[ruleId] {
                if MeshSDK.sharedInstance.isConnected() {
                    print("给设备写入的规则：\(ruleStr)")
                    MeshSDK.sharedInstance.writeRules(uuid: uuid, ruleId: ruleId, rule: ruleStr) { (isSuccess:Bool) in
                        if isSuccess {
                            print("写入成功")
                            ruleParams.removeValue(forKey: ruleId)
                            
                            self.writeRuleToDevice(uuid: uuid, rules: ruleParams, handler: handler)
                            return
                        } else {
                            
                            handler(false)
                        }
                    }
                } else { 
                    handler(false)
                }
            } else {  
                ruleParams.removeValue(forKey: ruleId)
                self.writeRuleToDevice(uuid: uuid, rules: ruleParams, handler: handler)
                return
            }
        } else {  
            handler(true)
        }
    }
    
    func createRule(scene:MXSceneInfo, properties:[MXPropertyInfo]) -> String {
        var ruleStr: String = ""
        var actionRuleHex = ""
        properties.forEach({ (pInfo:MXPropertyInfo) in
            if let identifier = pInfo.identifier,
               let value = pInfo.value,
               let pHex = MXMeshMessageHandle.properiesToMessageHex(identifier: identifier, value: value) {
                actionRuleHex += pHex
            }
        })
        
        if actionRuleHex.count <= 0 {
            return ruleStr
        }
        
        if scene.type == "one_click" {
            ruleStr = "FFFF".littleEndian + "0007".littleEndian + String(format: "%02X", scene.vid) + actionRuleHex
        } else {
            if let trigger = scene.conditions.items?.first(where: { $0.params is MXDeviceInfo}),
               let triggerDevice = trigger.params as? MXDeviceInfo {
                var triggerHex = ""
                triggerDevice.properties?.forEach({ (pInfo:MXPropertyInfo) in
                    if let identifier = pInfo.identifier,
                       let value = pInfo.value,
                       let pHex = MXMeshMessageHandle.properiesToMessageHex(identifier: identifier, value: value) {
                        triggerHex += pHex
                    }
                })
                if let triggerAddress = triggerDevice.meshInfo?.meshAddress, triggerHex.count > 0 {
                    ruleStr = String(format: "%04X", triggerAddress).littleEndian + triggerHex + actionRuleHex
                }
            }
        }
        
        return ruleStr
    }
}

extension MXSceneManager {
    
    
    func loadMXTemplateData() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXLightTemplateData.json")
        if let data = try? Data(contentsOf: url) {
            if let params = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [[String : Any]],
                let list = MXSceneTemplateInfo.mx_Decode(params) {
                self.lightTemplateList = list
            }
        }
    }
    
    public func updateLightTemplateList() {
        var list = [[String: Any]]()
        self.lightTemplateList.forEach { (home:MXSceneTemplateInfo) in
            if let params = MXSceneTemplateInfo.mx_keyValue(home) {
                list.append(params)
            }
        }
        self.updateMXTemplateData(params: list)
    }
    
    
    public func updateMXTemplateData(params: [[String : Any]]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXLightTemplateData.json")
        if let data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
            try? data.write(to: url)
        }
    }
}
