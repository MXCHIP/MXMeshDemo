
import Foundation
import SystemConfiguration.CaptiveNetwork
import MeshSDK

class MXInputWifiPasswordViewController: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String?
    public var deviceList = Array<MXProvisionDeviceInfo>()
    public var isSkip = false
    public var wifiSSID : String?
    public var wifiPassword : String?
    
    public var productInfo : MXProductInfo?
    
    var wifiParams = [String : String]()
    
    var isReplace: Bool?
    var replacedDevice: MXDeviceInfo?
    
    var resetDevice: MXDeviceInfo?  
    
    var roomId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.title = localized(key:"设置网络")
        
        if let wifiInfo = UserDefaults.standard.object(forKey: "kProvisionWifi") as? [String : String] {
            self.wifiParams = wifiInfo
        }
        
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left().top().right().height(84)
        
        self.contentView.addSubview(self.ssidView)
        self.ssidView.pin.below(of: self.headerView).marginTop(24).left(24).right(24).height(50)
        self.ssidView.nameLB.delegate = self
        self.ssidView.nameLB.returnKeyType = .done
        
        self.contentView.addSubview(self.paswordView)
        self.paswordView.pin.below(of: self.ssidView).marginTop(24).left(24).right(24).height(50)
        self.paswordView.nameLB.delegate = self
        self.paswordView.nameLB.returnKeyType = .done
        
        self.contentView.addSubview(self.nextBtn)
        self.nextBtn.pin.below(of: self.paswordView).marginTop(32).left(24).right(24).height(50)
        self.nextBtn.isUserInteractionEnabled = false
        
        self.contentView.addSubview(self.skipLB)
        self.skipLB.pin.below(of: self.nextBtn).marginTop(16).width(60).height(16).hCenter()
        self.skipLB.isHidden = !self.isSkip
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.pin.left().top().right().height(84)
        self.ssidView.pin.below(of: self.headerView).marginTop(24).left(24).right(24).height(50)
        self.paswordView.pin.below(of: self.ssidView).marginTop(24).left(24).right(24).height(50)
        self.nextBtn.pin.below(of: self.paswordView).marginTop(32).left(24).right(24).height(50)
        self.skipLB.pin.below(of: self.nextBtn).marginTop(16).width(60).height(16).hCenter()
    }
    
    private lazy var selectView : MXSelectWifiView = {
        let _wifiSelectView = MXSelectWifiView(frame: CGRect(x: 60, y: 248, width: screenWidth - 135, height: 216))
        _wifiSelectView.didSelectedItemCallback = { [weak self] (selectValue: String) in
            self?.ssidView.nameLB.text = selectValue
            self?.wifiSSID = selectValue
            
            if let passwordStr = self?.wifiParams[selectValue] {
                self?.wifiPassword = passwordStr
                self?.paswordView.nameLB.text = passwordStr
            }
            self?.view.endEditing(true)
            
            if self?.wifiSSID != nil, self?.wifiPassword != nil {
                self?.nextBtn.isUserInteractionEnabled = true
                self?.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
            } else {
                self?.nextBtn.isUserInteractionEnabled = false
                self?.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C2
            }
        }
        return _wifiSelectView
    }()
    
    private lazy var headerView : MXWifiPasswordHeaderView = {
        let _headerView = MXWifiPasswordHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: 84))
        return _headerView
    }()
    
    private lazy var ssidView : MXWifiInputView = {
        let _ssidView = MXWifiInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        _ssidView.iconView.text = "\u{e681}"
        _ssidView.actionBtn.setTitle("\u{e682}", for: .normal)
        _ssidView.didActionCallback = {
            if let url = URL(string: "App-Prefs:root=WIFI"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return _ssidView
    }()
    
    private lazy var paswordView : MXWifiInputView = {
        let _paswordView = MXWifiInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        _paswordView.iconView.text = "\u{e694}"
        _paswordView.iconView.textColor = AppUIConfiguration.NeutralColor.primaryText
        _paswordView.actionBtn.setTitle("\u{e695}", for: .normal)
        _paswordView.actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        _paswordView.nameLB.isSecureTextEntry = true
        _paswordView.didActionCallback = { [weak _paswordView] in
            if let isSecure = _paswordView?.nameLB.isSecureTextEntry, isSecure {
                _paswordView?.nameLB.isSecureTextEntry = false
                _paswordView?.actionBtn.setTitle("\u{e693}", for: .normal)
            } else {
                _paswordView?.nameLB.isSecureTextEntry = true
                _paswordView?.actionBtn.setTitle("\u{e695}", for: .normal)
            }
        }
        return _paswordView
    }()
    
    private lazy var nextBtn : UIButton = {
        let _nextBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        _nextBtn.backgroundColor = AppUIConfiguration.MainColor.C2
        _nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _nextBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        _nextBtn.setTitle(localized(key:"下一步"), for: .normal)
        _nextBtn.layer.cornerRadius = 25
        _nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return _nextBtn
    }()
    
    private lazy var skipLB : UILabel = {
        let _skipLB = UILabel(frame: .zero)
        _skipLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _skipLB.textColor = AppUIConfiguration.NeutralColor.title
        _skipLB.textAlignment = .center
        
        let str = localized(key:"跳过设置")
        let attributes = [.font:UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.title,.underlineStyle: NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        _skipLB.attributedText = NSAttributedString(string: str, attributes: attributes)
        _skipLB.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(skipAction))
        _skipLB.addGestureRecognizer(tap)
        return _skipLB
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkLocationPermiss()
    }
    
    func checkLocationPermiss() {
        if #available(iOS 13.0, *) {
            
            MXSystemAuth.authLocation { (isOpen: Bool, isReq: Bool, isFullAccuracy: Bool) in
                if !isOpen {
                    let alert = MXAlertView(title: localized(key:"未开启定位权限"), message: localized(key:"请允许App使用定位服务以便获取Wi-Fi信息"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"去设置")) {
                        
                    } rightButtonCallBack: {
                        MXSystemAuth.authSystemSetting(urlString: nil) { (isSuccess: Bool) in
                            
                        }
                    }
                    alert.show()
                } else {
                    if !isFullAccuracy {
                        MXToastHUD.showError(status: localized(key:"获取精准定位失败"))
                    }
                    self.getWifiSSID()
                }
            }
        } else {
            self.getWifiSSID()
        }
    }
    
    
    @objc func appBecomeActive() {
        print("appBecomeActive")
        self.checkLocationPermiss()
        self.getWifiSSID()
    }
}

extension MXInputWifiPasswordViewController {
    
    func getWifiSSID() {
        if let interfaces = CNCopySupportedInterfaces(), let interfacesArray = CFBridgingRetain(interfaces) as? Array<AnyObject> {
            if interfacesArray.count > 0 {
                let interfaceName = interfacesArray[0] as! CFString
                if let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName) {
                    if let interfaceData = ussafeInterfaceData as? Dictionary<String, Any>, let ssid = interfaceData["SSID"] as? String {
                        self.ssidView.nameLB.text = ssid
                        self.wifiSSID = ssid
                        self.paswordView.nameLB.text = self.wifiParams[ssid]
                        self.wifiPassword = self.wifiParams[ssid]
                        
                        if self.wifiSSID != nil, self.wifiPassword != nil {
                            self.nextBtn.isUserInteractionEnabled = true
                            self.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
                        } else {
                            self.nextBtn.isUserInteractionEnabled = false
                            self.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C2
                        }
                    }
                }
            }
        }
    }
    
    @objc func nextPage() {
        self.view.endEditing(true)
        
        guard let ssid = self.wifiSSID, let password = self.wifiPassword else {
            return
        }
        
        if let device = self.resetDevice {  
            if let uuid = device.meshInfo?.uuid, uuid.count > 0{
                if !MeshSDK.sharedInstance.isConnected() {
                    let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"请检查蓝牙连接状态"), confirmButtonTitle: localized(key:"确定")) {
                        
                    }
                    alert.show()
                    return
                }
                MXToastHUD.show()
                MeshSDK.sharedInstance.sendWiFiPasswordToDevice(uuid: uuid, ssid: ssid, password: password) { (isSuccess : Bool) in
                    MXToastHUD.dismiss()
                    if isSuccess {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        MeshSDK.sharedInstance.rebootDevice(uuid: uuid)
                        MXToastHUD.showError(status: localized(key: "切换网络失败"))
                    }
                }
            }
            return
        }
        
        if self.deviceList.count > 0 {  
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["devices"] = self.deviceList
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision", params: params)
        } else {
            var params = [String :Any]()
            params["networkKey"] = self.networkKey
            params["productInfo"] = self.productInfo
            params["ssid"] = self.wifiSSID
            params["password"] = self.wifiPassword
            params["devices"] = self.deviceList
            if let isReplace = isReplace {
                params["isReplace"] = isReplace
            }
            if let replacedDevice = replacedDevice {
                params["replacedDevice"] = replacedDevice
            }
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
        }
    }
    
    @objc func skipAction() {
        let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"跳过Wi-Fi设置"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
            
        } rightButtonCallBack: {
            if self.deviceList.count > 0 {  
                var params = [String :Any]()
                params["networkKey"] = self.networkKey
                params["devices"] = self.deviceList
                params["roomId"] = self.roomId
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/provision", params: params)
            } else {
                var params = [String :Any]()
                params["networkKey"] = self.networkKey
                params["productInfo"] = self.productInfo
                params["roomId"] = self.roomId
                MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
            }
        }
        alert.show()

    }
    
    func searchWifi(name: String) {
        
        let list : [String] = self.wifiParams.map { (key: String, value: String) -> String in
            return key
        }
        if list.count > 0 {
            self.selectView.dataList = list
            self.selectView.show()
        } else {
            self.selectView.hide()
        }
    }
}

extension MXInputWifiPasswordViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let mStr = text.replacingCharacters(in: textRange, with: string)
            if textField == self.paswordView.nameLB {
                self.wifiPassword = mStr
            } else if textField == self.ssidView.nameLB {
                let searchStr = mStr.trimmingCharacters(in: .whitespaces)
                self.wifiSSID = searchStr
                self.searchWifi(name: searchStr)
            }
        }
        
        if self.wifiSSID != nil, self.wifiPassword != nil {
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        } else {
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C2
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.ssidView.nameLB {
            let searchStr = (textField.text ?? "").trimmingCharacters(in: .whitespaces)
            self.searchWifi(name: searchStr)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.paswordView.nameLB {
            self.wifiPassword = textField.text
        } else if textField == self.ssidView.nameLB {
            self.wifiSSID = textField.text?.trimmingCharacters(in: .whitespaces)
            if let wifiName = textField.text?.trimmingCharacters(in: .whitespaces) {
                self.paswordView.nameLB.text = self.wifiParams[wifiName]
                self.wifiPassword = self.wifiParams[wifiName]
            }
        }
        
        self.selectView.hide()
        
        if let ssid = self.wifiSSID, let password = self.wifiPassword, ssid.count > 0, password.count > 0 {
            self.nextBtn.isUserInteractionEnabled = true
            self.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        } else {
            self.nextBtn.isUserInteractionEnabled = false
            self.nextBtn.backgroundColor = AppUIConfiguration.MainColor.C2
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MXInputWifiPasswordViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXInputWifiPasswordViewController()
        controller.networkKey = params["networkKey"] as? String
        if let list = params["devices"] as? Array<MXProvisionDeviceInfo> {
            controller.deviceList = list
        }
        controller.isSkip = (params["isSkip"] as? Bool) ?? false
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.isReplace = params["isReplace"] as? Bool
        controller.replacedDevice = params["replacedDevice"] as? MXDeviceInfo
        
        controller.resetDevice = params["resetDevice"] as? MXDeviceInfo
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
