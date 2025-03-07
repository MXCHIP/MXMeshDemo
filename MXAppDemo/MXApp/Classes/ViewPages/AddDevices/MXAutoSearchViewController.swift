
import Foundation
import UIKit
import MeshSDK
import CoreBluetooth

class MXAutoSearchViewController: MXBaseViewController {
    
    var animationView : MXAutoAnimationView = MXAutoAnimationView(frame: .zero)
    public var networkKey : String?
    var list = Array<MXProvisionDeviceInfo>()
    var selectedNum:Int = 0
    var maxSelectedNum: Int = MXAppPageConfig.shard.Provisioning_Batch_MaxDevices
    var permissionList = Array<[String : Any]>()
    var HeaderView: MXSearchDeviceHeader = MXSearchDeviceHeader(frame: .zero)
    
    public var wifiSSID : String?
    public var wifiPassword : String?
    
    public var productInfo : MXProductInfo?
    
    public var isReplace: Bool?
    public var replacedDevice: MXDeviceInfo?
    public var scanTimeout: Int = 0  
    
    var roomId: Int?
    
    var workItem : DispatchWorkItem?

    lazy var selectedBtn : UIButton = {
        let _selectedBtn = UIButton(type: .custom)
        _selectedBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _selectedBtn.setTitle(String(format: "%@(%d/%d)", localized(key:"一键选择"),self.selectedNum,self.maxSelectedNum), for: .normal)
        _selectedBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        _selectedBtn.backgroundColor = AppUIConfiguration.MXColor.white
        _selectedBtn.layer.borderWidth = 1
        _selectedBtn.layer.borderColor = AppUIConfiguration.MainColor.C0.cgColor
        _selectedBtn.layer.cornerRadius = 22
        _selectedBtn.tag = 20001
        _selectedBtn.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return _selectedBtn
    }()
    
    lazy var addBtn : UIButton = {
        let _addBtn = UIButton(type: .custom)
        _addBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _addBtn.setTitle(localized(key:"添加设备"), for: .normal)
        _addBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        _addBtn.setTitleColor(UIColor(hex: "FFFFFF", alpha: 0.5), for: .disabled)
        _addBtn.setBackgroundColor(color: AppUIConfiguration.MainColor.C0, forState: .normal)
        
        _addBtn.layer.cornerRadius = 22
        _addBtn.tag = 20002
        _addBtn.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return _addBtn
    }()
    
    lazy var notFoundBtn : UIView = {
        let _notFoundBtn = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth - 20, height: 80))
        _notFoundBtn.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        _notFoundBtn.layer.cornerRadius = 16
        _notFoundBtn.layer.masksToBounds = true
        
        let notLB = UILabel(frame: .zero)
        notLB.backgroundColor = .clear
        notLB.text = localized(key:"未发现设备")
        notLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        notLB.textColor = AppUIConfiguration.NeutralColor.title
        notLB.textAlignment = .left
        
        let notBtn = UIButton(type: .custom)
        notBtn.frame = CGRect(x: 0, y: 0, width: 72, height: 44)
        notBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        notBtn.setTitle(localized(key:"更新"), for: .normal)
        notBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        notBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        notBtn.layer.cornerRadius = 22
        notBtn.tag = 20003
        notBtn.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        _notFoundBtn.addSubview(notBtn)
        notBtn.pin.right(16).width(72).height(44).vCenter()
        
        _notFoundBtn.addSubview(notLB)
        notLB.pin.left(16).top().bottom().left(of: notBtn).marginRight(8)
        
        return _notFoundBtn
    }()
    
    @objc func menuBtnAction(_ sender : UIButton) {
        switch sender.tag {
        case 20001:
            self.selectDevices()
            break
        case 20002:
            self.gotoProvisionPage()
            break
        case 20003:
            
            self.notFoundBtn.isHidden = true
            //MXResourcesManager.updateAppResources()
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.title = localized(key:"发现设备")
        
        self.HeaderView = MXSearchDeviceHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        
        animationView = MXAutoAnimationView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 480))
        self.contentView.addSubview(animationView)
        animationView.pin.left().right().bottom().height(480)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.all()
        
        self.contentView.addSubview(self.selectedBtn)
        self.selectedBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        
        self.contentView.addSubview(self.addBtn)
        self.addBtn.pin.width(136).height(44).bottom(24).hCenter(74)
        
        self.contentView.addSubview(self.notFoundBtn)
        self.notFoundBtn.pin.width(136).height(44).bottom(24).hCenter()
        self.notFoundBtn.isHidden = true
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        self.workItem?.cancel()
        self.workItem = nil
        print("页面释放了")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.animationView.pin.left().right().bottom().height(480)
        self.tableView.pin.all()
        self.selectedBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        self.addBtn.pin.width(136).height(44).bottom(24).hCenter(74)
        self.notFoundBtn.pin.left(10).right(10).height(80).bottom(16 + self.view.pin.safeArea.bottom)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedBtn.isHidden = true
        self.addBtn.isEnabled = false
        self.addBtn.isHidden = true
        self.notFoundBtn.isHidden = true
        self.list.forEach { (device:MXProvisionDeviceInfo) in
            device.isSelected = false
        }
        self.list.removeAll()
        self.selectedNum = 0
        self.selectedBtn.setTitle(String(format: "%@(%d/%d)", localized(key:"一键选择"),self.selectedNum,self.maxSelectedNum), for: .normal)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.loadPermissList()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    
    @objc func appBecomeActive() {
        print("appBecomeActive")
        self.loadPermissList()
    }
    
    func loadPermissList()  {
        self.permissionList.removeAll()
        let group = DispatchGroup()
        group.enter()
        MXSystemAuth.authBluetooth { [weak self] (isAuth: Bool) in
            if !isAuth {
                self?.addBluetoothAuthAlert()
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.refreshCurrentView()
        }
    }
    
    func addBluetoothAuthAlert() {
        if (self.permissionList.first(where: { $0["name"] as? String == localized(key:"请开启蓝牙功能")}) == nil) {
            var item = [String : Any]()
            item["name"] =  localized(key:"请开启蓝牙功能")
            item["icon"] = "\u{e683}"
            self.permissionList.append(item)
        }
    }
    
    func refreshCurrentView() {
        if self.permissionList.count > 0 {
            self.animationView.isHidden = true
            self.HeaderView.nameLB.text = localized(key:"准备搜索…")
            self.HeaderView.desLB.text = localized(key:"请开启蓝牙") + "\u{e6df}"
        } else {
            self.animationView.isHidden = false
            self.HeaderView.nameLB.text = localized(key:"正在搜索设备…")
            self.HeaderView.desLB.text = localized(key:"请确保设备已经进入配网状态") + "\u{e6df}"
            
            self.list.removeAll()
            self.scanMeshDevices()
        }
        
        if self.list.count > 0 {
            self.tableView.tableHeaderView = nil
        } else {
            self.tableView.tableHeaderView = self.HeaderView
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
        tableView.separatorStyle = .none
        tableView.canSimultaneously = false
        
        tableView.register(MXPermissionCell.self, forCellReuseIdentifier: String(describing: MXPermissionCell.self))
        tableView.register(DiscoveryDeviceCell.self, forCellReuseIdentifier: String(describing: DiscoveryDeviceCell.self))
        
        return tableView
    }()
    //搜索设备
    func scanMeshDevices() {
        MXMeshDeviceScan.shared.stopScan();
        MXMeshDeviceScan.shared.scanDevice(mac: nil, timeout: 0) { (devices:[[String : Any]]) in
            var newList = [MXProvisionDeviceInfo]()
            devices.forEach { (info:[String : Any]) in
                let deviceInfo = MXProvisionDeviceInfo.init(params: info)
                if let pInfo = self.productInfo {
                    if deviceInfo.productInfo == pInfo {
                        newList.append(deviceInfo)
                    }
                } else {
                    newList.append(deviceInfo)
                }
            }
            //移除不支持的设备
            self.list.removeAll { (info:MXProvisionDeviceInfo) in
                if newList.first(where: {$0.mac == info.mac && $0.deviceName == info.deviceName && $0.productInfo == info.productInfo }) == nil {
                    return true
                }
                return false
            }
            //添加新搜索到的设备
            let addList = newList.filter({ (info:MXProvisionDeviceInfo) in
                if self.list.first(where: {$0.mac == info.mac && $0.deviceName == info.deviceName && $0.productInfo == info.productInfo }) == nil {
                    return true
                }
                return false
            })
            self.list.append(contentsOf: addList)
            if self.list.count > 0 {
                if let _ = self.isReplace {
                    self.selectedBtn.isHidden = true
                    self.addBtn.isHidden = true
                    self.tableView.tableHeaderView = nil
                } else {
                    self.selectedBtn.isHidden = false
                    self.addBtn.isHidden = false
                    self.tableView.tableHeaderView = nil
                }
                self.notFoundBtn.isHidden = true
            } else {
                self.selectedBtn.isHidden = true
                self.addBtn.isHidden = true
                self.tableView.tableHeaderView = self.HeaderView
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
//        self.workItem?.cancel()
//        self.workItem = nil
//        self.workItem = DispatchWorkItem { [weak self] in
//            if self?.list.count ?? 0 <= 0 {
//                self?.notFoundBtn.isHidden = false
//            }
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: self.workItem!)
    }
    
    func addDeviceIntoList(device: MXProvisionDeviceInfo) {
        if self.list.firstIndex(where: {$0.mac == device.mac}) != nil {
            return
        }
        self.list.append(device)
    }
    
    func selectDevices() {
        let selectedList = self.list.filter { (device:MXProvisionDeviceInfo) in
            return device.isSelected
        }
        self.selectedNum = selectedList.count
        if selectedNum < self.maxSelectedNum {
            for info in self.list {
                if !info.isSelected {
                    info.isSelected = true
                    self.selectedNum += 1
                    if self.selectedNum >= self.maxSelectedNum {
                        break
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.selectedBtn.setTitle(String(format: "%@(%d/%d)", localized(key:"一键选择"),self.selectedNum,self.maxSelectedNum), for: .normal)
            if self.selectedNum > 0 {
                self.addBtn.isEnabled = true
            } else {
                self.addBtn.isEnabled = false
            }
            self.tableView.reloadData()
        }
    }
    
    func gotoInitPage() {
        var params = [String :Any]()
        params["networkKey"] = self.networkKey
        params["productInfo"] = productInfo
        params["isReplace"] = self.isReplace
        params["replacedDevice"] = self.replacedDevice
        
        let link_type_id = self.productInfo?.link_type_id
        var url = ""
        if link_type_id == 7 || link_type_id == 8 {
            url = "https://com.mxchip.bta/page/device/deviceInit"
        } else {
            url = "https://com.mxchip.bta/page/device/wifiPassword"
            params["isSkip"] = false
            if link_type_id == 11 {
                params["isSkip"] = true
            }
        }
        params["roomId"] = self.roomId
        MXURLRouter.open(url: url, params: params)
    }
    
    func gotoProvisionPage() {
        var devices = Array<MXProvisionDeviceInfo>()
        var hasWifiDevice = false
        var isSkipWifi = true
        for info in self.list {
            if info.isSelected {
                devices.append(info)
                
                if info.productInfo?.link_type_id != 7, info.productInfo?.link_type_id != 8 {
                    hasWifiDevice = true
                    if info.productInfo?.link_type_id != 11 {
                        isSkipWifi = false
                    }
                }
            }
        }
        
        if devices.count <= 0 {
            let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"请选择设备"), confirmButtonTitle: localized(key:"确定")) {
                
            }
            alert.show()
            return
        }
        self.workItem?.cancel()
        self.workItem = nil
        if hasWifiDevice && (self.wifiSSID == nil || self.wifiPassword == nil) {
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["devices"] = devices
            params["isSkip"] = isSkipWifi
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/wifiPassword", params: params)
            
        } else {
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["devices"] = devices
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision", params: params)
            
        }
    }
    
    
    func goToReplacePage(with provisionDevice: MXProvisionDeviceInfo) -> Void {
        guard let isReplace = self.isReplace,
              let replacedDevice = self.replacedDevice,
              let productInfo = provisionDevice.productInfo
        else { return }
        
        var url = ""
        var params = [String: Any]()
        
        let isWifiDevice = productInfo.link_type_id != 7 && productInfo.link_type_id != 8
        let isSkipWifi = productInfo.link_type_id == 11
        
        params["networkKey"] = self.networkKey
        params["provisionDevice"] = provisionDevice
        
        if isWifiDevice && self.wifiSSID == nil {
            url = "https://com.mxchip.bta/page/device/wifiPassword"
            params["isSkip"] = isSkipWifi
            params["isReplace"] = isReplace
        } else {
            url = "https://com.mxchip.bta/page/mine/deviceDoneReplace"
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["replacedDevice"] = replacedDevice
        }
        params["roomId"] = self.roomId
        MXURLRouter.open(url: url, params: params)
    }
    
}

extension MXAutoSearchViewController:UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.permissionList.count > 0 {
            return self.permissionList.count
        } else {
            return self.list.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.permissionList.count > 0 {
            var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: MXPermissionCell.self)) as? MXPermissionCell
            if cell == nil{
                cell = MXPermissionCell(style: .default, reuseIdentifier: String (describing: MXPermissionCell.self))
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            if self.permissionList.count > indexPath.section {
                let deviceInfo = self.permissionList[indexPath.section]
                cell?.refreshView(info: deviceInfo)
            }
            return cell!
        } else  {
            var cell = tableView.dequeueReusableCell(withIdentifier: String (describing: DiscoveryDeviceCell.self)) as? DiscoveryDeviceCell
            if cell == nil{
                cell = DiscoveryDeviceCell(style: .default, reuseIdentifier: String (describing: DiscoveryDeviceCell.self))
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            if list.count > indexPath.section {
                let deviceInfo = list[indexPath.section]
                cell?.refreshView(info: deviceInfo, isReplace: self.isReplace)
            }
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.permissionList.count > 0 {
            if self.permissionList.count > indexPath.section {
                
                MXSystemAuth.authSystemSetting(urlString: nil) { (isSuccess: Bool) in
                    
                }
            }
        } else {
            if list.count > indexPath.section {
                let deviceInfo = list[indexPath.section]
                if let _ = self.isReplace {
                    self.goToReplacePage(with: deviceInfo)
                } else {
                    if deviceInfo.isSelected {
                        deviceInfo.isSelected = false
                        self.selectedNum -= 1
                    } else {
                        if self.selectedNum < self.maxSelectedNum {
                            deviceInfo.isSelected = true
                            self.selectedNum += 1
                        }
                    }
                    self.selectedBtn.setTitle(String(format: "%@(%d/%d)", localized(key:"一键选择"),self.selectedNum,self.maxSelectedNum), for: .normal)
                    if self.selectedNum > 0 {
                        self.addBtn.isEnabled = true
                    } else {
                        self.addBtn.isEnabled = false
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 12))
        hView.backgroundColor = .clear
        return hView
    }
}

extension MXAutoSearchViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAutoSearchViewController()
        controller.networkKey = params["networkKey"] as? String ?? MXHomeManager.shard.currentHome?.networkKey
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.isReplace = params["isReplace"] as? Bool
        controller.replacedDevice = params["replacedDevice"] as? MXDeviceInfo
        controller.scanTimeout = (params["scanTimeout"] as? Int) ?? 0
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
