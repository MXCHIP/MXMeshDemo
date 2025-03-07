
import Foundation

class MXDeviceDetailViewController: MXBaseViewController {
    
    var info : MXDeviceInfo?
    var headerView: MXDeviceDetailHeaderView?
    var gatewayStatus = [String: Int]()
    var connectPassword: String?
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    private lazy var footerView : UIView = {
        let _footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width-20, height: 60))
        _footerView.backgroundColor = UIColor.clear
        
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.layer.cornerRadius = 25.0
        deleteBtn.layer.masksToBounds = true
        deleteBtn.setTitleColor(AppUIConfiguration.MXAssistColor.red, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        deleteBtn.setTitle(localized(key:"删除设备"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteDeviceAlert), for: .touchUpInside)
        
        _footerView.addSubview(deleteBtn)
        deleteBtn.pin.left().top().right().height(50)
        deleteBtn.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        return _footerView
    }()
    
    private lazy var redPointView : UIView = {
        let _redPointView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        _redPointView.backgroundColor = AppUIConfiguration.MXAssistColor.red
        _redPointView.layer.cornerRadius = 3.0
        _redPointView.layer.masksToBounds = true
        return _redPointView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"设备详情")
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top(12).bottom()
        
        self.headerView = MXDeviceDetailHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 100))
        self.headerView?.didActionCallback = { [weak self] (info: Any) in
            if let isShare = self?.info?.isShare, isShare {
                
            } else {
                if !MXHomeManager.shard.operationAuthorityCheck() {
                    return
                }
            }
            let alertView = MXAlertView(title: localized(key:"设备名称"), placeholder: localized(key:"请输入名称"), text:self?.info?.name, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textField: UITextField) in
                
            } rightButtonCallBack: { (textField: UITextField) in
                guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                    MXToastHUD.showInfo(status: localized(key:"输入不能为空"))
                    return
                }
                if let msg = text.toastMessageIfIsInValidDeviceName() {
                    MXToastHUD.showInfo(status: msg)
                    return
                }
                self?.info?.name = text
                if let device = self?.info {
                    self?.headerView?.refreshView(info: device)
                }
                if let newDevice = self?.info {
                    MXDeviceManager.shard.update(device: newDevice)
                }
            }
            alertView.show()

        }
        self.tableView.tableHeaderView = self.headerView
        self.headerView?.layer.cornerRadius = 16.0
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60)
        self.tableView.tableFooterView = self.footerView
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
        self.headerView?.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
        self.requestPassword()
        self.requestGatewayStatus()
        self.requestGatewayIp(type: 2)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(10).right(10).top(12).bottom()
        self.headerView?.layer.cornerRadius = 16.0
    }
    
    func loadRequestData() {
        if let device = self.info {
            self.headerView?.refreshView(info: device)
        }
        self.tableView.reloadData()
    }
    
    func requestPassword() {
        if self.info?.productInfo?.node_type_v2 == "gateway", let uuidStr = self.info?.meshInfo?.uuid {
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: "1A00") { [weak self] (result:[String : Any]) in
                print("获取到密码数据：\(result)");
                guard  let resultMsg = result["message"] as? String else {
                    return
                }
                if resultMsg.count > 4 {
                    let attrValue = String(resultMsg.suffix(resultMsg.count-4))
                    if let text = String(data: Data(hex: attrValue), encoding: .utf8) {
                        self?.info?.hasPwd = text;
                        MXHomeManager.shard.updateHomeList()
                        self?.tableView.reloadData();
                        return
                    }
                }
            }
        }
    }
    
    func requestGatewayStatus() {
        if self.info?.productInfo?.node_type_v2 == "gateway",
           let uuidStr = self.info?.meshInfo?.uuid {
            let attrStr = "001B".littleEndian + "01"
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: attrStr) { (result:[String : Any]) in
                guard  let resultMsg = result["message"] as? String else {
                    return
                }
                let resultData = [UInt8](Data(hex: resultMsg))
                if resultData.count > 4 {
                    let subType1 = String(format: "%02X", resultData[3])
                    let subValue1 = String(format: "%02X", resultData[4])
                    self.gatewayStatus[subType1] = Int(subValue1, radix: 16)
                }
                if resultData.count > 6 {
                    let subType2 = String(format: "%02X", resultData[5])
                    let subValue2 = String(format: "%02X", resultData[6])
                    self.gatewayStatus[subType2] = Int(subValue2, radix: 16)
                }
                if self.gatewayStatus.count > 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func requestGatewayIp(type: Int) {
        if self.info?.productInfo?.node_type_v2 == "gateway",
           let uuidStr = self.info?.meshInfo?.uuid {
            let attrStr = "001B".littleEndian + "02" + String(format: "%02X", type)
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "10", uuid: uuidStr, message: attrStr) { (result:[String : Any]) in
                guard  let resultMsg = result["message"] as? String else {
                    if type == 2 {
                        self.requestGatewayIp(type: 1)
                    }
                    return
                }
                let resultData = [UInt8](Data(hex: resultMsg))
                if resultData.count > 6, resultData[3] > 0 {
                    self.info?.ip = String(resultData[3]) + "." + String(resultData[4]) + "." + String(resultData[5]) + "." + String(resultData[6])
                    MXHomeManager.shard.updateHomeList()
                    print("获取到网关的ip地址：\(String(describing: self.info?.ip))")
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else if type == 2 {
                    self.requestGatewayIp(type: 1)
                }
            }
        }
    }
    
    @objc func deleteDeviceAlert() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        let alert = MXAlertView(title: localized(key:"删除设备"), message: localized(key:"删除设备提示"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
            
        } rightButtonCallBack: {
            self.deleteDevice()
        }
        alert.show()
    }
    
    @objc func deleteDevice() {
        if let device = self.info {
            if device.objType == 0, let uuidStr = device.meshInfo?.uuid {
                MeshSDK.sharedInstance.resetNode(uuid: uuidStr)
            }
            MXDeviceManager.shard.delete(device: device)
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func updateDeviceFavorite(isOn: Bool) {
        self.info?.isFavorite = isOn
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        if let newDevice = self.info {
            MXDeviceManager.shard.update(device: newDevice)
        }
    }
}

extension MXDeviceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "kCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXLongPressMenuCell
        if cell == nil{
            cell = MXLongPressMenuCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.textLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.title
        cell?.textLabel?.textAlignment = .left
        
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.detailTextLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
        cell?.detailTextLabel?.textAlignment = .right
        cell?.detailTextLabel?.numberOfLines = 1
        cell?.canShowMenu = false
        cell?.actionBtn.isHidden = true
        cell?.cellCorner = []
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = localized(key:"设备ID")
            cell?.detailTextLabel?.text = self.info?.deviceName
            cell?.accessoryType = .none
            cell?.canShowMenu = true
            cell?.copyActionCallback = { [weak self] in
                self?.copyDeviceName()
            }
            cell?.cellCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]
            break
        case 1:
            cell?.textLabel?.text = localized(key:"房间位置")
            cell?.detailTextLabel?.text = localized(key:"未设置")
            if let rName = self.info?.roomName, rName.count > 0 {
                cell?.detailTextLabel?.text = rName
            }
            cell?.accessoryType = .disclosureIndicator
            break
        case 2:
            cell?.accessoryType = .none
            cell?.textLabel?.text = localized(key:"固件版本")
            cell?.detailTextLabel?.text = (self.info?.firmware_version ??  "")
            break
        case 3:
            cell?.textLabel?.text = localized(key:"一键替换")
            cell?.detailTextLabel?.text = nil
            cell?.accessoryType = .disclosureIndicator
            break
        case 4:
            cell?.textLabel?.text = localized(key:"切换网络")
            cell?.detailTextLabel?.text = nil
            cell?.accessoryType = .disclosureIndicator
            break
        case 5:
            cell?.textLabel?.text = localized(key:"mx_connect_status")
            cell?.detailTextLabel?.text = nil
            cell?.accessoryType = .none
            if let status1 = self.gatewayStatus["02"], status1 == 1 {
                cell?.detailTextLabel?.text = localized(key: "mx_connect_net" )
            } else if let status2 = self.gatewayStatus["01"], status2 == 1 {
                cell?.detailTextLabel?.text = localized(key: "mx_network_state_wifi")
            } else if self.gatewayStatus.count > 0 {
                cell?.detailTextLabel?.text = localized(key: "mx_disconnect")
            }
            break
        case 6:
            cell?.textLabel?.text = localized(key:"mx_gateway_ip")
            cell?.detailTextLabel?.text = self.info?.ip
            cell?.accessoryType = .none
            cell?.canShowMenu = true
            cell?.copyActionCallback = { [weak self] in
                self?.copyIPAddress()
            }
            break
        case 7:
            cell?.textLabel?.text = localized(key:"HAS密码")
            cell?.detailTextLabel?.text = self.info?.hasPwd
            cell?.accessoryType = .disclosureIndicator
            cell?.canShowMenu = true
            cell?.copyActionCallback = { [weak self] in
                self?.copyPassword()
            }
            break
        case 8:
            cell?.textLabel?.text = localized(key:"设置为常用设备")
            cell?.detailTextLabel?.text = nil
            cell?.accessoryType = .none
            cell?.actionBtn.isHidden = false
            cell?.actionBtn.isOn = self.info?.isFavorite ?? false
            cell?.didActionCallback = { [weak self] (isOn: Bool) in
                
                self?.updateDeviceFavorite(isOn: isOn)
            }
            cell?.cellCorner = [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
            break
        default:
            break
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            if let version = self.info?.firmware_version, version.count > 0 {
                return 60
            }
            return 0
        case 3:
            return 0
        case 4:
            if self.info?.productInfo?.node_type_v2 == "gateway" ||
                self.info?.productInfo?.link_type_id == 10 ||
                self.info?.productInfo?.link_type_id == 11  {
                return 60
            }
            return 0
        case 5:
            if self.info?.productInfo?.node_type_v2 == "gateway",
               self.gatewayStatus.count > 0 {
                return 60
            }
            return 0
        case 6:
            if self.info?.productInfo?.node_type_v2 == "gateway",
               let ipStr = self.info?.ip,
               ipStr.count > 0 {
                return 60
            }
            return 0
        case 7:
            if self.info?.productInfo?.node_type_v2 == "gateway",
               let password = self.info?.hasPwd,
               password.count > 0 {
                return 60
            }
            return 0
        case 8:
            if self.info?.productInfo?.node_type_v2 == "gateway",
               let password = self.info?.hasPwd,
               password.count > 0 {
                return 60
            }
            return 0
        default:
            return 60
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            self.gotoDeviceRoomSetting()
            break
        case 2:
            //self.gotoOTAPage()
            break
        case 3:
            self.gotoReplace()
            break
        case 4:
            self.gotoWifiSetting()
            break
        case 5:
            break
        case 6:
            break
        case 7:
            //设置密码
            if !MeshSDK.sharedInstance.isConnected() {
                MXToastHUD.showInfo(status: localized(key: "请检查蓝牙连接状态"));
                return;
            }
            self.settingGatewayConnectPassword()
            break
        case 8:
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12.0))
        header_view.backgroundColor = UIColor.clear
        
        return header_view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12.0))
        footer_view.backgroundColor = UIColor.clear
        
        return footer_view
    }
    
}

extension MXDeviceDetailViewController {
    
    func gotoOTAPage() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
    }
    
    
    func gotoReplace() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        
        guard let info = self.info else { return }
        
        var url = ""
        var params = [String: Any]()
        
        if let networkKey = MXHomeManager.shard.currentHome?.networkKey {
            params["networkKey"] = networkKey
        }
        if let productInfo = info.productInfo {
            params["productInfo"] = productInfo
        }
        params["isReplace"] = true
        params["replacedDevice"] = info
        params["scanTimeout"] = 15
        url = "https://com.mxchip.bta/page/device/autoSearch"
        
        MXURLRouter.open(url: url, params: params)
    }
    
    
    func gotoWifiSetting() {
        var params = [String :Any]()
        params["resetDevice"] = self.info
        params["isSkip"] = false
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/wifiPassword", params: params)
    }
    
    
    func gotoDeviceRoomSetting() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        var params = [String : Any]()
        params["device"] = self.info
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/selectRoom", params: params)
    }
    
    
    func copyDeviceName() {
        let past = UIPasteboard.general
        past.string = self.info?.deviceName
        
        MXToastHUD.showInfo(status: localized(key:"复制成功"))
    }
    
    func copyPassword() {
        if let pwd = self.info?.hasPwd {
            let past = UIPasteboard.general
            past.string = pwd
            MXToastHUD.showInfo(status: localized(key:"复制成功"))
        }
    }
    
    func copyIPAddress() {
        if let ipStr = self.info?.ip {
            let past = UIPasteboard.general
            past.string = ipStr
            MXToastHUD.showInfo(status: localized(key:"复制成功"))
        }
    }
    
    func settingGatewayConnectPassword() {
        guard self.info?.hasPwd != nil, let uuidStr = self.info?.meshInfo?.uuid else {
            //没有密码说明不支持
            return;
        }
        let alertView = MXAlertView(title: localized(key:"设置密码"), placeholder: localized(key:"请输入密码"), text:self.info?.hasPwd, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { [weak self] (textField: UITextField) in
            
        } rightButtonCallBack: { [weak self] (textField: UITextField) in
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                MXToastHUD.showInfo(status: localized(key:"输入不能为空"))
                return
            }
            if !text.isValidGatewayPassword() {
                MXToastHUD.showInfo(status: localized(key: "网关密码校验"));
                return
            }
            if let passwordHex = text.data(using: .utf8)?.toHexString() {
                let msg = "1A00" + passwordHex
                MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: msg) { (result:[String : Any]) in
                    guard  let resultMsg = result["message"] as? String else {
                        MXToastHUD.showInfo(status: localized(key: "设置密码失败"))
                        return
                    }
                    if resultMsg.count > 4 {
                        let attrValue = String(resultMsg.suffix(resultMsg.count-4))
                        if Int(attrValue, radix: 16) == 0 {
                            self?.info?.hasPwd = text;
                            MXHomeManager.shard.updateHomeList()
                            self?.tableView.reloadData();
                            MXToastHUD.showInfo(status: localized(key: "设置密码成功"))
                            return
                        }
                    }
                    MXToastHUD.showInfo(status: localized(key: "设置密码失败"));
                }
            }
        }
        alertView.show()
    }
}

extension MXDeviceDetailViewController: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXDeviceDetailViewController()
        controller.info = params["device"] as? MXDeviceInfo
        return controller
    }
}
