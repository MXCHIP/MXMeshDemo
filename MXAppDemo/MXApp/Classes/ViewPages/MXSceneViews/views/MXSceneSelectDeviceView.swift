
import Foundation
import UIKit

class MXSceneSelectDeviceView: UIView {
    public typealias SelectActionCallback = (_ device: MXDeviceInfo) -> ()
    public var selectCallback : SelectActionCallback?
    var contentView: UIView!
    
    var pageNo : Int = 1
    var sceneType: String = "one_click"
    var isTrigger: Bool = false
    
    var dataList = [[MXDeviceInfo]]() {
        didSet {
            self.refreshContent()
        }
    }
    
    var selectedList = [MXDeviceInfo]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func refreshContent() {
        self.layoutSubviews()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadDeviceList() {
        if isTrigger {
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
        } else {
            self.dataList.removeAll()
            MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
                let device_list = room.devices.filter({$0.properties?.first(where: {$0.isSupportLocalAutoAction}) != nil})
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
    }
    
    public var titleStr : String? {
        didSet {
            self.titleLB.text = titleStr
        }
    }
    
    convenience init(sceneType: String, isTrigger: Bool = false) {
        self.init(frame: .zero)
        self.sceneType = sceneType
        self.isTrigger = isTrigger
        
        if sceneType == "local_auto" {
            
            NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        }
        
        self.loadDeviceList()
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH : CGFloat = 262
        self.contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - viewH, width: UIScreen.main.bounds.width, height: viewH))
        self.contentView = UIView(frame: frame)
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.addSubview(self.contentView)
        
        self.contentView.addSubview(self.titleLB)
        self.titleLB.pin.left(0).top(0).right(0).height(52)
        
        self.titleLB.addSubview(self.lineView)
        self.lineView.pin.left().right().bottom().height(1)
        
        self.contentView.addSubview(self.actionBtn)
        self.actionBtn.pin.width(44).height(44).right(14).top(4)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.titleLB).marginTop(0).left().right().bottom()
        
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无设备")
        self.tableView.emptyView = mxEmptyView
        
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.refreshContent()
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var dataCount = 0
        for subList in self.dataList {
            dataCount += subList.count
        }
        var contentH = 52 + (CGFloat(self.dataList.count) * 50) + (CGFloat(dataCount) * 80)
        if contentH > 532  {
            contentH = 532
        } else if contentH < 262 {
            contentH = 262
        }
        self.contentView.pin.left().right().bottom().height(contentH + self.pin.safeArea.bottom)
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.titleLB.pin.left(0).top(0).right(0).height(52)
        self.lineView.pin.left().right().bottom().height(1)
        self.actionBtn.pin.width(44).height(44).right(14).top(4)
        self.tableView.pin.below(of: self.titleLB).marginTop(0).left().right().bottom()
        var footerH:CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            footerH = self.pin.safeArea.bottom
        }
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: footerH))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.title;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"选择设备")
        return _titleLB
    }()
    
    lazy var lineView : UIView = {
        let _lineView = UILabel(frame: .zero)
        _lineView.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        return _lineView
    }()
    
    lazy public var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _actionBtn.setTitle("\u{e721}", for: .normal)
        _actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        _actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        return _actionBtn
    }()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: .zero, style: UITableView.Style.grouped)
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
    
    
    func show() -> Void {
        if self.superview != nil {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
        self.pin.left().right().top().bottom()
    }
    
    
    func dismiss() -> Void {
        self.removeFromSuperview()
    }
    
    @objc func didAction() {
        self.dismiss()
    }
    
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MXSceneSelectDeviceView: UITableViewDelegate, UITableViewDataSource {
    
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
                self.selectCallback?(info)
                self.dismiss()
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
