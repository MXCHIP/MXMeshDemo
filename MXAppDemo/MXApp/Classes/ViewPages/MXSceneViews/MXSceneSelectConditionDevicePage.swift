
import Foundation

class MXSceneSelectConditionDevicePage: MXBaseViewController {
    
    var info = MXSceneInfo(type: "local_auto")
    var dataList = [[MXDeviceInfo]]()
    var selectedList = [MXDeviceInfo]()
    
    var pageNo : Int = 1
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect(x: 10, y: 0, width: self.view.frame.size.width - 20, height: self.view.frame.size.height), style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 10))
        tableView.register(MXSceneDeviceCell.self, forCellReuseIdentifier: String(describing: MXSceneDeviceCell.self))
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"选择设备")
        
        if self.info.type == "local_auto" {
            
            NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        }
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top().bottom()
        
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无设备")
        self.tableView.emptyView = mxEmptyView
        
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = .clear
        
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
        self.pageNo = 1
        self.loadDeviceList()
    }
    
    func loadDeviceList() {
        self.dataList.removeAll()
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            let device_list = room.devices.filter({$0.productInfo?.properties?.first(where: {$0.isSupportLocalAutoCondition}) != nil})
            if device_list.count > 0 {
                let newRoom = MXRoomInfo()
                newRoom.roomId = room.roomId
                newRoom.name = room.name
                for device in device_list {
                    if let deviceParams = MXDeviceInfo.mx_keyValue(device), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                        newDevice.properties = newDevice.productInfo?.properties
                        newRoom.devices.append(newDevice)
                    }
                }
                self.dataList.append(newRoom.devices)
            }
        })
    }
    
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension MXSceneSelectConditionDevicePage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataList.count > section {
            let subList = self.dataList[section]
            return subList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MXSceneDeviceCell.self)) as? MXSceneDeviceCell
        if cell == nil{
            cell = MXSceneDeviceCell(style: .value1, reuseIdentifier: String(describing: MXSceneDeviceCell.self))
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.detailTextLabel?.textColor = AppUIConfiguration.MXAssistColor.gold
        cell?.detailTextLabel?.text = nil
        
        cell?.nameLB.textColor = AppUIConfiguration.NeutralColor.title
        cell?.cellCorner = []
        
        if self.dataList.count > indexPath.section {
            let subList = self.dataList[indexPath.section]
            if subList.count > indexPath.row {
                let info = subList[indexPath.row]
                cell?.info = info
                if let selectedInfo = self.selectedList.first(where: { (item:MXDeviceInfo) in
                    if item.isSameFrom(info) {
                        return true
                    }
                    return false
                }) {
                    cell?.refreshPropertyInfo(device: selectedInfo)
                }
            }
            
            if indexPath.row == 0 {
                if subList.count == 1 {
                    cell?.cellCorner = [UIRectCorner.topLeft, UIRectCorner.topRight, UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                } else {
                    cell?.cellCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]
                }
            } else if indexPath.row == subList.count - 1 {
                cell?.cellCorner = [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
            }
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.section {
            let subList = self.dataList[indexPath.section]
            if subList.count > indexPath.row {
                let info = subList[indexPath.row]
                if let uuidStr = info.meshInfo?.uuid, uuidStr.count > 0 {
                    if !MeshSDK.sharedInstance.isConnected() {
                        return
                    }
                }
                
                var params = [String : Any]()
                params["device"] = info
                params["isTrigger"] = true
                params["sceneType"] = self.info.type
                params["sceneInfo"] = self.info
                MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/settingProperty", params: params)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        header_view.backgroundColor = UIColor.clear
        let header_title = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.width - 30, height: 50))
        header_title.backgroundColor = UIColor.clear
        header_title.textColor = AppUIConfiguration.NeutralColor.secondaryText
        header_title.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        header_title.text = localized(key:"未分配房间")
        if self.dataList.count > section {
            let subList = self.dataList[section]
            if let info = subList.first, let roomName = info.roomName, roomName.count > 0 {
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

extension MXSceneSelectConditionDevicePage: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXSceneSelectConditionDevicePage()
        if let info = params["sceneInfo"] as? MXSceneInfo {
            controller.info = info
        }
        if let list = params["selectedDevices"] as? [MXDeviceInfo] {
            controller.selectedList = list
        }
        return controller
    }
}
