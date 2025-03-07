
import Foundation
import SDWebImage

class MXSceneDetailPage: MXBaseViewController {
    
    public var iconList = [[String : Any]]()
    public var colorList = ["FE6974","FF8062","FEC60C","37C453","00CBA7","00CBDE","29A3FF","5C70FF","976FFB","FF5BA3"]
    
    public var oldInfo = MXSceneInfo()
    
    var currentTimerAction : MXSceneTACItem?
    
    public var info : MXSceneInfo = MXSceneInfo()  {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        return tableView
    }()
    
    private lazy var bottomView : UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70))
        _bottomView.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        _bottomView.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        _bottomView.layer.shadowOffset = CGSize.zero
        _bottomView.layer.shadowOpacity = 1
        _bottomView.layer.shadowRadius = 8
        _bottomView.addSubview(self.nextBtn)
        self.nextBtn.pin.left(16).right(16).top(10).bottom(10)
        return _bottomView
    }()
    
    lazy var footerView : UIView = {
        let _footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        _footerView.backgroundColor = .clear
        
        let deleteBtn = UIButton(type: .custom)
        var deleteStr = localized(key:"删除场景")
        if self.oldInfo.type == "local_auto" {
            deleteStr =  localized(key:"删除联动")
        } else if self.oldInfo.type == "cloud_auto" {
            deleteStr =  localized(key:"删除自动化")
        } else if self.oldInfo.type == "one_click" {
            deleteStr =  localized(key:"删除场景")
        }
        deleteBtn.setTitle(deleteStr, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        deleteBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteScene), for: .touchUpInside)
        _footerView.addSubview(deleteBtn)
        deleteBtn.pin.width(120).height(44).center()
        
        return _footerView
    }()
    
    lazy var nextBtn : UIButton = {
        let _nextBtn = UIButton(type: .custom)
        _nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _nextBtn.setTitle(localized(key:"保存"), for: .normal)
        _nextBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        _nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        _nextBtn.layer.cornerRadius = 25
        _nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return _nextBtn
    }()
    
    @objc func deleteScene() {
        
        var deleteMsg = localized(key:"确定要删除该场景吗?")
        if self.info.type == "local_auto" {
            deleteMsg =  localized(key:"确定要删除该联动吗?")
        } else if self.info.type == "cloud_auto" {
            deleteMsg =  localized(key:"确定要删除该自动化吗?")
        } else if self.info.type == "one_click" {
            deleteMsg =  localized(key:"确定要删除该场景吗?")
        }
        
        let alert = MXAlertView(title: localized(key:"提示"), message: deleteMsg, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
            
        } rightButtonCallBack: {
            let needDevices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: nil, oldScene: self.oldInfo)
            MXSceneManager.shard.delete(scene: self.oldInfo)
            MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.oldInfo) { isFinish in
                self.backPreviousPage()
            }
        }
        alert.show()
    }
    
    @objc func nextPage() {
        
        if MXSceneManager.checkSceneConditionDeviceIsInvalid(scene: self.info) || MXSceneManager.checkSceneDeviceIsInvalid(scene: self.info) {
            var msgStr = localized(key:"该“一键执行”的部分任务已失效，保存后会删除失效任务")
            if self.info.type == "local_auto" {
                msgStr =  localized(key:"该“本地联动”的部分任务已失效，保存后会删除失效任务")
            } else if self.info.type == "cloud_auto" {
                msgStr =  localized(key:"该“自动化”的部分条目已失效，保存后会删除失效条目")
            } else if self.info.type == "one_click" {
                msgStr =  localized(key:"该“一键执行”的部分任务已失效，保存后会删除失效任务")
            }
            let alert = MXAlertView(title: localized(key:"提示"), message: msgStr, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"保存")) {
                
            } rightButtonCallBack: {
                self.info.conditions.items?.removeAll(where: { (item:MXSceneTACItem) in
                    if let newObj = item.params as? MXDeviceInfo, !newObj.isValid {
                        return true
                    }
                    return false
                })
                if (self.info.conditions.items?.count ?? 0) < 2 {
                    self.info.conditions.uri = "mx/logic/and"
                }
                self.info.actions.removeAll(where: { (item:MXSceneTACItem) in
                    if let params = item.params as? MXDeviceInfo {
                        if !params.isValid {
                            return true
                        } else if params.objType == 1, let nodes = params.subDevices, nodes.count <= 0 {
                            return true
                        }
                    }
                    return false
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.nextPage()
            }
            alert.show()
            return
        }
        
        if self.oldInfo == self.info && self.info.sceneId != 0 { 
            if self.info.type == "cloud_auto" {
                self.backPreviousPage()
            } else {
                let needDevices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: self.info, oldScene: self.oldInfo)
                MXSceneManager.shard.update(scene: self.info)
                if !MeshSDK.sharedInstance.isConnected() {
                    let alert = MXAlertView(title: "蓝牙未连接", message: localized(key: "蓝牙未连接提示描述"), leftButtonTitle: localized(key: "返回"), rightButtonTitle: localized(key:"确定")) {
                        self.backPreviousPage()
                    } rightButtonCallBack: {
                        MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                            self.backPreviousPage()
                        }
                    }
                    alert.show()
                    return
                }
                MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                    self.backPreviousPage()
                }
            }
            return
        }
        
        if self.info.type != "local_auto",  self.info.iconImage == nil {
            let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"请选择图标"), confirmButtonTitle: localized(key:"确定")) {
                
            }
            alert.show()
            return
        }
        
        if self.info.type == "cloud_auto" || self.info.type == "local_auto" {
            guard let condition_list = self.info.conditions.items, condition_list.count > 0 else {
                let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"请选择触发条件"), confirmButtonTitle: localized(key:"确定")) {
                    
                }
                alert.show()
                return
            }
        }
        
        if self.info.actions.count <= 0 {
            let alert = MXAlertView(title: localized(key: "提示"), message: localized(key: "请选择执行动作"), confirmButtonTitle: localized(key: "确定")) {
                
            }
            alert.show()
            return
        }
        
        if self.info.type == "cloud_auto" {
            guard let _ = self.info.attachments.items?.first(where: {$0.uri == "mx/attachment/time/range"}) else {
                let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"请选择生效时间段"), confirmButtonTitle: localized(key:"确定")) {
                    
                }
                alert.show()
                return
            }
        }
        
        if self.info.name == nil {
            let alert = MXAlertView(title: localized(key:"设置名称"), placeholder: localized(key:"请输入名称"), text: nil, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textField: UITextField) in
                
            } rightButtonCallBack: { (textField: UITextField) in
                if let name = textField.text {
                    let nameStr = name.trimmingCharacters(in: .whitespaces)
                    if !nameStr.isValidName() {
                        MXToastHUD.showInfo(status: localized(key:"名称长度限制"))
                        return
                    }
                    if MXHomeManager.shard.currentHome?.scenes.first(where: {$0.name == nameStr}) != nil {
                        MXToastHUD.showInfo(status: localized(key:"名称重复"))
                        return
                    }
                    self.info.name = nameStr
                    self.nextPage()
                }
            }
            alert.show()
            return
        }
        
        if self.info.sceneId == 0 {  
            let needDevices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: self.info, oldScene: nil)
            MXSceneManager.shard.add(scene: self.info)
            if !MeshSDK.sharedInstance.isConnected() {
                let alert = MXAlertView(title: "蓝牙未连接", message: localized(key: "蓝牙未连接提示描述"), leftButtonTitle: localized(key: "返回"), rightButtonTitle: localized(key:"确定")) {
                    self.backPreviousPage()
                } rightButtonCallBack: {
                    MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                        self.backPreviousPage()
                    }
                }
                alert.show()
                return
            }
            MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                self.backPreviousPage()
            }
        } else { 
            let needDevices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: self.info, oldScene: self.oldInfo)
            MXSceneManager.shard.update(scene: self.info)
            if !MeshSDK.sharedInstance.isConnected() {
                let alert = MXAlertView(title: "蓝牙未连接", message: localized(key: "蓝牙未连接提示描述"), leftButtonTitle: localized(key: "返回"), rightButtonTitle: localized(key:"确定")) {
                    self.backPreviousPage()
                } rightButtonCallBack: {
                    MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                        self.backPreviousPage()
                    }
                }
                alert.show()
                return
            }
            MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                self.backPreviousPage()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.oldInfo.sceneId == 0 {
            if self.oldInfo.type == "cloud_auto" {
                self.title = localized(key:"创建自动场景")
                self.nextBtn.setTitle(localized(key:"创建"), for: .normal)
            } else if self.oldInfo.type == "one_click" {
                self.title = localized(key:"创建手动场景")
                self.nextBtn.setTitle(localized(key:"创建"), for: .normal)
            } else if self.oldInfo.type == "local_auto" {
                self.title = localized(key:"创建自动场景")
                self.nextBtn.setTitle(localized(key:"保存"), for: .normal)
            }
        } else {
            if self.oldInfo.type == "cloud_auto" {
                self.title = localized(key:"编辑自动场景")
                self.nextBtn.setTitle(localized(key:"保存"), for: .normal)
            } else if self.oldInfo.type == "one_click" {
                self.title = localized(key:"编辑手动场景")
                self.nextBtn.setTitle(localized(key:"保存"), for: .normal)
            } else if self.oldInfo.type == "local_auto" {
                self.title = localized(key:"编辑自动场景")
                self.nextBtn.setTitle(localized(key:"保存"), for: .normal)
            }
            self.tableView.tableFooterView = self.footerView
        }
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.top().above(of: self.bottomView).marginBottom(0).left(10).right(10)
        

        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.bottomView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.tableView.backgroundColor = UIColor.clear
        
        if self.oldInfo.type != "local_auto" {
            self.loadIconDataList()
        }
        self.checkSceneInfoVaild()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func checkSceneInfoVaild() {
        if let infoParams = MXSceneInfo.mx_keyValue(self.oldInfo), let newInfo = MXSceneInfo.mx_Decode(infoParams) {
            self.info = newInfo
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        if self.info.type == "local_auto", MXSceneManager.checkSceneConditionDeviceIsInvalid(scene: self.oldInfo) {
            let msgStr = localized(key:"该“本地联动”的触发设备已解绑，联动失效，是否删除？")
            let alert = MXAlertView(title: localized(key:"提示"), message: msgStr, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
                self.backPreviousPage()
                
            } rightButtonCallBack: {
                
                let needDevices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: self.info, oldScene: self.oldInfo)
                MXSceneManager.shard.delete(scene: self.info)
                MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: self.info) { isFinish in
                    self.backPreviousPage()
                }
            }
            alert.show()
            return
        }
        
        if MXSceneManager.checkSceneConditionDeviceIsInvalid(scene: self.oldInfo) || MXSceneManager.checkSceneDeviceIsInvalid(scene: self.oldInfo) {
            var msgStr = localized(key:"该“自动化”的部分条目已失效，您可以删除失效的条目")
            if self.info.type == "cloud_auto" {
                msgStr = localized(key:"该“自动化”的部分条目已失效，您可以删除失效的条目")
            } else if self.info.type == "one_click" {
                msgStr = localized(key:"该“一键执行”的部分任务已失效，您可以删除失效任务")
            } else if self.info.type == "local_auto" {
                msgStr = localized(key:"该“本地联动”的部分任务已失效，您可以删除失效任务")
            }
            let alert = MXAlertView(title: localized(key:"提示"), message: msgStr, confirmButtonTitle: localized(key:"知道了")) {
                
            }
            alert.show()
        }
    }
    
    deinit {
        print("页面释放了")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        self.tableView.pin.top().above(of: self.bottomView).marginBottom(0).left(10).right(10)
    }
    
    override func gotoBack() {
        
        if self.oldInfo == self.info { 
            self.backPreviousPage()
            return
        }
        
        let sheetView = MXSceneSheetView(frame: CGRect.zero)
        sheetView.titleStr = localized(key:"未保存，是否退出")
        sheetView.dataList = [localized(key:"保存并退出"), localized(key:"退出"), localized(key:"取消")]
        sheetView.selectCallback = { (index: Int) in
            
            switch index {
            case 0:
                self.nextPage()
                break
            case 1:
                self.backPreviousPage()
                break
            default:
                break
            }
        }
        sheetView.show()
    }
    
    func backPreviousPage() {
            self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func loadIconDataList() {
        MXResourcesManager.loadLocalConfigFileUrl(name: "MXSceneIconImage") { (filePath:String?) in
            if let path = filePath {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url),
                   let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]] {
                    self.iconList = json
                    
                    if let iconStr = self.oldInfo.iconImage, iconStr.count > 0 {
                        
                    } else {
                        let randomIcon = self.iconList.randomElement()
                        self.oldInfo.iconImage = randomIcon?["image"] as? String
                        self.oldInfo.iconColor = self.colorList.randomElement()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension MXSceneDetailPage {
    
    @objc func selectSceneAction() {
        
        var params = [String: Any]()
        params["sceneInfo"] = self.info
        MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/selectedAction", params: params)
    }
    
    func setDeviceProperty(info: MXSceneTACItem, isTrigger: Bool = false) {
        
        if let propertyInfo = info.params as? MXDeviceInfo, let properties = propertyInfo.properties, propertyInfo.isValid {
             let view = MXSceneSettingPropertyView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
             view.sureActionCallback = { (list: [MXPropertyInfo]) in
                 if list.count == 0 {
                     self.info.actions.removeAll { (item:MXSceneTACItem) in
                         if let actionParams = item.params as? MXDeviceInfo, actionParams.isSameFrom(propertyInfo) {
                             return true
                         } else {
                             return false
                         }
                     }
                 } else {
                     if propertyInfo.status != 1 || propertyInfo.properties != list {
                         propertyInfo.properties = list
                         propertyInfo.status = 0
                         if let nodes = propertyInfo.subDevices {
                             nodes.forEach { (device:MXDeviceInfo) in
                                 device.status = 0
                             }
                         }
                     }
                 }
                 DispatchQueue.main.async {
                     self.tableView.reloadData()
                 }
             }
             view.dataList = propertyInfo.productInfo?.properties?.filter({$0.isSupportLocalAutoAction}) ?? properties
             view.selectList = properties
             view.show()
         }
    }
}

extension MXSceneDetailPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.info.type == "one_click" {
            return 5
        } else if self.info.type == "local_auto" {
            return 3
        }
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.oldInfo.type == "one_click" {
                return 0
            } else if self.oldInfo.type == "local_auto" {
                return 1
            }
            return 0
        } else if section == 1 {
            let list = self.info.actions.filter { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo {
                    if obj.objType == 1, let nodes = obj.subDevices {
                        var isDelete = true
                        for node in nodes {
                            if node.status != 3 {
                                isDelete = false
                                break
                            }
                        }
                        return !isDelete
                    } else if obj.objType == 0, obj.status == 3  {
                        return false
                    }
                }
                return true
            }
            if list.count > 0 {
                return list.count
            }
        } else if section == 2 {
            if self.info.sceneId == 0 {
                return 0
            }
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 2 {
            let cellIdentifier = "SceneActionCellIdentifier"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXSceneActionCell
            if cell == nil{
                cell = MXSceneActionCell(style: .default, reuseIdentifier: cellIdentifier)
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
            
            cell?.textLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
            cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.disable
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.text = nil
            cell?.textLabel?.attributedText = nil
            
            cell?.nameLab.text = nil
            cell?.valueLab.text = nil
            cell?.iconLB.text = nil
            cell?.iconView.image = nil
            cell?.cellCorner = []
            cell?.tagLab.isHidden = true
            
            if indexPath.section == 0 {
                if let list = self.info.conditions.items, list.count > 0 {
                    if list.count > indexPath.row {
                        let tcaInfo = list[indexPath.row]
                        if tcaInfo.uri == "mx/condition/device/property", let propertyInfo = tcaInfo.params as? MXDeviceInfo {
                            cell?.refreshView(info: propertyInfo, isTrigger: true)
                        }
                    }
                    if list.count == 1 || self.info.conditions.uri != "mx/logic/and"  {
                        cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                    } else if indexPath.row == 0 {
                        cell?.cellCorner = [.topLeft, .topRight]
                    } else if indexPath.row == (list.count - 1) {
                        cell?.cellCorner = [.bottomLeft, .bottomRight]
                    }
                } else {
                    let attriStr = NSMutableAttributedString()
                    let iconStr = NSAttributedString(string: "\u{e703}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1),.foregroundColor:AppUIConfiguration.NeutralColor.disable])
                    attriStr.append(iconStr)
                    let nameStr = NSAttributedString(string: "  " + localized(key:"添加条件"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.NeutralColor.disable,.baselineOffset: 2])
                    attriStr.append(nameStr)
                    cell?.textLabel?.attributedText = attriStr
                    cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                }
            } else if indexPath.section == 1 {
                let list = self.info.actions.filter { (item:MXSceneTACItem) in
                    if let obj = item.params as? MXDeviceInfo, obj.status == 3 {
                        if obj.objType == 0, obj.status == 3 {
                            return false
                        }
                    }
                    return true
                }
                if list.count > indexPath.row {
                    let tcaInfo = list[indexPath.row]
                    if let propertyInfo = tcaInfo.params as? MXDeviceInfo {
                        cell?.refreshView(info: propertyInfo)
                    }
                    
                    if list.count == 1  {
                        cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                    } else if indexPath.row == 0 {
                        cell?.cellCorner = [.topLeft, .topRight]
                    } else if indexPath.row == (list.count - 1) {
                        cell?.cellCorner = [.bottomLeft, .bottomRight]
                    }
                    
                } else {
                    let attriStr = NSMutableAttributedString()
                    let iconStr = NSAttributedString(string: "\u{e702}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1),.foregroundColor:AppUIConfiguration.NeutralColor.disable])
                    attriStr.append(iconStr)
                    let nameStr = NSAttributedString(string: "  " + localized(key:"添加动作"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.NeutralColor.disable,.baselineOffset: 2])
                    attriStr.append(nameStr)
                    cell?.textLabel?.attributedText = attriStr
                    
                    cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                }
            }
            
            return cell!
        } else {
            let cellIdentifier2 = "SceneCellIdentifier"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier2) as? MXActionCell
            if cell == nil{
                cell = MXActionCell(style: .value1, reuseIdentifier: cellIdentifier2)
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            cell?.textLabel?.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4)
            cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.title
            cell?.textLabel?.textAlignment = .left
            cell?.textLabel?.text = nil
            
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
            cell?.detailTextLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
            cell?.detailTextLabel?.textAlignment = .right
            cell?.detailTextLabel?.text = nil
            cell?.preView.isHidden = true
            cell?.actionBtn.isHidden = true
            
            switch indexPath.section {
            case 2:
                cell?.textLabel?.text = localized(key:"名称")
                cell?.detailTextLabel?.text = self.info.name
                cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                break
            case 3:
                cell?.textLabel?.text = localized(key:"图标风格")
                if let iconImage = self.info.iconImage {
                    cell?.preView.isHidden = false
                    cell?.preView.sd_setImage(with: URL(string: iconImage), placeholderImage: UIImage(named: iconImage)?.mx_imageByTintColor(color: UIColor(hex: self.info.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))) { (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                        if let img = image {
                            cell?.preView.image = img.mx_imageByTintColor(color: UIColor(hex: self.info.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))
                        }
                    }
                }
                cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                break
            case 4:
                if self.oldInfo.type == "one_click" {
                    cell?.accessoryType = .none
                    cell?.textLabel?.text = localized(key: "首页快捷启动")
                    cell?.actionBtn.isHidden = false
                    cell?.actionBtn.isOn = self.info.isFavorite
                    cell?.didActionCallback = { [weak self] (isOn: Bool) in
                        self?.info.isFavorite = isOn
                    }
                    cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                }
                break
            default:
                break
            }
            
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            if self.info.sceneId == 0 {
                return 0
            }
        }
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            let list = self.info.actions.filter { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo {
                    if obj.objType == 1, let nodes = obj.subDevices {
                        var isDelete = true
                        for node in nodes {
                            if node.status != 3 {
                                isDelete = false
                                break
                            }
                        }
                        return !isDelete
                    } else if obj.objType == 0, obj.status == 3  {
                        return false
                    }
                }
                return true
            }
            if list.count > indexPath.row {
                let info = list[indexPath.row]
                self.setDeviceProperty(info: info)
            } else {
                self.selectSceneAction()
            }
            break
        case 2:
            let alert = MXAlertView(title: localized(key:"设置名称"), placeholder: localized(key:"请输入名称"), text: self.info.name, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textField: UITextField) in
                
            } rightButtonCallBack: { (textField: UITextField) in
                if let name = textField.text {
                    let nameStr = name.trimmingCharacters(in: .whitespaces)
                    if !nameStr.isValidName() {
                        MXToastHUD.showInfo(status: localized(key:"名称长度限制"))
                        return
                    }
                    if MXHomeManager.shard.currentHome?.scenes.first(where: {$0.name == nameStr}) != nil {
                        MXToastHUD.showInfo(status: localized(key:"名称重复"))
                        return
                    }
                    self.info.name = nameStr
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            alert.show()
            break
        case 3:
            
            let iconView = MXScenceSelectIconView(frame: CGRect.zero)
            iconView.iconList = self.iconList
            iconView.colorList = self.colorList
            iconView.selectedIcon = self.info.iconImage
            iconView.selectedColorHex = self.info.iconColor
            iconView.selectIconCallback = { [weak self] (value: String) in
                self?.info.iconImage = value
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            iconView.selectColorCallback = { [weak self] (value: String) in
                self?.info.iconColor = value
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            iconView.show()
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.info.type == "one_click" {
                return 0
            }
            return 58
        } else if section == 1 {
            return 58
        } else if section == 2 {
            if self.info.sceneId == 0 {
                return 0
            }
        }
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            if self.info.type == "one_click" {
                let _hView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0))
                _hView.backgroundColor = .clear
                return _hView
            }
            
            let _hView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 58))
            _hView.backgroundColor = .clear
            
            let _titleLB = UILabel(frame: CGRect.zero)
            _titleLB.backgroundColor = UIColor.clear
            _titleLB.textAlignment = .left
            _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
            _titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
            _hView.addSubview(_titleLB)
            _titleLB.pin.left(16).right(120).top().bottom()
            _titleLB.text = localized(key:"如果")
            return _hView
            
        } else if section == 1 {
            let _hView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 58))
            _hView.backgroundColor = .clear
            
            let _titleLB = UILabel(frame: CGRect.zero)
            _titleLB.backgroundColor = UIColor.clear
            _titleLB.textAlignment = .left
            _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
            _titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
            _hView.addSubview(_titleLB)
            _titleLB.pin.left(16).right(120).top().bottom()
            
            let _moreLB = UILabel(frame: .zero)
            _moreLB.backgroundColor = .clear
            _moreLB.textAlignment = .right
            
            let _moreBtn = UIButton.init(type: .custom)
            _moreBtn.backgroundColor = .clear
            
            _titleLB.text = localized(key:"就执行以下动作")
            if self.info.type == "one_click" {
                _titleLB.text = localized(key:"一键执行以下动作")
            }
            
            let str = NSMutableAttributedString()
            let str1 = NSAttributedString(string: localized(key:"添加动作"), attributes: [.font: UIFont.mxBlodFont(size: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.MXAssistColor.main, .baselineOffset:2])
            str.append(str1)
            let str2 = NSAttributedString(string: "\u{e6db}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H2),.foregroundColor:AppUIConfiguration.MXAssistColor.main])
            str.append(str2)
            _moreLB.attributedText = str
            _hView.addSubview(_moreLB)
            _moreLB.pin.right(20).width(80).height(40).vCenter()
            
            _moreBtn.addTarget(self, action: #selector(selectSceneAction), for: .touchUpInside)
            _hView.addSubview(_moreBtn)
            _moreBtn.pin.right(20).width(80).height(40).vCenter()
            
            return _hView
        } else if section == 2 {
            var heardH: CGFloat = 12
            if self.info.sceneId == 0 {
                heardH = 0
            }
            let _hView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: heardH))
            _hView.backgroundColor = .clear
            return _hView
        } else {
            let _hView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
            _hView.backgroundColor = .clear
            return _hView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0.0))
        footer_view.backgroundColor = UIColor.clear
        return footer_view
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 1 {
                if self.info.actions.count > indexPath.row {
                    var action = self.info.actions[indexPath.row]
                    if let obj = action.params as? MXDeviceInfo {
                        if obj.objType == 0 {
                            obj.status = 3
                        } else if let nodes = obj.subDevices {
                            nodes.forEach { (device:MXDeviceInfo) in
                                device.status = 3
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return localized(key:"删除")
    }
    
}

extension MXSceneDetailPage: MXURLRouterDelegate {
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneDetailPage()
        if let scene_info = params["sceneInfo"] as? MXSceneInfo {
            vc.oldInfo = scene_info
        } else if let scene_params = params["sceneInfo"] as? [String : Any], let scene_info = MXSceneInfo.mx_Decode(scene_params) {
            vc.oldInfo = scene_info
        }
        return vc
    }
}
