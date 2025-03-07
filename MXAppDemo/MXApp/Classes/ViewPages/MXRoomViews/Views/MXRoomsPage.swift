
import Foundation
import UIKit
import PinLayout

class MXRoomsPage: MXBaseViewController {
    
    public var dataSource = [MXRoomInfo]()
    public var homeId : Int? = MXHomeManager.shard.currentHome?.homeId
    public var ifEditing: Bool = false
    
    
    @objc func editingRoom(sender: UIButton) -> Void {
        sender.isSelected = !sender.isSelected
        self.ifEditing = sender.isSelected
        self.tableView.isEditing = self.ifEditing
        if !self.ifEditing {
            if let homeInfo = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId}) {
                homeInfo.rooms = self.dataSource
                MXHomeManager.shard.updateHomeList()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
            }
        }
        self.tableView.reloadData()
    }
    
    
    @objc func createRoom(sender: UITapGestureRecognizer) -> Void {
        let url = "https://com.mxchip.bta/page/room/create"
        var params = [String : Any]()
        params["homeId"] = self.homeId
        MXURLRouter.open(url: url, params: params)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviews()
    }
    
    func initSubviews() -> Void {
        self.title = localized(key: "房间管理")
        self.view.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        contentView.backgroundColor = AppUIConfiguration.NeutralColor.background
        
        let rightButton = UIButton()
        let att = NSAttributedString(string: localized(key: "编辑"),
                                     attributes: [NSAttributedString.Key.foregroundColor: AppUIConfiguration.NeutralColor.primaryText,
                                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)])
        rightButton.setAttributedTitle(att, for: UIControl.State.normal)
        
        let attSelected = NSAttributedString(string: localized(key: "完成"),
                                     attributes: [NSAttributedString.Key.foregroundColor: AppUIConfiguration.NeutralColor.primaryText,
                                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)])
        rightButton.setAttributedTitle(attSelected, for: UIControl.State.selected)
        
        rightButton.addTarget(self, action: #selector(editingRoom(sender:)), for: UIControl.Event.touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightButton)
        rightButton.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.contentView.addSubview(bottomView)
        self.bottomView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.bottomView.addSubview(createRoomLabel)
        createRoomLabel.textAlignment = .center
        
        let homeIcon = "\u{e710}"
        let homeTitle = localized(key: "新建房间")
        let homeString = homeIcon + "  " + homeTitle
        let homeAtt = NSMutableAttributedString(string: homeString,
                                                attributes: [NSAttributedString.Key.font: UIFont(name: "PingFang-SC-Regular",
                                                                                                 size: AppUIConfiguration.TypographySize.H2) ?? UIFont(),
                                                             NSAttributedString.Key.foregroundColor: AppUIConfiguration.MainColor.C0])
        if let range = homeString.nsRange(of: homeIcon) {
            homeAtt.setAttributes([NSAttributedString.Key.font: UIFont(name: "iconfont",
                                                                       size: AppUIConfiguration.TypographySize.H1) ?? UIFont(),
                                   NSAttributedString.Key.baselineOffset: -3,
                                   NSAttributedString.Key.foregroundColor : AppUIConfiguration.MainColor.C0], range: range)
            createRoomLabel.attributedText = homeAtt
        }
        
        createRoomLabel.isUserInteractionEnabled = true
        let tapCreateRoomLabel = UITapGestureRecognizer(target: self, action: #selector(createRoom(sender:)))
        createRoomLabel.addGestureRecognizer(tapCreateRoomLabel)
        
        contentView.addSubview(tableView)
        tableView.register(MXRoomsTableViewCell.self, forCellReuseIdentifier: "MXRoomsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = AppUIConfiguration.NeutralColor.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let homeInfo = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId}) {
            self.dataSource = homeInfo.rooms
        }
        self.tableView.reloadData()
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bottomView.pin.left().right().bottom().height(64 + self.view.pin.safeArea.bottom)
        createRoomLabel.pin.left().right().top().height(64)
        tableView.pin.above(of: createRoomLabel).left().right().top(12).marginBottom(0)
    }
    
    
    let bottomView = UIView(frame: .zero)
    let createRoomLabel = UILabel(frame: .zero)
    let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
        
}

class MXRoomsTableViewCell: UITableViewCell {
    
    func updateSubviws(with data: MXRoomInfo, ifEditing: Bool = false) -> Void {
        
        self.nameLabel.text = data.name
        
        self.countLabel.text = String(data.devices.count) + localized(key: "个设备")
        
        rightIcon.isHidden = ifEditing
        
        if ifEditing {
            rightIcon.text = "\u{e713}"
        } else {
            rightIcon.text = "\u{e6df}"
        }
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
        self.selectionStyle = .none
        
        contentView.addSubview(nameLabel)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        
        contentView.addSubview(rightConstraint)
        
        contentView.addSubview(rightIcon)
        rightIcon.text = "\u{e713}"
        rightIcon.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        rightIcon.textColor = AppUIConfiguration.NeutralColor.disable
        
        contentView.addSubview(countLabel)
        countLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        countLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        countLabel.textAlignment = .right
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.pin.left(16).height(20).width(180).vCenter()
        rightConstraint.pin.right(8).width(0.001).height(0.001).vCenter()
        rightIcon.pin.right(16).width(20).height(20).vCenter()
        countLabel.pin.before(of: visible([rightIcon, rightConstraint]), aligned: .center).marginRight(4).height(20).width(80)
    }
        
    let nameLabel = UILabel()
    let countLabel = UILabel()
    let rightIcon = UILabel()
    let rightConstraint = UIView()
}


extension MXRoomsPage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.ifEditing
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if self.dataSource.count <= indexPath.row {
            return .none
        }
        let room = self.dataSource[indexPath.row]
        if room.isDefault {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard self.dataSource.count > sourceIndexPath.row else {
            return
        }
        let source = self.dataSource[sourceIndexPath.row]
        self.dataSource.remove(at: sourceIndexPath.row)
        self.dataSource.insert(source, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSource.count > indexPath.row {
            let room = self.dataSource[indexPath.row]
            
            var params = [String: Any]()
            params["info"] = room
            params["homeId"] = self.homeId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/home/roomDetails", params: params)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        if self.dataSource.count <= indexPath.row {
            return
        }
        let room = self.dataSource[indexPath.row]
        if room.isDefault {
            MXToastHUD.showError(status: localized(key: "默认房间不能删除"))
            return
        }
        
        let alert = MXAlertView(title: localized(key: "确定要删除房间吗？"),
                                message: localized(key: "删除房间提示描述"),
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) {
            
        } rightButtonCallBack: {
            if let homeInfo = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId}), let defaultRoom = homeInfo.rooms.first(where: {$0.isDefault}) {
                room.devices.forEach { (device:MXDeviceInfo) in
                    device.roomId = defaultRoom.roomId
                    device.roomName = defaultRoom.name
                    defaultRoom.devices.append(device)
                }
                homeInfo.rooms.removeAll(where: {$0.roomId == room.roomId})
                
                MXHomeManager.shard.updateHomeList()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
            }
            self.dataSource.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        
        alert.show()
    }
    
}

extension MXRoomsPage: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXRoomsTableViewCell", for: indexPath) as! MXRoomsTableViewCell
        if self.dataSource.count > indexPath.row {
            let room = self.dataSource[indexPath.row]
            cell.updateSubviws(with: room, ifEditing: self.ifEditing)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension MXRoomsPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXRoomsPage()
        if let home_id = params["homeId"] as? Int {
            vc.homeId = home_id
        }
        return vc
    }
}
