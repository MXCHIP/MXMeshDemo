
import Foundation
import UIKit
import MeshSDK
import CoreBluetooth

class MXAddDeviceStepViewController: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String?
    public var deviceList = [MXProvisionDeviceInfo]()
    let provisionQueueMax: Int = MXAppPageConfig.shard.Provisioning_Batch_ParallelNum
    public var wifiSSID : String?
    public var wifiPassword : String?
    
    var successNum = 0
    var failNum = 0
    
    var roomId: Int?
    
    var nextAddress: Int = 0x0101
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"添加设备")
        
        self.nextAddress = Int(MeshSDK.sharedInstance.getNextUnicastAddress())
        
        for item in self.deviceList {
            self.createProvisionSteps(device: item)
        }
        
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left(10).right(10).top().height(50)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.headerView).marginTop(0).left(10).right(10).bottom()
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.bottomView.isHidden = true
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
        self.startProvisionDevice()
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        MXMeshProvisionManager.shared.mxProvisionFinish()
        MeshSDK.sharedInstance.connect()
        print("页面释放了")
    }
    
    override func gotoBack() {
        if self.bottomView.isHidden {  
            let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"当前还有设备正在配网中，是否确定返回？"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
                
            } rightButtonCallBack: {
                MXMeshProvisionManager.shared.mxProvisionFinish()
                MeshSDK.sharedInstance.disconnect()
                MeshSDK.sharedInstance.connect()
                
                MXHomeManager.shard.updateHomeList()
                
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.show()
            return
        }
        MeshSDK.sharedInstance.connect()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.pin.left(10).right(10).top().height(50)
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        if self.bottomView.isHidden {
            self.tableView.pin.below(of: self.headerView).marginTop(0).left(10).right(10).bottom()
        } else {
            self.tableView.pin.left(10).right(10).below(of: self.headerView).marginTop(0).above(of: self.bottomView).marginBottom(10)
        }
    }
    
    private lazy var headerView : UILabel = {
        
        let _headerView = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 50))
        _headerView.backgroundColor = UIColor.clear
        _headerView.textAlignment = .left
        _headerView.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        _headerView.textColor = AppUIConfiguration.NeutralColor.secondaryText
        _headerView.text = String(format: "%d%@%@,%@%d%@", self.deviceList.count,localized(key:"个"),localized(key:"设备正在添加"),localized(key:"已添加成功"),self.successNum, localized(key:"个"))
        
        return _headerView
    }()
    
    private lazy var bottomView : MXAddDeviceBottomView = {
        let _bottomView = MXAddDeviceBottomView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 70))
        _bottomView.didActionCallback = { [weak self] (index: Int) in
            
            
            MeshSDK.sharedInstance.connect()
            if index == 0 {
                MXHomeManager.shard.updateHomeList()
                if let searchVC = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAddDeviceViewController.self)}) as? MXAddDeviceViewController {
                    self?.navigationController?.popToViewController(searchVC, animated: true)
                } else if let searchVC = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAutoSearchViewController.self)}) as? MXAutoSearchViewController {
                    self?.navigationController?.popToViewController(searchVC, animated: true)
                }
            } else {
                var device_list = [MXDeviceInfo]()
                self?.deviceList.forEach { (info:MXProvisionDeviceInfo) in
                    if info.provisionStatus == 2 {
                        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
                            if let device = room.devices.first(where: {$0.isSameFrom(info)}) {
                                device_list.append(device)
                            }
                        })
                    }
                }
                if device_list.count > 0 {
                    MXHomeManager.shard.updateHomeList()
                    var params = [String :Any]()
                    params["devices"] = device_list
                    params["roomId"] = self?.roomId
                    MXURLRouter.open(url: "https://com.mxchip.bta/page/device/settingRoom", params: params)
                } else {
                    if let searchVC = self?.navigationController?.viewControllers.first(where: {$0.isKind(of: MXAddDeviceViewController.self)}) as? MXAddDeviceViewController {
                        self?.navigationController?.popToViewController(searchVC, animated: true)
                    } else {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
        return _bottomView
    }()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.separatorStyle = .none
        tableView.canSimultaneously = false
        
        tableView.register(MXProvisionDeviceCell.self, forCellReuseIdentifier: String(describing: MXProvisionDeviceCell.self))
        
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension MXAddDeviceStepViewController {
    
    func createProvisionSteps(device: MXProvisionDeviceInfo) {
        var steps = Array<String>()
        let linkType = device.productInfo?.link_type_id
        switch linkType {
        case 7:
            steps = [localized(key:"与设备蓝牙连接"),localized(key:"配置蓝牙MESH网络"),localized(key:"绑定账号")]
        case 8:
            steps = [localized(key:"与设备蓝牙连接"),localized(key:"配置蓝牙MESH网络"),localized(key:"绑定账号")]
        case 9:
            steps = [localized(key:"设置网络信息"),localized(key:"连接Wi-Fi网络"),localized(key:"配置蓝牙MESH网络"),localized(key:"绑定账号")]
        case 10:
            steps = [localized(key:"与设备蓝牙连接"),localized(key:"配置蓝牙MESH网络"),localized(key:"连接Wi-Fi网络"),localized(key:"绑定账号")]
        case 11:
            if self.wifiSSID != nil, self.wifiPassword != nil {
                steps = [localized(key:"与设备蓝牙连接"),localized(key:"配置蓝牙MESH网络"),localized(key:"连接Wi-Fi网络"),localized(key:"绑定账号")]
            } else {
                steps = [localized(key:"与设备蓝牙连接"),localized(key:"配置蓝牙MESH网络"),localized(key:"绑定账号")]
            }
            
        default:
            steps = [localized(key:"设置网络信息"),localized(key:"连接网络"),localized(key:"绑定账号")]
            break
        }
        

        var list = Array<MXProvisionStepInfo>()
        for stepName in steps {
            let stepItem = MXProvisionStepInfo()
            stepItem.name = stepName
            stepItem.status = 0
            list.append(stepItem)
        }
        device.provisionStepList = list
    }
    
    
    func startProvisionDevice() {
        let unProvisionList = self.deviceList.filter({$0.provisionStatus == 0})
        let provisioningList = self.deviceList.filter({$0.provisionStatus == 1})
        if unProvisionList.count > 0 {
            for item in unProvisionList {
                if provisioningList.count < provisionQueueMax {
//                    if item.productInfo?.link_type_id == 7 || item.productInfo?.link_type_id == 8 || item.productInfo?.link_type_id == 10 || item.productInfo?.link_type_id == 11 {
                        if item.uuid != nil {
                            item.provisionStatus = 1
                            
                            self.startMeshProvision(info: item)
                        } else {
                            item.provisionStatus = 3
                            self.failNum += 1
                        }
                        self.startProvisionDevice()
                        return
                    //}
                }
            }
            self.bottomView.isHidden = true
            self.viewDidLayoutSubviews()
        } else {
            if self.deviceList.first(where: { $0.provisionStatus == 1 }) == nil {
                self.bottomView.isHidden = false
                self.viewDidLayoutSubviews()
            } else {
                self.bottomView.isHidden = true
                self.viewDidLayoutSubviews()
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func refreshProvisionStep(uuid: String? = nil, step: Int) {
        if let uuidStr = uuid, let item = self.deviceList.first(where: {$0.uuid == uuidStr}) {
            for i in 0..<item.provisionStepList.count {
                let info = item.provisionStepList[i]
                if i < step {
                    info.status = 2
                } else if i == step {
                    info.status = 1
                } else {
                    info.status = 0
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func provisionFail(uuid: String?) {
        if let uuidStr = uuid, let item = self.deviceList.first(where: {$0.uuid == uuidStr}) {
            if let info = item.provisionStepList.first(where: { $0.status == 1 }) {
                info.status = 3
            }
            item.provisionStatus = 3
            self.failNum += 1
            MXMeshProvisionManager.shared.isBusy = false
            
        }
        self.startProvisionDevice()
    }
    
    func provisionSuccess(uuid: String?) {
        if let uuidStr = uuid, let item = self.deviceList.first(where: {$0.uuid == uuidStr}) {
            for i in 0..<item.provisionStepList.count {
                let info = item.provisionStepList[i]
                info.status = 2
            }
            item.provisionStatus = 2
            self.successNum += 1
            self.headerView.text = String(format: "%d%@%@,%@%d%@", self.deviceList.count,localized(key:"个"),localized(key:"设备正在添加"),localized(key:"已添加成功"),self.successNum, localized(key:"个"))
            
            if self.deviceList.first(where: {$0.uuid != nil && ($0.provisionStatus == 0 || $0.provisionStatus == 1)}) == nil {
                MeshSDK.sharedInstance.getGATTProxyStatus(uuid: uuidStr) { (result: [String: Any]) in
                    if let status = result["proxy_status"] as? Int, status != 1 {
                        MeshSDK.sharedInstance.disconnect()
                    }
                    MXMeshProvisionManager.shared.isBusy = false
                    MXHomeManager.shard.meshConnectChange(status: 1)
                    self.startProvisionDevice()
                }
            } else {
                MXMeshProvisionManager.shared.isBusy = false
                self.startProvisionDevice()
            }
            
        } else {
            self.startProvisionDevice()
        }
    }
    
    func getQuintupleData(info:MXProvisionDeviceInfo) {
        if let uuid = info.uuid, uuid.count > 0 {
            guard MXAppPageConfig.shard.Provisioning_Need_Auth else { //不需要三元组认证
                self.gatewayOfflineMode(info: info)
                return
            }
            if info.productInfo?.cloud_platform == 2 {  
                MeshSDK.sharedInstance.fogDeviceTriplet(uuid: uuid) { (result: [String : Any]) in
                    if let dn = result["dn"] as? String {
                        if let signStr = result["ds"] as? String {
                            info.sign = signStr
                        }
                        if let sign_type = result["type"] as? String {
                            info.signType = Int(sign_type, radix: 16)
                        }

                        info.deviceName = dn
                    }
                    
                    self.gatewayOfflineMode(info: info)
                }
            } else {
                MeshSDK.sharedInstance.fetchDeviceTriplet(uuid: uuid) { (result: [String : Any]) in
                    if let dn = result["dn"] as? String {
                        info.deviceName = dn
                    }

                    self.gatewayOfflineMode(info: info)
                }
            }
        } else {
            self.provisionFail(uuid: nil)
        }
    }
    
    func gatewayOfflineMode(info:MXProvisionDeviceInfo) {
        if info.productInfo?.node_type_v2 == "gateway", let uuid = info.uuid, uuid.count > 0 {
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuid, message: "160001") { (result:[String : Any]) in
                if let resultMsg = result["message"] as? String, resultMsg.count > 4 {
                    let attrValue = String(resultMsg.suffix(resultMsg.count-4))
                    if Int(attrValue, radix: 16) == 0 {
                        if info.productInfo?.link_type_id == 10 || (info.productInfo?.link_type_id == 11 && self.wifiSSID != nil && self.wifiPassword != nil) {
                            self.sendWifiConfigData(info: info)
                        } else {
                            self.syncDeviceVersion(device: info)
                        }
                        return
                    }
                }
                self.provisionFail(uuid: uuid)
            }
        } else {
            if info.productInfo?.link_type_id == 10 || (info.productInfo?.link_type_id == 11 && self.wifiSSID != nil && self.wifiPassword != nil) {
                self.sendWifiConfigData(info: info)
            } else {
                self.syncDeviceVersion(device: info)
            }
        }
    }
    
    func sendWifiConfigData(info:MXProvisionDeviceInfo) {
        
        if let uuid = info.uuid, uuid.count > 0, let ssid = self.wifiSSID, let password = self.wifiPassword {
            self.refreshProvisionStep(uuid: uuid, step: (info.provisionStepList.firstIndex(where: {$0.name == localized(key:"连接Wi-Fi网络")}) ?? 1))
            MeshSDK.sharedInstance.sendWiFiPasswordToDevice(uuid: uuid, ssid: ssid, password: password) { (isSuccess : Bool) in
                if isSuccess {
                    if info.productInfo?.node_type_v2 == "gateway" {
                        MXDeviceManager.requestGatewayIp(uuid: uuid) { result in
                            info.ip = result
                            MXDeviceManager.requestHasPassword(uuid: uuid) { result in
                                info.hasPwd = result
                                self.syncDeviceVersion(device: info)
                            }
                        }
                    } else {
                        self.syncDeviceVersion(device: info)
                    }
                } else {
                    self.provisionFail(uuid: uuid)
                }
            }
        } else {
            self.provisionFail(uuid: info.uuid)
        }
    }
    
    func syncSettingDeviceInfo(device:MXProvisionDeviceInfo) {
        if let uuidStr = device.meshInfo?.uuid, uuidStr.count > 0 {
            
            let attrStr =  String(format: "%04X", UInt16(bigEndian: 0x0018).littleEndian) + "00000000"
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: attrStr) { (result:[String : Any]) in
                self.provisionSuccess(uuid: uuidStr)
            }
        } else {
            self.provisionSuccess(uuid: nil)
        }
    }
    
    func bindDevice(info: MXProvisionDeviceInfo) {
        
        self.cacheWifiInfo()
        
        let device = MXDeviceInfo()
        device.name = info.productInfo?.name ?? info.bleName
        device.productKey  = info.productInfo?.product_key
        device.image = info.productInfo?.image
        device.firmware_version = info.firmware_version
        device.bindTime = Int(NSDate().timeIntervalSince1970)
        device.isFavorite = true
        device.meshInfo = info.meshInfo
        device.deviceName = info.deviceName
        device.properties = info.productInfo?.properties
        device.category_id = info.productInfo?.category_id
        device.mac = info.mac
        if let room_id = self.roomId, let room = MXHomeManager.shard.currentHome?.rooms.first(where: {$0.roomId == room_id}) {
            device.roomId = room_id
            device.roomName = room.name
        } else if let defaultRoom = MXHomeManager.shard.currentHome?.rooms.first(where: {$0.isDefault}) {
            device.roomId = defaultRoom.roomId
            device.roomName = defaultRoom.name
        }
        device.ip = info.ip
        device.hasPwd = info.hasPwd
        MXDeviceManager.shard.add(device: device)
        
        self.refreshProvisionStep(uuid: info.uuid, step: (info.provisionStepList.firstIndex(where: {$0.name == localized(key:"绑定账号")}) ?? 2))
        info.bindTime = Int(Date().timeIntervalSince1970)
        self.syncSettingDeviceInfo(device: info)
    }
    
    func syncDeviceVersion(device:MXProvisionDeviceInfo) {
        if MXAppPageConfig.shard.Provisioning_Need_Version, let uuidStr = device.meshInfo?.uuid, uuidStr.count > 0 {
            MeshSDK.sharedInstance.fetchDeviceFirmwareVersion(uuid: uuidStr) { (version: String) in
                device.firmware_version = version
                self.bindDevice(info: device)
            }
        } else {
            self.bindDevice(info: device)
        }
    }
    
    func cacheWifiInfo() {
        if let ssid = self.wifiSSID, let password = self.wifiPassword {
            var wifi_params = [String : String]()
            if let wifiInfos = UserDefaults.standard.object(forKey: "kProvisionWifi") as? [String : String] {
                wifi_params = wifiInfos
            }
            wifi_params[ssid] = password
            
            UserDefaults.standard.set(wifi_params, forKey: "kProvisionWifi")
            UserDefaults.standard.synchronize()
        }
    }
}


extension MXAddDeviceStepViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.deviceList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXProvisionDeviceCell.self)) as? MXProvisionDeviceCell
        if cell == nil{
            cell = MXProvisionDeviceCell(style: .default, reuseIdentifier: String (describing: MXProvisionDeviceCell.self))
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        
        if self.deviceList.count > indexPath.section {
            let item = self.deviceList[indexPath.section]
            cell?.refreshView(info: item)
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.deviceList.count > indexPath.section {
            let item = self.deviceList[indexPath.section]
            if item.provisionStatus == 3 {
                var params = [String :Any]()
                params["device"] = item
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provisionStep", params: params)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 0.1))
        hView.backgroundColor = .clear
        return hView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let fView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 12))
        fView.backgroundColor = .clear
        return fView
    }
}

extension MXAddDeviceStepViewController:MXMeshProvisioningDelegate {
    
    func startMeshProvision(info: MXProvisionDeviceInfo) {
        self.refreshProvisionStep(uuid:info.uuid, step: (info.provisionStepList.firstIndex(where: {$0.name == localized(key:"与设备蓝牙连接")}) ?? 0))
        guard let device = info.device, let peripheral = info.peripheral, let nk = self.networkKey else {
            self.provisionFail(uuid: info.uuid)
            return
        }
        MXMeshProvisionManager.shared.startUnprovisionedDeviceProvision(device: device, peripheral: peripheral, networkKey: nk, delegate: self)
    }
    
    func meshProvisionFinish(uuid: String?, error: NSError?) {
        if let item = self.deviceList.first(where: {$0.uuid == uuid}) {
            if error == nil {
                if let uuidStr = uuid, uuidStr.count > 0, let node = MeshSDK.sharedInstance.getNodeInfo(uuid: uuidStr) {
                    item.meshInfo = MXMeshInfo()
                    item.meshInfo?.uuid = node["UUID"] as? String
                    if let meshAddress = node["unicastAddress"] as? String {
                        item.meshInfo?.meshAddress = UInt16(meshAddress, radix: 16)
                    }
                    item.meshInfo?.deviceKey = node["deviceKey"] as? String
                }
                self.refreshProvisionStep(uuid:uuid,step: (item.provisionStepList.firstIndex(where: {$0.name == localized(key:"配置蓝牙MESH网络")}) ?? 1))
                //self.bindDevice(info: item)
                self.getQuintupleData(info: item)
            } else {
                item.provisionError = error?.domain
                self.provisionFail(uuid:uuid)
            }
        }
    }
    
    func inputUnicastAddress(uuid: String?, elementNum: Int, handler: @escaping ((String?, Int) -> Void)) {
        nextAddress += 1
        handler(uuid,nextAddress)
    }
}

extension MXAddDeviceStepViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceStepViewController()
        controller.networkKey = params["networkKey"] as? String
        if let list = params["devices"] as? Array<MXProvisionDeviceInfo> {
            controller.deviceList = list
        }
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
