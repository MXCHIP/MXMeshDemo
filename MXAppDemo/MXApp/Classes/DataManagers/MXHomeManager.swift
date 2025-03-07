
import Foundation
import MeshSDK

class MXHomeManager: NSObject {
    public static var shard = MXHomeManager()
    var addProxyFilterNum: Int = 0
    var workItem : DispatchWorkItem?
    public var homeList = Array<MXHomeInfo>()
    
    public var currentHome : MXHomeInfo? = nil {
        didSet {
            if self.currentHome == nil {
                return
            }
            
            if let isCurrent = self.currentHome?.isCurrent, !isCurrent {
                self.homeList.forEach { (home:MXHomeInfo) in
                    home.isCurrent = false
                }
                self.currentHome?.isCurrent = true
                self.updateHomeList()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
            self.resetMeshNetwork()
        }
    }
    
    public var isShowBleConnectStatus: Bool {
        get {
            if MXDeviceManager.shard.loadDevices(roomId: 0, type: 3).count > 0 {
                return !MeshSDK.sharedInstance.isConnected()
            } else {
                return false
            }
        }
    }
    
    override init() {
        super.init()
        self.loadMXHomeData()
        self.refreshCurrentHome()
        MeshSDK.sharedInstance.delegate = self
        self.loadMeshAttrTypeMap()
    }
    
    public func refreshCurrentHome() {
        if self.homeList.count > 0 {
            if let info = self.homeList.first(where: {$0.isCurrent}) {
                self.currentHome = info
            } else {
                self.currentHome = self.homeList.first
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
            self.resetMeshNetwork()
        } else {
            self.createHome(name: localized(key: "我的家"), rooms: [localized(key: "默认房间")])
        }
    }
    
    
    func loadMeshAttrTypeMap() {
        MXResourcesManager.loadLocalConfigFileUrl(name: "MXMeshAttrMap") { (filePath:String?) in
            if let path = filePath {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url) {
                    if let params = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, Any> {
                        MXMeshMessageHandle.shard.updateTranscodingMapping(data: params as NSDictionary)
                    }
                }
            }
        }
    }
    
    func subscribeMeshGroupAddress(handler:@escaping (Bool) -> Void) {
        //订阅组播地址
        self.addProxyFilterNum -= 1;
        MeshSDK.sharedInstance.subscribeMeshProxyFilter(address: 0xD003)
        
        self.workItem?.cancel()
        self.workItem = nil
        self.workItem = DispatchWorkItem { [weak self] in
            if MeshSDK.sharedInstance.meshNetworkManager.proxyFilter.addresses.contains(0xD003) {
                handler(true)
            } else {
                if let num = self?.addProxyFilterNum, num > 0 {
                    self?.subscribeMeshGroupAddress(handler: handler)
                    return
                }
                handler(false)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: self.workItem!)
    }
    
    func resetMeshNetwork() {
        MeshSDK.sharedInstance.disconnect()
        var params = [String : Any]()
        var netkeyParams = [String : Any]()
        var appKeyParams = [String: Any]()
        if let nk = self.currentHome?.networkKey, let ak = self.currentHome?.appKey {
            netkeyParams["key"] = nk
            netkeyParams["appKeys"] = [ak]
            
            appKeyParams["key"] = ak
            appKeyParams["netKey"] = nk
        }
        params["netKeys"] = [netkeyParams]
        var nodesParams = [[String: Any]]()
        self.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            room.devices.forEach { (device:MXDeviceInfo) in
                if device.objType == 0 {
                    if let meshInfo = device.meshInfo,
                       let address = meshInfo.meshAddress,
                       let uuidStr = meshInfo.uuid,
                       let deviceKey = meshInfo.deviceKey {
                        var meshParams = [String: Any]()
                        meshParams["appKeys"] = [appKeyParams]
                        meshParams["UUID"] = uuidStr
                        meshParams["unicastAddress"] = String(format: "%04X", address)
                        meshParams["deviceKey"] = deviceKey
                        nodesParams.append(meshParams)
                    }
                } else if device.objType == 1, let subList = device.subDevices {
                    subList.forEach { (item:MXDeviceInfo) in
                        if let meshInfo = item.meshInfo,
                           let address = meshInfo.meshAddress,
                           let uuidStr = meshInfo.uuid,
                           let deviceKey = meshInfo.deviceKey {
                            var meshParams = [String: Any]()
                            meshParams["appKeys"] = [appKeyParams]
                            meshParams["UUID"] = uuidStr
                            meshParams["unicastAddress"] = String(format: "%04X", address)
                            meshParams["deviceKey"] = deviceKey
                            nodesParams.append(meshParams)
                        }
                    }
                }
            }
        })
        params["nodes"] = nodesParams
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed), let jsonStr = String(data: jsonData, encoding: .utf8) {
            MeshSDK.sharedInstance.importMeshNetworkConfig(jsonString: jsonStr) { (isSuccess:Bool) in
                MeshSDK.sharedInstance.resetProvisionerUnicastAddress(address: UInt16(0x0001))
                if let currentNK = self.currentHome?.networkKey {
                    MeshSDK.sharedInstance.disconnect()
                    if !MeshSDK.sharedInstance.isNetworkKeyExists(networkKey: currentNK) {
                        _ = MeshSDK.sharedInstance.createNetworkKey(key: currentNK, appKey: self.currentHome?.appKey)
                    }
                    MeshSDK.sharedInstance.setCurrentNetworkKey(key: currentNK)
                    if let seqNum = self.currentHome?.seqNumber {
                        MeshSDK.sharedInstance.setMeshNetworkSequence(seq: UInt32(seqNum + 200), updateInterval: 50)
                        self.currentHome?.seqNumber = seqNum + 200
                        self.updateHomeList()
                    } else {
                        var seq = MeshSDK.sharedInstance.getMeshNetworkSequence()
                        MeshSDK.sharedInstance.setMeshNetworkSequence(seq: seq + 200, updateInterval: 50)
                        self.currentHome?.seqNumber = Int(seq) + 200
                        self.updateHomeList()
                    }
                    MeshSDK.sharedInstance.connect()
                }
            }
        }
    }
    
}

extension MXHomeManager {
    
    func createHomeId() -> Int {
        var home_id = 1
        if let last = self.homeList.max(by: {$0.homeId < $1.homeId}), last.homeId >= home_id {
            home_id = last.homeId + 1
        }
        return home_id
    }
    
    func createRoomId(homeId:Int) -> Int {
        var room_id = 1
        if let last = self.homeList.first(where: {$0.homeId == homeId})?.rooms.max(by: {$0.roomId < $1.roomId}), last.roomId >= room_id {
            room_id = last.roomId + 1
        }
        return room_id
    }
    
    func createRandom() -> String? {
        var buffer = [UInt8](repeating: 0, count: 16)
        let status = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        if status == errSecSuccess  {
            return Data(buffer).toHexString()
        }
        return nil
    }
    
    func createHome(name:String, rooms:[String]) {
        let newHome = MXHomeInfo()
        newHome.homeId = self.createHomeId()
        newHome.networkKey = self.createRandom()
        newHome.appKey = self.createRandom()
        newHome.meshAddress = 0x0001
        newHome.seqNumber = 0
        newHome.name = name
        self.homeList.append(newHome)
        
        for i in 0 ..< rooms.count {
            let newRoom = self.createRoom(homeId: newHome.homeId, name: rooms[i])
            newRoom.isDefault = (i == 0)
            newHome.rooms.append(newRoom)
        }
        if newHome.homeId == 1 {  
            newHome.isCurrent = true
            self.currentHome = newHome
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
            self.resetMeshNetwork()
        } else {
            let alert = MXAlertView(title: localized(key: "加入新家庭"), message: localized(key: "你加入了新家庭，是否切换到新家庭？"), leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) {
                
            } rightButtonCallBack: {
                self.currentHome = newHome
            }
            alert.show()
        }
        self.updateHomeList()
    }
    
    func createRoom(homeId: Int, name:String) -> MXRoomInfo {
        let newRoom = MXRoomInfo()
        newRoom.roomId =  self.createRoomId(homeId: homeId)
        newRoom.name = name
        return newRoom
    }
     
    
    func getNextAvailableVid() -> Int {
        var last_vid = 1
        let cache_vid = UserDefaults.standard.integer(forKey: "MXNextAvailableVid")
        if cache_vid > last_vid {
            last_vid = cache_vid
        }
        if let last = MXHomeManager.shard.currentHome?.scenes.max(by: {$0.vid < $1.vid}) {
            if last.vid >= last_vid {
                last_vid = last.vid + 1
            }
        }
        if let last = MXHomeManager.shard.currentHome?.autoScenes.max(by: {$0.vid < $1.vid}) {
            if last.vid >= last_vid {
                last_vid = last.vid + 1
            }
        }
        if last_vid >= 255 {
            for i in 1 ..< 255 {
                if MXHomeManager.shard.currentHome?.scenes.first(where: {$0.isValid && $0.vid == i}) == nil, MXHomeManager.shard.currentHome?.autoScenes.first(where: {$0.isValid && $0.vid == i}) == nil {
                    last_vid = i
                    break
                }
            }
        }
        UserDefaults.standard.set(last_vid + 1, forKey: "MXNextAvailableVid")
        return last_vid
    }
    
    func replaceDeviceUpdate(replaceDevice:MXDeviceInfo?, newDevice:MXDeviceInfo?) {
        
        guard let newDevice = newDevice, let replaceDevice = replaceDevice else {
            return
        }
        self.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            for device in room.devices {
                if device.objType == 0, device.isSameFrom(replaceDevice) {
                    device.meshInfo = newDevice.meshInfo
                    device.bindTime = newDevice.bindTime
                    device.firmware_version = newDevice.firmware_version
                    return
                } else if device.objType == 1, let nodes = device.subDevices {
                    nodes.forEach { (node:MXDeviceInfo) in
                        if node.isSameFrom(replaceDevice) {
                            node.meshInfo = newDevice.meshInfo
                            node.bindTime = newDevice.bindTime
                            node.firmware_version = newDevice.firmware_version
                        }
                    }
                }
            }
        })
        self.currentHome?.scenes.forEach({ (scene:MXSceneInfo) in
            scene.actions.forEach { (tac:MXSceneTACItem) in
                if let device = tac.params as? MXDeviceInfo {
                    if device.objType == 0, device.isSameFrom(replaceDevice) {
                        device.meshInfo = newDevice.meshInfo
                        device.bindTime = newDevice.bindTime
                        device.status = 1
                    } else if device.objType == 1, let nodes = device.subDevices {
                        nodes.forEach { (node:MXDeviceInfo) in
                            if node.isSameFrom(replaceDevice) {
                                node.meshInfo = newDevice.meshInfo
                                node.bindTime = newDevice.bindTime
                                node.status = 1
                            }
                        }
                    }
                }
            }
        })
        
        self.currentHome?.autoScenes.forEach({ (scene:MXSceneInfo) in
            scene.conditions.items?.forEach { (tac:MXSceneTACItem) in
                if let device = tac.params as? MXDeviceInfo {
                    if device.objType == 0, device.isSameFrom(replaceDevice) {
                        device.meshInfo = newDevice.meshInfo
                        device.bindTime = newDevice.bindTime
                    }
                }
            }
            scene.actions.forEach { (tac:MXSceneTACItem) in
                if let device = tac.params as? MXDeviceInfo {
                    if device.objType == 0,device.isSameFrom(replaceDevice) {
                        device.meshInfo = newDevice.meshInfo
                        device.bindTime = newDevice.bindTime
                        device.status = 1
                    } else if device.objType == 1, let nodes = device.subDevices {
                        nodes.forEach { (node:MXDeviceInfo) in
                            if node.isSameFrom(replaceDevice) {
                                node.meshInfo = newDevice.meshInfo
                                node.bindTime = newDevice.bindTime
                                node.status = 1
                            }
                        }
                    }
                }
            }
        })
        self.updateHomeList()
    }
}

extension MXHomeManager {
    
    func loadMXHomeData() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXHomeData.json")
        if let data = try? Data(contentsOf: url) {
            if let params = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [[String : Any]],
                let list = MXHomeInfo.mx_Decode(params) {
                self.homeList = list
            }
        }
    }
    
    public func updateHomeList() {
        var home_list = [[String: Any]]()
        self.homeList.forEach { (home:MXHomeInfo) in
            if let params = MXHomeInfo.mx_keyValue(home) {
                home_list.append(params)
            }
        }
        self.updateMXHomeData(params: home_list)
    }
    
    
    public func updateMXHomeData(params: [[String : Any]]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXHomeData.json")
        if let data = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
            try? data.write(to: url)
        }
    }
}

extension MXHomeManager {
    
    func operationAuthorityCheck(_ isShowAlert: Bool = true) -> Bool {
        if let homeRole = self.currentHome?.role, homeRole < 2 {
            return true
        }
        if isShowAlert {
            MXHomeManager.showNoAuthorityAlert()
        }
        return false
    }
    
    static public func showNoAuthorityAlert(_ msg :String? = nil) {
        var alertMsg = localized(key:"普通成员没有权限描述")
        if let m = msg {
            alertMsg = m
        }
        let alert = MXAlertView(title: localized(key:"提示"), message: alertMsg, confirmButtonTitle: localized(key:"确定")) {
            
        }
        alert.show()
    }
    
    func ownerAuthorityCheck(_ isShowAlert: Bool = true) -> Bool {
        if let homeRole = self.currentHome?.role, homeRole == 0 {
            return true
        }
        if isShowAlert {
            MXHomeManager.showOwnerAuthorityAlert()
        }
        return false
    }
    
    static public func showOwnerAuthorityAlert() {
        let alertMsg = localized(key:"管理员没有权限描述")
        let alert = MXAlertView(title: localized(key:"提示"), message: alertMsg, confirmButtonTitle: localized(key:"确定")) {
            
        }
        alert.show()
    }
}

extension MXHomeManager : MXMeshDelegate {
    
    func meshConnectChange(status: Int) {
        if MeshSDK.sharedInstance.isConnected() {
            if status == 2 {
                return
            }
            self.addProxyFilterNum = 2
            self.subscribeMeshGroupAddress { (isSuccess: Bool) in
                if isSuccess {
                    //清除mesh缓存，避免控制状态不同步的问题
                    MeshSDK.sharedInstance.initDeviceCache()
                    NotificationCenter.default.post(name: NSNotification.Name("kMeshConnectStatusChange"), object: nil)
                } else {
                    MeshSDK.sharedInstance.disconnect()
                    MeshSDK.sharedInstance.connect()
                }
            }
        } else {
            self.workItem?.cancel()
            self.workItem = nil
            NotificationCenter.default.post(name: NSNotification.Name("kMeshConnectStatusChange"), object: nil)
        }
    }
    
    func meshNetworkIvIndexUpdate(index: Int) {
        
    }
    
    func provisionerSequenceUpdate(seq: Int) {
        
    }
    
    func deviceStatusUpdate(uuid: String, status: Int) {
        NotificationCenter.default.post(name: NSNotification.Name("kDeviceLocateStatusChange"), object: uuid)
    }
    
    func deviceCacheInvalid(uuid: String) {
        NotificationCenter.default.post(name: NSNotification.Name("kDevicePropertyCacheInvalidFromLocate"), object: uuid)
    }
    
    func receiveMeshMessage(uuid: String, elementIndex: Int, message: String) {
        let result = [uuid: ["code":0, "message":message, "elemnetIndex": elementIndex]]
        let properyParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: message)
        
        MeshSDK.sharedInstance.updateDeviceStatusCache(uuid: uuid, properties: properyParams)
        NotificationCenter.default.post(name: NSNotification.Name("kDevicePropertyChangeFromLocate"), object: result)
    }
}

