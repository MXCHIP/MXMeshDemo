
import Foundation
import UIKit

class MXSceneSelectDevicePage: MXBaseViewController {
    
    var dataList = [[MXDeviceInfo]]()
    var selectedDevices = [MXDeviceInfo]()
    var dataSources = [[MXDeviceInfo]]()
    
    var info = MXSceneInfo(type: "one_click")
    
    var deleteActions = [MXSceneTACItem]()
    
    let rightBarButton = UIButton(type: .custom)
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect(x: 10, y: 0, width: self.view.frame.size.width - 20, height: self.view.frame.size.height), style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 10))
        tableView.register(MXSceneDeviceEditCell.self, forCellReuseIdentifier: String(describing: MXSceneDeviceEditCell.self))
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"选择设备")
        
        let color = AppUIConfiguration.NeutralColor.primaryText
        let font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let att = NSAttributedString(string: localized(key: "下一步"), attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: font])
        self.rightBarButton.setAttributedTitle(att, for: .normal)
        self.rightBarButton.addTarget(self, action: #selector(nextButtonAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(self.rightBarButton)
        self.rightBarButton.pin.right(20).vCenter().sizeToFit()
        
        if self.info.type == "local_auto" {
            
            NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        }
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top().bottom()
        
        let mxEmptyView = MXTitleEmptyView(frame: tableView.bounds)
        mxEmptyView.titleLB.text = localized(key: "暂无设备")
        self.tableView.emptyView = mxEmptyView
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = .clear
        
        let del_list = self.info.actions.filter({ (action:MXSceneTACItem) in
            if let obj = action.params as? MXDeviceInfo {
                if obj.objType == 1, let nodes = obj.subDevices {
                    var isDelete = true
                    nodes.forEach { (device:MXDeviceInfo) in
                        if device.status != 3 {
                            isDelete = false
                            return
                        }
                    }
                    return isDelete
                } else if obj.status == 3 {
                    return true
                }
            }
            return false
        })
        
        del_list.forEach { (item:MXSceneTACItem) in
            if let params = MXSceneTACItem.mx_keyValue(item), let newObj = MXSceneTACItem.mx_Decode(params) {
                self.deleteActions.append(newObj)
            }
        }
        
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(10).right(10).top().bottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDeviceList()
    }
    
    @objc func nextButtonAction(sender: UIButton) -> Void {
        
        if self.selectedDevices.count <= 0 {
            MXToastHUD.showError(status: localized(key: "请选择设备"))
            return
        }
        
        self.deleteActions.forEach { (item:MXSceneTACItem) in
            if self.info.actions.first(where: {$0 == item}) == nil {
                self.info.actions.append(item)
            }
        }
        
        if let detailVC = self.navigationController?.viewControllers.first(where: {$0.isKind(of: MXSceneDetailPage.self)}) as? MXSceneDetailPage {
            detailVC.info = self.info
            self.navigationController?.popToViewController(detailVC, animated: true)
        } else {
            var params = [String : Any]()
            params["sceneInfo"] = self.info
            MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
        }
        
    }
    
    func loadDeviceList() {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            self.dataList.append(room.devices.filter({ (device:MXDeviceInfo) in
                if let pList = device.productInfo?.properties, pList.first(where: {$0.isSupportLocalAutoAction}) != nil {
                    return true
                }
                return false
            }))
        })
        self.formateDataSource()
        self.tableView.reloadData()
    }
    
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func formateDataSource() -> Void {
        let actions = self.info.actions
        self.selectedDevices.removeAll()
        actions.forEach { (item: MXSceneTACItem) in
            if let objParams = item.params as? MXDeviceInfo, objParams.status != 3, objParams.isValid {
                self.selectedDevices.append(objParams)
            }
        }
        self.dataSources.removeAll()
        self.dataSources.append(contentsOf: self.dataList)
        for i in 0 ..< self.dataSources.count {
            var list = self.dataSources[i]
            let newList = list.filter { (info:MXDeviceInfo) in
                if self.selectedDevices.first(where: {$0.isSameFrom(info)}) != nil {
                    return false
                }
                return true
            }
            list = newList
            self.dataSources[i] = list
        }
        self.dataSources.removeAll(where: {$0.count <= 0})
        if self.selectedDevices.count > 0 {
            self.dataSources.insert(self.selectedDevices, at: 0)
        }
        
        self.tableView.reloadData()
    }
    
    
    func gotoSelectProtertyPage(device: MXDeviceInfo) {
        let view = MXSceneSettingPropertyView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        view.sureActionCallback = { (list: [MXPropertyInfo]) in
            if let actionInfo = self.info.actions.first(where: { (tca: MXSceneTACItem) in
                if let obj = tca.params as? MXDeviceInfo, obj.isSameFrom(device) {
                    return true
                }
                return false
            }), let objParams = actionInfo.params as? MXDeviceInfo {
                if objParams.status != 1 || objParams.properties != list || !objParams.isValid {
                    objParams.properties = list
                    objParams.status = 0
                    if let nodes = objParams.subDevices {
                        nodes.forEach { (device:MXDeviceInfo) in
                            device.status = 0
                        }
                    }
                }
                objParams.isValid = true
            } else {
                let caInfo = MXSceneTACItem()
                if device.objType == 0 {
                    caInfo.uri = "mx/action/device/property/set"
                } else {
                    caInfo.uri = "mx/action/group/property/set"
                }
                var objParams = MXDeviceInfo()
                if let deviceParams = MXDeviceInfo.mx_keyValue(device), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                    objParams = newDevice
                }
                objParams.properties = list
                caInfo.params = objParams
                self.info.actions.append(caInfo)
            }
                            
            self.formateDataSource()
        }
        if let actionInfo = self.info.actions.first(where: { (tca: MXSceneTACItem) in
            if let obj = tca.params as? MXDeviceInfo, obj.isSameFrom(device), obj.isValid, obj.status != 3 {
                return true
            }
            return false
        }),
           let objParams = actionInfo.params as? MXDeviceInfo,
           let properties = objParams.properties {
            view.selectList = properties
        }
        if let pList = device.productInfo?.properties?.filter({$0.isSupportLocalAutoAction}), pList.count > 0  {
            view.dataList = pList
            view.show()
        }
    }
    
}

extension MXSceneSelectDevicePage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSources.count > section {
            let subList = self.dataSources[section]
            return subList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneDeviceEditCell", for: indexPath) as! MXSceneDeviceEditCell
        cell.selectionStyle = .none
        if self.dataSources.count > indexPath.section {
            let list = self.dataSources[indexPath.section]
            if list.count > indexPath.row {
                let device = list[indexPath.row]
                cell.indexPath = indexPath
                cell.delegate = self
                cell.sceneType = self.info.type
                cell.device = device
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSources.count > indexPath.section {
            let subList = self.dataSources[indexPath.section]
            if subList.count > indexPath.row {
                let info = subList[indexPath.row]
                self.gotoSelectProtertyPage(device: info)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width - 10 * 2, height: 40))
        header_view.backgroundColor = UIColor.clear
        let header_title = UILabel(frame: CGRect(x: 10, y: 16, width: tableView.frame.width - 10 * 2 - 10 * 2, height: 18))
        header_title.backgroundColor = UIColor.clear
        header_title.textColor = AppUIConfiguration.NeutralColor.secondaryText
        header_title.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        header_title.text = localized(key:"未分配房间")
        if self.dataSources.count > section {
            let subList = self.dataSources[section]
            if section == 0 && self.selectedDevices.count > 0 {
                header_title.text = localized(key: "已添加到任务的设备")
            } else if let info = subList.first, let roomName = info.roomName, roomName.count > 0 {
                header_title.text = roomName
            }
        }
        header_view.addSubview(header_title)
        return header_view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.1))
        footer_view.backgroundColor = UIColor.clear
        return footer_view
    }
    
}

extension MXSceneSelectDevicePage: MXSceneDeviceEditCellDelegate {
    
    func add(at indexPath: IndexPath) {
        if self.dataSources.count > indexPath.section {
            let subList = self.dataSources[indexPath.section]
            if subList.count > indexPath.row {
                let info = subList[indexPath.row]
                
                if self.selectedDevices.count > 0 && indexPath.section == 0 {

                } else {
                    self.gotoSelectProtertyPage(device: info)
                }
            }
        }
    }
    
    func remove(at indexPath: IndexPath) {
        if self.dataSources.count > indexPath.section {
            let subList = self.dataSources[indexPath.section]
            if subList.count > indexPath.row {
                let info = subList[indexPath.row]
                self.info.actions.removeAll { (item:MXSceneTACItem) in
                    if let objParams = item.params as? MXDeviceInfo, objParams.isSameFrom(info) {
                        return true
                    }
                    return false
                }
                self.formateDataSource()
            }
        }
        
    }
}

extension MXSceneSelectDevicePage: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXSceneSelectDevicePage()
        if let info = params["sceneInfo"] as? MXSceneInfo, let newInfoParams = MXSceneInfo.mx_keyValue(info), let newInfo = MXSceneInfo.mx_Decode(newInfoParams) {
            controller.info = newInfo
        }
        return controller
    }
}
