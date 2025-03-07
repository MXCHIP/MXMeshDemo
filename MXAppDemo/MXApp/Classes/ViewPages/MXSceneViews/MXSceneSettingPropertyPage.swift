
import Foundation
import UIKit
import MeshSDK

class MXSceneSettingPropertyPage: MXBaseViewController {
    
    var dataList = [MXPropertyInfo]()
    
    public var deviceActions = [MXSceneTACItem]()
    public var device : MXDeviceInfo?
    var isTrigger : Bool = false 
    var sceneType: String = "one_click"
    
    var sceneInfo = MXSceneInfo(type: "one_click")
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"执行设备动作")
        self.title = self.device?.showName
        
        if !self.isTrigger {
            let rightBtn = UIButton(type: .custom)
            rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
            rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
            rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
            rightBtn.setTitle(localized(key:"保存"), for: .normal)
            rightBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
            self.mxNavigationBar.rightView.addSubview(rightBtn)
            rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        }
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(0).right(0).top(12).bottom()
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(0).right(0).top(12).bottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDataList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneInfo = MXSceneInfo(type: self.sceneType)
        self.deviceActions.removeAll()
    }
    
    
    func loadDataList() {
        if self.isTrigger {
            self.dataList.removeAll()
            if let list = self.device?.productInfo?.properties?.filter({$0.isSupportLocalAutoCondition}) {
                for p in list {
                    self.dataList.append(MXPropertyInfo(info: p))
                }
            }
        }
        self.fetchDeviceActions()
    }
    
    
    func fetchDeviceActions() {
        self.dataList.forEach { (item:MXPropertyInfo) in
            for tac in self.deviceActions {
                if let obj = tac.params as? MXDeviceInfo, obj.status != 3, let pList = obj.properties {
                    if let pInfo = pList.first(where: {$0.identifier == item.identifier}) {
                        item.value = pInfo.value
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func saveAction() {
        
        if self.dataList.first(where: {$0.value != nil}) == nil {
            MXToastHUD.showError(status: localized(key:"请设置设备动作"))
            return
        }
        
        if self.sceneType == "local_auto", self.isTrigger { 
            if let info = self.dataList.first(where: {$0.value != nil}) {
                
                if let scene = MXHomeManager.shard.currentHome?.autoScenes.first(where: { (scene_info:MXSceneInfo) in
                    if scene_info.conditions.items?.first(where: { (tac:MXSceneTACItem) in
                        if let params = tac.params as? MXDeviceInfo, params.isSameFrom(self.device), params.properties?.first(where: {$0 == info}) != nil, params.isValid {
                            return true
                        }
                        return false
                    }) != nil, scene_info.isValid {
                        return true
                    }
                    return false
                }) {
                    var params = [String : Any]()
                    params["sceneInfo"] = scene
                    MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
                    return
                }
                
                let sceneInfo = MXSceneInfo()
                sceneInfo.type = "local_auto"
                sceneInfo.iconImage = self.device?.image ?? self.device?.productInfo?.image
                sceneInfo.conditions = MXSceneConditionItem()
                sceneInfo.conditions.items = [MXSceneTACItem]()
                sceneInfo.conditions.uri = "mx/logic/and"
                
                let trigger = MXSceneTACItem()
                trigger.uri = "mx/condition/device/property"
                var objParams = MXDeviceInfo()
                if let newDevice = self.device, let deviceParams = MXDeviceInfo.mx_keyValue(newDevice), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                    objParams = newDevice
                }
                objParams.properties = [info]
                trigger.params = objParams
                sceneInfo.conditions.items?.append(trigger)
                
                var params = [String : Any]()
                params["sceneInfo"] = sceneInfo
                MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
                return
            }
        }
        
        var list = [MXSceneTACItem]()
        if self.isTrigger {
            if let triggers = self.sceneInfo.conditions.items {
                list = triggers
            }
            for item in self.dataList {
                if item.value != nil,
                   list.first(where: { (tac:MXSceneTACItem) in
                       if let obj = tac.params as? MXDeviceInfo,
                          obj.objId == self.device?.objId,
                          let pInfo = obj.properties?.first {
                        if pInfo.identifier == item.identifier {
                            return true
                        }
                    }
                    return false
                   }) == nil {
                    let caInfo = MXSceneTACItem()
                    caInfo.uri = "mx/condition/device/property"
                    var objParams = MXDeviceInfo()
                    if let newDevice = self.device, let deviceParams = MXDeviceInfo.mx_keyValue(newDevice), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                        objParams = newDevice
                    }
                    objParams.properties = [item]
                    caInfo.params = objParams
                    list.append(caInfo)
                }
            }
            self.sceneInfo.conditions.items = list
        } else {
            list = self.sceneInfo.actions
            let property_list = self.dataList.filter({$0.value != nil})
            
            if let info = list.first(where: { (tca: MXSceneTACItem) in
                if let obj = tca.params as? MXDeviceInfo, obj.isSameFrom(self.device) {
                    return true
                }
                return false
            }), let objParams = info.params as? MXDeviceInfo {
                objParams.properties = property_list
            } else {
                let caInfo = MXSceneTACItem()
                if self.device?.objType == 0 {
                    caInfo.uri = "mx/action/device/property/set"
                } else {
                    caInfo.uri = "mx/action/group/property/set"
                }
                var objParams = MXDeviceInfo()
                if let newDevice = self.device, let deviceParams = MXDeviceInfo.mx_keyValue(newDevice), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                    objParams = newDevice
                }
                objParams.properties = property_list
                caInfo.params = objParams
                list.append(caInfo)
            }
            self.sceneInfo.actions = list
        }
        if let detailVC = self.navigationController?.viewControllers.first(where: {$0.isKind(of: MXSceneDetailPage.self)}) as? MXSceneDetailPage {
            detailVC.info = self.sceneInfo
            self.navigationController?.popToViewController(detailVC, animated: true)
        } else {
            var params = [String : Any]()
            params["sceneInfo"] = self.sceneInfo
            MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
        }
    }
}

extension MXSceneSettingPropertyPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "kCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXActionCell
        if cell == nil{
            cell = MXActionCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.textLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.title
        cell?.textLabel?.textAlignment = .left
        cell?.textLabel?.text = nil
        
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.detailTextLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
        cell?.detailTextLabel?.textAlignment = .right
        cell?.detailTextLabel?.text = nil
        cell?.actionBtn.isHidden = true
        cell?.preView.isHidden = true
        cell?.preView.backgroundColor = .clear
        
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell?.textLabel?.text = info.name
            if let identifierStr = info.identifier {
                if identifierStr == "HSVColorHex" || identifierStr == "HSVColor" {
                    cell?.preView.isHidden = false
                    cell?.preView.layer.cornerRadius = 16.0
                    if self.isTrigger {
                        
                        cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
                    }
                    if let pValue = info.value as? Int32 {
                        cell?.preView.backgroundColor = MXHSVColorHandle.colorFromHSVColor(value: pValue)
                    } else if let pValue = info.value as? [String: Int], let hValue = pValue["Hue"], let sValue = pValue["Saturation"], let vValue = pValue["Value"] {
                        cell?.preView.backgroundColor = UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0)
                    }
                    
                } else {
                    if let pValue = info.value as? Int {
                        var compareStr = info.compare_type
                        if compareStr == "==" {
                            compareStr = ""
                        }
                        cell?.detailTextLabel?.text = compareStr + String(pValue)
                        if let pType = info.dataType?.type, let list = info.dataType?.specs as? [String: String], (pType == "bool" || pType == "enum") {
                            cell?.detailTextLabel?.text = list[String(pValue)]
                        }
                        if self.isTrigger {
                            
                            cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
                        }
                    } else if let pValue = info.value as? Double {
                        var compareStr = info.compare_type
                        if compareStr == "==" {
                            compareStr = ""
                        }
                        cell?.detailTextLabel?.text = compareStr + String(pValue)
                        if self.isTrigger {
                            
                            cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
                        }
                    }
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if self.isTrigger, info.value != nil {  
                return
            }
            
            guard let pType = info.dataType?.type, let identifierStr = info.identifier else {
                return
            }
            if (pType == "bool" || pType == "enum") {
                guard let list = info.dataType?.specs as? [String: String] else {
                    return
                }
                if self.isTrigger {
                    if list.count == 1, let firstKey = list.keys.first, let newValue = Int(firstKey) {
                        info.value = newValue as AnyObject
                        self.saveAction()
                        return
                    }
                    let selectV = MXSceneConditionEnumView(frame: .zero)
                    selectV.dataName = info.name ?? ""
                    selectV.dataList = list
                    selectV.selectCallback = { (value: Int?) in
                        if let newValue = value {
                            info.value = newValue as AnyObject
                            self.saveAction()
                        }
                    }
                    selectV.show()
                } else {
                    let selectV = MXSelectedSettingView(frame: .zero)
                    selectV.titleLB.text = info.name
                    selectV.dataList = list
                    selectV.currentValue = info.value as? Int
                    selectV.sureActionCallback = { (value: Int?) in
                        info.value = value as AnyObject
                        self.tableView.reloadData()
                    }
                    selectV.show()
                }
            } else if pType == "struct" {
                if identifierStr == "HSVColor" {
                    let selectV = MXHSVSettingView(frame: .zero)
                    selectV.sureActionCallback = { (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) in
                        var newValue = [String: Int]()
                        newValue["Hue"] = Int(hue*360)
                        newValue["Saturation"] = Int(saturation*100)
                        newValue["Value"] = Int(brightness*100)
                        info.value = newValue as AnyObject
                        if self.isTrigger {
                            self.saveAction()
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                    if let pValue = info.value as? [String : Int] {
                        selectV.hsvValue = pValue
                    }
                    selectV.show()
                }
            } else {
                guard let list = info.dataType?.specs as? [String: String] else {
                    return
                }
                if identifierStr == "HSVColorHex" {
                    let selectV = MXHSVSettingView(frame: .zero)
                    selectV.sureActionCallback = { (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) in
                        let hStr = String(format: "%04X", Int(hue*360)).littleEndian
                        let sStr = String(format: "%02X", Int(saturation*100))
                        let vStr = String(format: "%02X", Int(brightness*100))
                        let hsvHex = hStr + sStr + vStr
                        
                        let hsvValue = UInt32(hsvHex, radix: 16) ?? 0
                        
                        info.value = Int32(bitPattern: hsvValue) as AnyObject
                        
                        if self.isTrigger {
                            self.saveAction()
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                    selectV.hsvColorValue = (info.value as? Int) ?? 25700
                    selectV.show()
                } else if identifierStr == "ColorTemperature" {
                    let selectV = MXColorTemperatureSettingView(frame: .zero)
                    selectV.percent = (info.value as? Double) ?? 0
                    selectV.sureActionCallback = { (value: Double) in
                        info.value = value as AnyObject
                        if self.sceneType == "local_auto", self.isTrigger {
                            self.saveAction()
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                    selectV.show()
                } else {
                    if self.isTrigger, self.sceneType == "cloud_auto" {
                        let selectV = MXSceneSliderSettingView(frame: .zero)
                        selectV.titleLB.text = info.name
                        selectV.minValue = Float(list["min"] ?? "0") ?? 0
                        selectV.maxValue = Float(list["max"] ?? "100") ?? 100
                        if let unitStr = list["unit"] {
                            selectV.sliderView.unit = unitStr
                        }
                        if let stepStr = list["step"], let step = Float(stepStr) {
                            selectV.sliderView.stepValue = step
                            if step < 0.1 {
                                selectV.sliderView.floatNum = 2
                            } else if step < 1 {
                                selectV.sliderView.floatNum = 1
                            }
                        }
                        selectV.percent = (info.value as? Float) ?? (selectV.maxValue - selectV.minValue)/2.0 + selectV.minValue
                        selectV.sureActionCallback = { (value: Float, compare:String) in
                            info.compare_type = compare
                            info.value = value as AnyObject
                            if self.isTrigger {
                                self.saveAction()
                            } else {
                                self.tableView.reloadData()
                            }
                        }
                        selectV.show()
                    } else {
                        let selectV = MXSliderSettingView(frame: .zero)
                        selectV.titleLB.text = info.name
                        selectV.minValue = Int(list["min"] ?? "0") ?? 0
                        selectV.maxValue = Int(list["max"] ?? "100") ?? 100
                        selectV.percent = (info.value as? Int) ?? selectV.maxValue
                        selectV.sureActionCallback = { (value: Int) in
                            info.value = value as AnyObject
                            if self.isTrigger {
                                self.saveAction()
                            } else {
                                self.tableView.reloadData()
                            }
                        }
                        selectV.show()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
}

extension MXSceneSettingPropertyPage: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXSceneSettingPropertyPage()
        if let is_trigger = params["isTrigger"] as? Bool {
            controller.isTrigger = is_trigger
        }
        if let type = params["sceneType"] as? String {
            controller.sceneType = type
            controller.sceneInfo = MXSceneInfo(type: type)
        }
        if let actions = params["deviceActions"] as? [MXSceneTACItem] {
            controller.deviceActions = actions
        }
        controller.device = params["device"] as? MXDeviceInfo
        if let info = params["sceneInfo"] as? MXSceneInfo {
            controller.sceneInfo = info
        }
        return controller
    }
}
