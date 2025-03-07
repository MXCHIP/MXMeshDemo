
import Foundation
import UIKit
import PinLayout

class MXRoomDetailsPage: MXBaseViewController {
    
    let colorGradientLayer = CAGradientLayer()
    var homeId: Int? = MXHomeManager.shard.currentHome?.homeId
    var roomInfo: MXRoomInfo = MXRoomInfo()
    
    var devices = [MXDeviceInfo]()
    
    
    override func gotoBack() {
        if let room = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId})?.rooms.first(where: {$0.roomId == self.roomInfo.roomId}), self.roomInfo != room {
            let alert = MXItemsAlertView(title: localized(key: "未保存，是否退出"),
                                         actionTitles: [localized(key: "保存并退出"),
                                                        localized(key: "退出")],
                                         cancel: localized(key: "取消"),
                                         style: MXItemsAlertView.Style.actionSheet) { index in
                if index == 0 {
                    self.editingRoom()
                } else if index == 1 {
                    super.gotoBack()
                }
            }
            alert.show()
        } else {
            super.gotoBack()
        }
    }
    
    
    @objc func editingRoom() -> Void {
        if let home = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId}), let room = home.rooms.first(where: {$0.roomId == self.roomInfo.roomId}), self.roomInfo != room {
            room.name = self.roomInfo.name
            room.isDefault = self.roomInfo.isDefault
            room.bg_color = self.roomInfo.bg_color
            
            if let defaultRoom = home.rooms.first(where: {$0.isDefault}) {
                room.devices.forEach { (device:MXDeviceInfo) in
                    if self.roomInfo.devices.first(where: {$0.isSameFrom(device)}) == nil {
                        device.roomId = defaultRoom.roomId
                        device.roomName = defaultRoom.name
                        defaultRoom.devices.append(device)
                    }
                }
            }
            room.devices = self.roomInfo.devices
            room.devices.forEach { (device:MXDeviceInfo) in
                device.roomId = room.roomId
                device.roomName = room.name
            }
            home.rooms.forEach { (info:MXRoomInfo) in
                if info.roomId != room.roomId {
                    info.devices.removeAll { (item:MXDeviceInfo) in
                        if self.roomInfo.devices.first(where: {$0.isSameFrom(item)}) != nil {
                            return true
                        }
                        return false
                    }
                }
            }
            
            MXHomeManager.shard.updateHomeList()
        }
        super.gotoBack()
    }
    
    
    @objc func update(sender: UITapGestureRecognizer) -> Void {
        let alert = MXAlertView(title: localized(key: "修改名称"),
                                placeholder: localized(key: "请输入房间名称"),
                                text: self.roomInfo.name,
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) { (textField: UITextField) in
            
        } rightButtonCallBack: { [weak self] (textField: UITextField) in
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                MXToastHUD.showInfo(status: localized(key:"输入不能为空"))
                return
            }
            if MXHomeManager.shard.homeList.first(where: {$0.homeId == self?.homeId})?.rooms.first(where: {$0.name == text }) != nil {
                MXToastHUD.showInfo(status: localized(key:"名称重复"))
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                return
            }
            if let msg = text.toastMessageIfIsInValidRoomName() {
                MXToastHUD.showInfo(status: msg)
                return
            }
            self?.roomInfo.name = text
            DispatchQueue.main.async {
                self?.updateSubviews()
            }
        }
        alert.show()
    }
    
    
    @objc func updateColor(sender: UITapGestureRecognizer) -> Void {
        let url = "https://com.mxchip.bta/page/home/room/wallpapers"
        MXURLRouter.open(url: url, params: nil)
    }
    
    func updateSubviews() -> Void {
        nameLabel.text = self.roomInfo.name
        
        var bgColor = "DFE7F2"
        if let bg_color = self.roomInfo.bg_color, bg_color.count > 0 {
            bgColor = bg_color
        }
        self.colorGradientLayer.colors = [UIColor(hex: bgColor).cgColor, UIColor(hex: bgColor).withAlphaComponent(0.0).cgColor]
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setWallpaper(notification:)), name: NSNotification.Name.init("ROOM_SET_WALLPAPER"), object: nil)
        
        if let homeInfo = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId}) {
            homeInfo.rooms.forEach { (room:MXRoomInfo) in
                if room.roomId != self.roomInfo.roomId {
                    self.devices.append(contentsOf: room.devices)
                }
            }
        }
        
        
        initNavViews()
        
        initSubviews()    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func initNavViews() -> Void {
        
        self.title = localized(key: "房间设置")
        self.view.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        contentView.backgroundColor = AppUIConfiguration.NeutralColor.background

        let rightButton = UIButton()
        let att = NSAttributedString(string: localized(key: "保存"),
                                     attributes: [NSAttributedString.Key.foregroundColor: AppUIConfiguration.NeutralColor.primaryText,
                                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)])
        rightButton.setAttributedTitle(att, for: UIControl.State.normal)
        
        rightButton.addTarget(self, action: #selector(editingRoom), for: UIControl.Event.touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightButton)
        rightButton.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
    }
    
    func initSubviews() -> Void {
        contentView.addSubview(tableView)
        tableView.register(MXRoomDetailsTableViewCell.self, forCellReuseIdentifier: "MXRoomDetailsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        tableView.isEditing = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        let tableHeaderView = UIView()
        tableHeaderView.backgroundColor = UIColor.clear
        tableHeaderView.pin.height(302).width(screenWidth)
        tableView.tableHeaderView = tableHeaderView
        
        let bgViewName = UIView()
        bgViewName.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        tableHeaderView.addSubview(bgViewName)
        bgViewName.pin.left().height(60).width(screenWidth).top(12)
        
        let titleLabel = UILabel()
        bgViewName.addSubview(titleLabel)
        titleLabel.text = localized(key: "房间名称")
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.pin.left(16).height(20).vCenter().sizeToFit(.height)
        
        let arrowLabel = UILabel()
        bgViewName.addSubview(arrowLabel)
        arrowLabel.text = "\u{e6df}"
        arrowLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        arrowLabel.pin.right(16).height(20).width(20).vCenter()
        
        bgViewName.addSubview(nameLabel)
        nameLabel.text = "XXX"
        nameLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        nameLabel.textAlignment = .right
        nameLabel.pin.before(of: arrowLabel, aligned: .center).marginRight(4).height(20).width(200)
                
        let bgViewColor = UIView()
        bgViewColor.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        tableHeaderView.addSubview(bgViewColor)
        bgViewColor.pin.below(of: bgViewName, aligned: .left).marginTop(12).height(206).width(screenWidth)
        
        let colorTitleLabel = UILabel()
        bgViewColor.addSubview(colorTitleLabel)
        colorTitleLabel.text = localized(key: "房间壁纸")
        colorTitleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        colorTitleLabel.textColor = AppUIConfiguration.NeutralColor.title
        colorTitleLabel.pin.left(16).height(20).top(20).sizeToFit(.height)
        
        let colorArrowLabel = UILabel()
        bgViewColor.addSubview(colorArrowLabel)
        colorArrowLabel.text = "\u{e6df}"
        colorArrowLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        colorArrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        colorArrowLabel.pin.right(16).height(20).width(20).top(20)
        
        let bgColor = "DFE7F2"
        self.colorGradientLayer.colors = [UIColor(hex: bgColor).cgColor, UIColor(hex: bgColor).withAlphaComponent(0.0).cgColor]
        colorGradientLayer.locations = [0.0,1.0]
        colorGradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        colorGradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        colorGradientLayer.cornerRadius = 8
        colorGradientLayer.masksToBounds = true
        
        bgViewColor.layer.addSublayer(colorGradientLayer)
        colorGradientLayer.pin.left(16).top(70).right(16).bottom(16)
        
        bgViewName.isUserInteractionEnabled = true
        let tapView = UITapGestureRecognizer(target: self, action: #selector(update(sender:)))
        bgViewName.addGestureRecognizer(tapView)
        
        bgViewColor.isUserInteractionEnabled = true
        let tapColorView = UITapGestureRecognizer(target: self, action: #selector(updateColor(sender:)))
        bgViewColor.addGestureRecognizer(tapColorView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.pin.all()
    }
    
    let nameLabel = UILabel()
    let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateSubviews()
    }
    
    @objc func setWallpaper(notification: NSNotification) -> Void {
        guard let userInfo = notification.userInfo,
              let color = userInfo["color"] as? String else { return }
        self.roomInfo.bg_color = color
        self.colorGradientLayer.colors = [UIColor(hex: color).cgColor, UIColor(hex: color).withAlphaComponent(0.0).cgColor]
        self.navigationController?.popToViewController(self, animated: true)
    }

}

protocol MXRoomDetailsTableViewCellDelegate {
    
    func didSelected(at cell: MXRoomDetailsTableViewCell) -> Void
    
}

class MXRoomDetailsTableViewCell: UITableViewCell {
    
    func updateSubviews(with data: MXDeviceInfo, section: Int, isDefault: Bool = false) -> Void {
        self.data = data
        self.isDefault = isDefault
        self.section = section
        if section == 0 {
            leftIcon.isHidden = true
            leftIcon.isUserInteractionEnabled = false
            roomLabel.isHidden = true
        } else {
            leftIcon.isHidden = false
            leftIcon.isUserInteractionEnabled = true
            roomLabel.isHidden = true
        }
        
        if let product_image = self.data.image, let url = URL(string: product_image) {
            deviceImageView.sd_setImage(with: url, placeholderImage: UIImage(named: product_image), options: .retryFailed, context: nil)
        } else if let product_image = self.data.productInfo?.image, let url = URL(string: product_image) {
            deviceImageView.sd_setImage(with: url, placeholderImage: UIImage(named: product_image), options: .retryFailed, context: nil)
        }
        
        nameLabel.text = self.data.showName
        
        if let room_name = self.data.roomName, room_name.count > 0, section > 0 {
            roomLabel.text = room_name
            roomLabel.isHidden = false
        }
        
        self.layoutSubviews()
    }
    
    @objc func tapLeft(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.didSelected(at: self)
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
        
        self.contentView.addSubview(leftConstraint)
        
        self.contentView.addSubview(leftIcon)
        leftIcon.text = "\u{e6f5}"
        leftIcon.font = UIFont.iconFont(size: AppUIConfiguration.TypographyUndefinedSize.H9)
        leftIcon.textColor = AppUIConfiguration.MainColor.C0
        deviceImageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(deviceImageView)
        deviceImageView.image = UIImage(named: "avatar")
        
        self.contentView.addSubview(nameLabel)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        
        self.contentView.addSubview(roomLabel)
        roomLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        roomLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        
        self.contentView.addSubview(bottomConstraint)
        
        let tapLeftIcon = UITapGestureRecognizer(target: self, action: #selector(tapLeft(sender:)))
        leftIcon.addGestureRecognizer(tapLeftIcon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.isDefault {
            if self.section == 0 {
                leftConstraint.pin.left(-40).width(0.01).height(0.01).vCenter()
            } else {
                leftConstraint.pin.left().width(0.01).height(0.01).vCenter()
            }
        } else {
            leftConstraint.pin.left().width(0.01).height(0.01).vCenter()
        }
        leftIcon.pin.left(17).width(22).height(22).vCenter()
        deviceImageView.pin.after(of: visible([leftConstraint, leftIcon]), aligned: .center).marginLeft(18).width(40).height(40)
        bottomConstraint.pin.after(of: deviceImageView).marginLeft(8).bottom(28).width(0.01).height(0.01)
        roomLabel.pin.after(of: deviceImageView, aligned: .bottom).marginLeft(8).width(220).height(16)
        nameLabel.pin.above(of: visible([bottomConstraint, roomLabel]), aligned: .left).marginBottom(4).width(220).height(16)
    }

    let leftConstraint = UIView()
    let leftIcon = UILabel()
    let deviceImageView = UIImageView()
    let nameLabel = UILabel()
    let roomLabel = UILabel()
    let bottomConstraint = UIView()
    var delegate: MXRoomDetailsTableViewCellDelegate?
    var data = MXDeviceInfo()
    var isDefault:Bool = false
    var section = 0
    
}

extension MXRoomDetailsPage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView()
            view.backgroundColor = AppUIConfiguration.NeutralColor.background
            let titileLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width - 32, height: 50))
            view.addSubview(titileLabel)
            titileLabel.text = localized(key: "不在此房间的设备")
            titileLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
            titileLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension MXRoomDetailsPage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.roomInfo.devices.count
        }
        
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXRoomDetailsTableViewCell", for: indexPath) as! MXRoomDetailsTableViewCell
        
        var dataSource: [MXDeviceInfo] = self.devices
        if indexPath.section == 0 {
            dataSource = self.roomInfo.devices
        }
        if dataSource.count > indexPath.row {
            var data = dataSource[indexPath.row]
            cell.updateSubviews(with: data, section: indexPath.section, isDefault: self.roomInfo.isDefault)
        }
        cell.delegate = self
        return cell
    }
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if self.roomInfo.isDefault {
            return .none
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        if self.roomInfo.devices.count <= indexPath.row {
            return
        }
        
        let device = self.roomInfo.devices[indexPath.row]
        self.roomInfo.devices.remove(at: indexPath.row)
        self.devices.append(device)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if destinationIndexPath.section > 0 || sourceIndexPath.section > 0 {
            return
        }
        if self.roomInfo.devices.count > sourceIndexPath.row {
            let moveItem = self.roomInfo.devices[sourceIndexPath.row]
            self.roomInfo.devices.remove(at: sourceIndexPath.row)
            if self.roomInfo.devices.count >= destinationIndexPath.row {
                self.roomInfo.devices.insert(moveItem, at: destinationIndexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section{
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
}

extension MXRoomDetailsPage: MXRoomDetailsTableViewCellDelegate {
    
    func didSelected(at cell: MXRoomDetailsTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if self.devices.count <= indexPath.row {
            return
        }
        let device = self.devices[indexPath.row]
        
        var message: String = ""
        if let room_name = device.roomName, room_name.count > 0 {
            message = localized(key: "该设备已添加到") + "“" + room_name + "”，" + localized(key: "确认要移动到当前房间吗？")
        }
        let alert = MXAlertView(title: localized(key: "确定要移动到该房间吗？"),
                                message: message,
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) {
            
        } rightButtonCallBack: {
            self.devices.remove(at: indexPath.row)
            self.roomInfo.devices.append(device)
            self.tableView.reloadData()
        }
        
        alert.show()
    }
}

extension MXRoomDetailsPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXRoomDetailsPage()
        if let home_id = params["homeId"] as? Int {
            vc.homeId = home_id
        }
        if let info = params["info"] as? MXRoomInfo, let roomParams = MXRoomInfo.mx_keyValue(info), let room = MXRoomInfo.mx_Decode(roomParams)  {
            vc.roomInfo = room
        }
        return vc
    }
    
}
