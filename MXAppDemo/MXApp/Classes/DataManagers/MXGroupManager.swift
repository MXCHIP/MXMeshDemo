
import Foundation


class MXGroupManager: NSObject {
    
    static let shared = MXGroupManager()
    
    var groupInfo = MXDeviceInfo()
    var devices = [MXDeviceInfo]()
    
    var needWrittenDeviceList = [MXDeviceInfo]()
    var currenWrittenIndex: Int = 0
    let deviceWrittenView: MXSceneDeviceStatusView = MXSceneDeviceStatusView.shard
    
    func loadAllGroupList() -> [MXDeviceInfo] {
        var list = [MXDeviceInfo]()
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            let groupList = room.devices.filter({$0.objType == 1})
            list.append(contentsOf: groupList)
        })
        
        return list
    }
    
    func getNextAvailableGroupAddress() -> UInt16 {
        var last_address: UInt16 = 0xC000
        let cacheAddress = UserDefaults.standard.integer(forKey: "MXNextAvailableGroupMeshAddress")
        if UInt16(cacheAddress) > last_address {
            last_address = UInt16(cacheAddress)
        }
        if let last = self.loadAllGroupList().max(by: {($0.meshInfo?.meshAddress ?? 0) < ($1.meshInfo?.meshAddress ?? 0)}) {
            if (last.meshInfo?.meshAddress ?? 0) >= last_address {
                last_address = (last.meshInfo?.meshAddress ?? 0xC000) + 1
            }
        }
        if last_address >= 0xCFFF {
            for i in 0xC000 ..< 0xCFFF {
                if  self.loadAllGroupList().first(where: {($0.meshInfo?.meshAddress ?? 0) == i}) == nil {
                    last_address = UInt16(i)
                    break
                }
            }
        }
        UserDefaults.standard.set(last_address + 1, forKey: "MXNextAvailableGroupMeshAddress")
        return last_address
    }
    
    
    func update(with groupInfo: MXDeviceInfo,
                devices: [MXDeviceInfo],
                handle: @escaping (_ list: [MXDeviceInfo]) -> Void) {
        if groupInfo.meshInfo?.meshAddress == nil {
            var mesh_info = MXMeshInfo()
            mesh_info.meshAddress = self.getNextAvailableGroupAddress()
            groupInfo.meshInfo = mesh_info
            groupInfo.createTime = Int(NSDate().timeIntervalSince1970)
            groupInfo.subDevices?.removeAll()
        }
        
        self.groupInfo = groupInfo
        self.devices = devices
        
        var written_devices = [MXDeviceInfo]()
        if let list = groupInfo.subDevices {
            let add_list = devices.filter { (info: MXDeviceInfo) in
                return list.first(where: {$0.isSameFrom(info)}) == nil
            }
            written_devices.append(contentsOf: add_list)
            let remove_list = list.filter{ (info: MXDeviceInfo) in
                return devices.first(where: {$0.isSameFrom(info)}) == nil
            }
            remove_list.forEach { (info: MXDeviceInfo) in
                info.isIntoGroup = false
            }
            written_devices.append(contentsOf: remove_list)
        } else {
            written_devices.append(contentsOf: devices)
        }
        
        written_devices.forEach { (device:MXDeviceInfo) in
            device.writtenStatus = 0
        }
        self.showRuleWrittenView(list: written_devices, handle: handle)
    }
    
    func showRuleWrittenView(list: [MXDeviceInfo], handle: @escaping (_ list: [MXDeviceInfo]) -> Void) {
        self.needWrittenDeviceList = list
        self.currenWrittenIndex = 0
        if self.needWrittenDeviceList.count > 0 {
            self.deviceWrittenView.dataList = self.needWrittenDeviceList
            self.deviceWrittenView.isGroupSetting = true
            self.deviceWrittenView.sureActionCallback = {
                
                let failList = self.needWrittenDeviceList.filter({$0.writtenStatus == 3})
                failList.forEach { (device:MXDeviceInfo) in
                    if device.isIntoGroup {
                        self.devices.removeAll(where: {$0.isSameFrom(device)})
                    } else {
                        self.devices.append(device)
                    }
                }
                handle(self.devices)
            }
            self.deviceWrittenView.retryCallback = { [weak self] in
                if let newList = self?.needWrittenDeviceList.filter({$0.writtenStatus == 3}) {
                    newList.forEach { (info:MXDeviceInfo) in
                        info.writtenStatus = 0
                    }
                    self?.showRuleWrittenView(list: newList, handle: handle)
                }
                
            }
            self.deviceWrittenView.show()
            self.fetchGroupToDevice()
        } else {
            handle(self.devices)
        }
    }

    
    func fetchGroupToDevice() {

        guard self.needWrittenDeviceList.count > self.currenWrittenIndex else {
            self.deviceWrittenView.isFinish = true
            return
        }
        let info = self.needWrittenDeviceList[self.currenWrittenIndex]
        info.writtenStatus = 1
        self.deviceWrittenView.updateWrittenStatus()
        if let uuidStr = info.meshInfo?.uuid, uuidStr.count > 0, let address = self.groupInfo.meshInfo?.meshAddress, MeshSDK.sharedInstance.isConnected() {
            let group_address = String(format: "%04X", address)
            let groupInfo:[String : Any] = ["address":group_address,"service":0, "isMaster":false]
            let groups:[[String : Any]] = [groupInfo]
            if info.isIntoGroup {
                MeshSDK.sharedInstance.resetDeviceGroupSetting(uuid: uuidStr, groups: groups) { (isSuccess: Bool) in
                    info.writtenStatus = isSuccess ? 2 : 3
                    self.deviceWrittenView.updateWrittenStatus()
                    
                    self.currenWrittenIndex += 1
                    self.fetchGroupToDevice()
                }
            } else {
                MeshSDK.sharedInstance.resetDeviceGroupSetting(uuid: uuidStr) { (isSuccess: Bool) in
                    info.writtenStatus = isSuccess ? 2 : 3
                    self.deviceWrittenView.updateWrittenStatus()
                    
                    self.currenWrittenIndex += 1
                    self.fetchGroupToDevice()
                }
            }
        } else {
            info.writtenStatus = 3
            self.deviceWrittenView.updateWrittenStatus()
            
            self.currenWrittenIndex += 1
            self.fetchGroupToDevice()
        }
    }
    
}
