
import Foundation
import UIKit

class MXSceneDevicesSwitchPage: MXBaseViewController {
    
    var sceneInfo = MXSceneInfo(type: "one_click")
    var pageNo : Int = 1
    
    @objc func nextButtonAction(sender: UIButton) -> Void {
        let devices = self.dataSources.map({$0.devices}).flatMap({$0})
        let newList = devices.filter({$0.isSelected})
        if newList.count <= 0 {
            MXToastHUD.showError(status: localized(key: "请选择设备"))
            return
        }
        let status = self.headerView.switchView.status
        if status == -1 {
            MXToastHUD.showError(status: localized(key: "请选择开关功能"))
            return
        }
        var actions = self.sceneInfo.actions
        
        actions.removeAll { (item:MXSceneTACItem) in
            if let obj = item.params as? MXDeviceInfo, devices.first(where: {$0.isSameFrom(obj)}) != nil {
                return true
            }
            return false
        }
        for device in newList {
            if let action = actions.first(where: { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo, obj.isSameFrom(device) {
                    return true
                }
                return false
            }),
               let obj = action.params as? MXDeviceInfo,
               var device_properties = obj.properties {
                if let propertys = device.properties {
                    propertys.forEach { (pItem:MXPropertyInfo) in
                        pItem.value = status as AnyObject
                        if device_properties.first(where: {$0.identifier == pItem.identifier}) == nil {
                            device_properties.append(pItem)
                        }
                    }
                    obj.properties = device_properties
                }
            } else {
                let caInfo = MXSceneTACItem()
                if device.objType == 0 {
                    caInfo.uri = "mx/action/device/property/set"
                } else if device.objType == 1 {
                    caInfo.uri = "mx/action/group/property/set"
                }
                var objParams = MXDeviceInfo()
                if let deviceParams = MXDeviceInfo.mx_keyValue(device), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                    objParams = newDevice
                }
                let propertys = device.productInfo?.properties?.filter({ (pInfo:MXPropertyInfo) in
                    if let identifer = pInfo.identifier, (identifer == "LightSwitch" || identifer.contains("Switch_")) {
                        return true
                    }
                    return false
                })
                propertys?.forEach({ (item:MXPropertyInfo) in
                    item.value = status as AnyObject
                })
                objParams.properties = propertys
                caInfo.params = objParams
                actions.append(caInfo)
            }
        }
        self.sceneInfo.actions = actions
        
        if let detailVC = self.navigationController?.viewControllers.first(where: {$0.isKind(of: MXSceneDetailPage.self)}) as? MXSceneDetailPage {
            detailVC.info = self.sceneInfo
            self.navigationController?.popToViewController(detailVC, animated: true)
        } else {
            var params = [String : Any]()
            params["sceneInfo"] = self.sceneInfo
            MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
        }
    }
    
    func selected(in section: Int) -> Void {
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            room.isSelected = !room.isSelected
            if room.isSelected {
                room.isOpen = true
            }
            room.devices.forEach { device in
                device.isSelected = room.isSelected
            }
            headerView.dataSources = self.dataSources
            self.tableView.reloadData()
        }
    }
    
    func selected(at indexPath: IndexPath) -> Void {
        if self.dataSources.count > indexPath.section {
            let room = self.dataSources[indexPath.section]
            if room.devices.count > indexPath.row {
                let device = room.devices[indexPath.row]
                device.isSelected = !device.isSelected
                
                let subDeviceList = room.devices.filter { (obj:MXDeviceInfo) in
                    if obj.objType == 0, obj.isSameFrom(device), obj.isSubDevice {
                        return true
                    }
                    return false
                }
                if device.isSubDevice {
                    let superDevice = room.devices.first { (obj:MXDeviceInfo) in
                        if obj.objType == 0, obj.isSameFrom(device), !obj.isSubDevice {
                            return true
                        }
                        return false
                    }
                    var subAllSelected = true
                    for sub_dev in subDeviceList {
                        if !sub_dev.isSelected {
                            subAllSelected = false
                        }
                    }
                    superDevice?.isSelected = subAllSelected
                } else {
                    subDeviceList.forEach { (sub_dev:MXDeviceInfo) in
                        sub_dev.isSelected = device.isSelected
                    }
                }
            }
            
            let selectedAmount = room.devices.filter({$0.isSelected}).count
            room.isSelected = selectedAmount == room.devices.count
            headerView.dataSources = self.dataSources
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubviews()
        self.headerView.switchView.didValueChangeCallback = { (status: Int) in
            if status == 1 {
                self.headerView.tipsLabel.text = localized(key: "一键开启选择的设备")
            } else if status == 0 {
                self.headerView.tipsLabel.text = localized(key: "一键关闭选择的设备")
            }
            self.headerView.tipsLabel.isHidden = false
            self.headerView.amountLabel.isHidden = false
            self.tableView.reloadData()
        }
        self.loadDeviceList()
    }
    
    func initSubviews() -> Void {
        self.title = localized(key: "批量打开/关闭设备")
        let rightBarButton = UIButton(type: .custom)
        let font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let color = AppUIConfiguration.NeutralColor.primaryText
        let att = NSAttributedString(string: localized(key: "下一步"), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
        rightBarButton.setAttributedTitle(att, for: .normal)
        rightBarButton.addTarget(self, action: #selector(nextButtonAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBarButton)
        rightBarButton.pin.right(20).vCenter().sizeToFit()
        
        self.contentView.addSubview(tableView)
        headerView.pin.height(230)
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MXSceneDeviceOptionalTableViewCell.self, forCellReuseIdentifier: "MXSceneDeviceOptionalTableViewCell")
        tableView.register(MXSceneDeviceOptionalTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "MXSceneDeviceOptionalTableSectionHeaderView")
        tableView.backgroundColor = UIColor.clear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = .zero
        } else {
            
        }
    }
    
    func loadDeviceList() -> Void {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            if let rvm = self.dataSources.first(where: {$0.roomId == room.roomId}) {
                rvm.devices.append(contentsOf: room.devices.filter({ (device:MXDeviceInfo) in
                    if let pList = device.properties, pList.first(where: {$0.isSupportQuickControl}) != nil {
                        return true
                    }
                    return false
                }))
            } else {
                if let item = room.devices.first {
                    let rvm = MXSceneRoomViewModel(from: item)
                    rvm.devices.append(contentsOf: room.devices.filter({ (device:MXDeviceInfo) in
                        if let pList = device.properties, pList.first(where: {$0.isSupportQuickControl}) != nil {
                            device.isSelected = false
                            return true
                        }
                        return false
                    }))
                    self.dataSources.append(rvm)
                }
            }
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.pin.left(10).right(10).top().bottom()
    }
    
    let tableView = UITableView(frame: .zero)
    let headerView = MXSceneDevicesControlHeaderView(frame: .zero)
    
    var dataSources = [MXSceneRoomViewModel]()
    
}

extension MXSceneDevicesSwitchPage: MXSceneDeviceOptionalTableSectionHeaderViewDelegate {

    func didSelected(at section: Int) {
        selected(in: section)
    }
    
    func didOpen(at section: Int) {
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            room.isOpen = !room.isOpen
            self.tableView.reloadData()
        }
    }
    
}

extension MXSceneDevicesSwitchPage: MXSceneDeviceOptionalTableViewCellDelegate {
    
    func didSelected(at indexPath: IndexPath) {
        selected(at: indexPath)
    }
    
}

extension MXSceneDevicesSwitchPage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MXSceneDeviceOptionalTableSectionHeaderView") as! MXSceneDeviceOptionalTableSectionHeaderView
        view.section = section
        if section == 0 {
            if self.dataSources.count == 1, !self.dataSources[0].isOpen {
                view.round(with: .both, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 60), radius: 16)
            } else {
                view.round(with: .top, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 60), radius: 16)
            }
        } else {
            view.removeRound()
        }
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            view.room = room
            view.delegate = self
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

extension MXSceneDevicesSwitchPage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.headerView.switchView.status == -1 {
            return 0
        }
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            if room.isOpen {
                return room.devices.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneDeviceOptionalTableViewCell", for: indexPath) as! MXSceneDeviceOptionalTableViewCell
        cell.indexPath = indexPath
        if self.dataSources.count > indexPath.section {
            let room = self.dataSources[indexPath.section]
            if room.devices.count > indexPath.row {
                let device = room.devices[indexPath.row]
                cell.device = device
                cell.delegate = self
                
                if indexPath.section == self.dataSources.count - 1 && indexPath.row == room.devices.count - 1 {
                    cell.round(with: .bottom, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                } else {
                    cell.removeRound()
                }
            }
        }
        
        return cell
    }
    
}

extension MXSceneDevicesSwitchPage: MXURLRouterDelegate {
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneDevicesSwitchPage()
        if let info = params["sceneInfo"] as? MXSceneInfo {
            vc.sceneInfo = info
        }
        return vc
    }
}

class MXSceneDevicesControlHeaderView: UIView {
    
    var dataSources: [MXSceneRoomViewModel]? {
        didSet {
            guard let dataSources = dataSources else {
                return
            }
            
            let roomDevicesCount = dataSources.map({$0.devices.count})
            let allDevicesCount = roomDevicesCount.reduce(0, +)
            self.tipsLabel.isHidden = allDevicesCount == 0
            self.amountLabel.isHidden = allDevicesCount == 0
            if allDevicesCount > 0 {
                
                var selectedDevices = [MXDeviceInfo]()
                dataSources.forEach { (room:MXSceneRoomViewModel) in
                    room.devices.forEach { (info:MXDeviceInfo) in
                        if info.isSelected, selectedDevices.first(where: {$0.isSameFrom(info)}) == nil {
                            selectedDevices.append(info)
                        }
                    }
                }
                let allSelectedDevicesCount = selectedDevices.count
                self.amountLabel.text = localized(key: "已选择") + " \(allSelectedDevicesCount) " + localized(key: "个设备")
                self.layoutSubviews()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.addSubview(switchView)
        self.addSubview(tipsLabel)
        self.addSubview(amountLabel)
        tipsLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        tipsLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        amountLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        amountLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        self.tipsLabel.text = localized(key: "一键开启选择的设备")
        self.amountLabel.text = localized(key: "已选择") + " 0 " + localized(key: "个设备")

        self.tipsLabel.isHidden = true
        self.amountLabel.isHidden = true
        switchView.layer.cornerRadius = 16
        switchView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switchView.pin.left().right().top(12).height(160)
        tipsLabel.pin.below(of: switchView).marginTop(20).left(10).sizeToFit()
        amountLabel.pin.below(of: switchView).marginTop(20).right(10).sizeToFit()
    }
    
    let switchView = MXSceneSwitchView(frame: .zero)
    let tipsLabel = UILabel(frame: .zero)
    let amountLabel = UILabel(frame: .zero)
    
}

class MXSceneRoomViewModel: NSObject {
    
    var name = ""
    
    var isSelected = false
    var isOpen = false

    var devices = [MXDeviceInfo]()
    
    var roomId = 0
    
    init(from device: MXDeviceInfo) {
        self.name = device.roomName ?? ""
        self.roomId = device.roomId ?? 0
    }
    
    override init() {
        super.init()
        
    }
    
}


class MXSceneDeviceViewModel: NSObject {
    
    var image = ""
    
    var name = ""
    
    var isSelected = false
    
    var device = MXDeviceInfo()
    
        
    init(device: MXDeviceInfo) {
        self.device = device
        self.image = device.image ?? device.productInfo?.image ?? ""
        self.name = device.showName
    }
    
    override init() {
        super.init()
        
    }
    
}


protocol MXSceneDeviceOptionalTableViewCellDelegate {
    func didSelected(at indexPath: IndexPath) -> Void
}

class MXSceneDeviceOptionalTableViewCell: UITableViewCell {
    
    var device: MXDeviceInfo? {
        didSet {
            self.imageView?.image = nil
            self.nameLabel.text = nil
            guard let newDevice = device else {
                return
            }
            
            if let image = newDevice.image, !newDevice.isSubDevice {
                self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
            } else if let image = newDevice.productInfo?.image, !newDevice.isSubDevice {
                self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
            }
            
            self.nameLabel.text = newDevice.showName
            
            if newDevice.isSubDevice, let propertys = newDevice.properties, let pInfo = propertys.first {
                self.nameLabel.text = (self.nameLabel.text ?? "") + (pInfo.name ?? "")
            }
            
            var statusIcon = ""
            var statusIconColor = UIColor()
            if newDevice.isSelected  {
                statusIcon = "\u{e644}"
                statusIconColor = AppUIConfiguration.MainColor.C0
            } else {
                statusIcon = "\u{e648}"
                statusIconColor = AppUIConfiguration.NeutralColor.disable
            }
            self.statusLabel.text = statusIcon
            self.statusLabel.textColor = statusIconColor
        }
    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.didSelected(at: indexPath)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(statusLabel)
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        statusLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        statusLabel.addGestureRecognizer(tap)
        statusLabel.isUserInteractionEnabled = true
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.pin.left(16).vCenter().width(40).height(40)
        nameLabel.pin.after(of: imgView, aligned: .center).marginLeft(16).sizeToFit()
        statusLabel.pin.right(16).width(24).height(24).vCenter()
    }
    
    let imgView = UIImageView(frame: .zero)
    let nameLabel = UILabel(frame: .zero)
    let statusLabel = UILabel(frame: .zero)
    
    var indexPath = IndexPath(row: 0, section: 0)
    var delegate: MXSceneDeviceOptionalTableViewCellDelegate?
}

protocol MXSceneDeviceOptionalTableSectionHeaderViewDelegate {
    func didSelected(at section: Int) -> Void
    func didOpen(at section: Int) -> Void
}

class MXSceneDeviceOptionalTableSectionHeaderView: UITableViewHeaderFooterView {
    
    var room: MXSceneRoomViewModel? {
        didSet {
            guard let room = room else {
                return
            }
            self.nameLabel.text = room.name
            var statusIcon = ""
            var statusIconColor = UIColor()
            if room.devices.count == 0 {
                statusIcon = "\u{e648}"
                statusIconColor = AppUIConfiguration.NeutralColor.disable
            } else {
                if room.isSelected  {
                    statusIcon = "\u{e644}"
                    statusIconColor = AppUIConfiguration.MainColor.C0
                } else {
                    statusIcon = "\u{e648}"
                    statusIconColor = AppUIConfiguration.NeutralColor.disable
                }
            }
            self.statusLabel.text = statusIcon
            self.statusLabel.textColor = statusIconColor
        }

    }
    
    @objc func tapAction(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.didSelected(at: section)
    }
    
    @objc func viewTap() {
        self.delegate?.didOpen(at: section)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(statusLabel)
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        statusLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        statusLabel.textAlignment = .center
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        self.contentView.addGestureRecognizer(viewTap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(sender:)))
        statusLabel.addGestureRecognizer(tap)
        statusLabel.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.pin.left(16).right(60).top().bottom()
        statusLabel.pin.right(6).width(44).height(44).vCenter()
    }
    
    let nameLabel = UILabel(frame: .zero)
    let statusLabel = UILabel(frame: .zero)
    
    var section = 0
    var delegate: MXSceneDeviceOptionalTableSectionHeaderViewDelegate?
}
