//
//  MXLinkageSelectedDevicesView.swift
//  MXApp
//
//  Created by mxchip on 2023/10/25.
//

import Foundation

class MXLinkageSelectedDevicesView: UIView {
    
    typealias deviceListCallBack = (_ devices: [MXDeviceInfo]) -> ()
    var nextCallBack: deviceListCallBack?
    
    var dataSources = [MXRoomInfo]()
    var selectedDevices = [MXDeviceInfo]()
    
    let tableHeaderView = UIView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let cancelLabel = UILabel(frame: .zero)
    let nextLabel = UILabel(frame: .zero)
    let lineView = UIView(frame: .zero)
    let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
    
    @objc func cancelAction(sender: UITapGestureRecognizer) -> Void {
        self.removeFromSuperview()
    }
    
    @objc func nextAction(sender: UITapGestureRecognizer) -> Void {
        
        let selectedDevices = self.dataSources.map { rvm in
            return rvm.devices.filter({$0.isSelected})
        }.flatMap({$0})
                
        self.removeFromSuperview()
        self.nextCallBack?(selectedDevices)
    }
    
    func show(in view: UIView, with devices: [MXDeviceInfo]? = nil, selected: @escaping (_ devices: [MXDeviceInfo]) -> Void ) -> Void {
        view.addSubview(self)
        if let newList = devices {
            self.selectedDevices = newList
        }
        self.loadDeviceList()
        self.nextCallBack = selected
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubViews() -> Void {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.addSubview(tableHeaderView)
        self.tableHeaderView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 52)
        tableHeaderView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 12)
        
        tableHeaderView.addSubview(titleLabel)
        tableHeaderView.addSubview(cancelLabel)
        tableHeaderView.addSubview(nextLabel)
        tableHeaderView.addSubview(lineView)
        self.addSubview(tableView)
        tableView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(MXSceneSelectDeviceTableViewCell.self, forCellReuseIdentifier: "MXSceneSelectDeviceTableViewCell")
        tableView.register(MXSceneSelectDeviceTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: "MXSceneSelectDeviceTableViewHeaderView")
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        self.tableView.emptyView = mxEmptyView
        
        titleLabel.text = "添加灯设备"
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        cancelLabel.text = "取消"
        cancelLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        cancelLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        nextLabel.text = "确定"
        nextLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        nextLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        lineView.backgroundColor = AppUIConfiguration.lineColor.XX0FEEEEEE
        cancelLabel.isUserInteractionEnabled = true
        nextLabel.isUserInteractionEnabled = true
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(cancelAction(sender:)))
        cancelLabel.addGestureRecognizer(cancelGesture)
        let nextGesture = UITapGestureRecognizer(target: self, action: #selector(nextAction(sender:)))
        nextLabel.addGestureRecognizer(nextGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.all()
        self.tableHeaderView.pin.top(177).left().right().height(52)
        self.tableView.pin.below(of: tableHeaderView).left().right().bottom()
        self.tableView.emptyView?.pin.all()
        titleLabel.pin.center().sizeToFit()
        cancelLabel.pin.left(24).vCenter().sizeToFit()
        nextLabel.pin.right(24).vCenter().sizeToFit()
        lineView.pin.left().right().bottom().height(1)
    }
    
}

extension MXLinkageSelectedDevicesView {
    
    func loadDeviceList() {
        var list = [MXRoomInfo]()
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            var roomDevices = room.devices.filter({ (device:MXDeviceInfo) in
                let categoryId = device.productInfo?.category_id ?? 0
                if categoryId >= 100101, categoryId <= 100106 {
                    return true
                }
                return false
            })
            if roomDevices.count > 0 {
                var item = MXRoomInfo()
                item.name = room.name
                item.roomId = room.roomId
                item.devices = roomDevices
                list.append(item)
            }
        })
        self.dataSources = list
        for rvm in self.dataSources {
            for device in rvm.devices {
                if self.selectedDevices.first(where: { (item:MXDeviceInfo) in
                    if item.isSameFrom(item) {
                        return true
                    }
                    return false
                }) != nil {
                    device.isSelected = true
                }
            }
        }
        self.tableView.reloadData()
    }
}


extension MXLinkageSelectedDevicesView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            return room.devices.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXLinkageSelectedDeviceCell", for: indexPath) as! MXLinkageSelectedDeviceCell
        if self.dataSources.count > indexPath.section {
            let room = self.dataSources[indexPath.section]
            let device = room.devices[indexPath.row]
            cell.info = device
            cell.actiontCallback = { info in
                if let uuid = info?.meshInfo?.uuid, uuid.count > 0 {
                    MeshSDK.sharedInstance.sendMeshMessage(opCode: "12", uuid: uuid, message: "000102")
                }
            }
            
        }
        return cell
    }

}

extension MXLinkageSelectedDevicesView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSources.count > indexPath.section {
            let room = dataSources[indexPath.section]
            if room.devices.count > indexPath.row {
                let dev = room.devices[indexPath.row]
                dev.isSelected = !dev.isSelected
//                if room.devices.count > 0 {
//                    let selectedDevices = room.devices.filter({$0.isSelected})
//                    let ifSelectedAll = selectedDevices.count == room.devices.count
//                    room.isSelected = ifSelectedAll
//                }
                //self.tableView.reloadData()
                self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MXLinkageSelectedDeviceHeaderView") as! MXLinkageSelectedDeviceHeaderView
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            view.room = room
        }
        view.selectObjectCallback = { [weak self] info in
            self?.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}


class MXLinkageSelectedDeviceCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ item: MXDeviceInfo?) -> ()
    public var actiontCallback : DidActionCallback?
    
    let leftIcon = UIButton(type: .custom)
    let imgView = UIImageView(frame: .zero)
    let nameLabel = UILabel(frame: .zero)
    let opLabel = UILabel(frame: .zero)
    
    var info: MXDeviceInfo? {
        didSet {
            self.imgView.image = nil
            self.nameLabel.text = nil
            
            if let newInfo = info {
                if let image = newInfo.image {
                    self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
                } else if let image = newInfo.productInfo?.image {
                    self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
                }
                if let name = newInfo.name, name.count > 0 {
                    self.nameLabel.text = name
                } else if let name = newInfo.productInfo?.name {
                    self.nameLabel.text = name
                }
            }
            if let isSelected = info?.isSelected, isSelected {
                opLabel.text = "\u{e644}"
            } else {
                opLabel.text = "\u{e648}"
            }
        }
    }
    
    @objc func swithAction() {
        self.actiontCallback?(self.info)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubviews() -> Void {
        self.selectionStyle = .none
        self.contentView.addSubview(self.leftIcon)
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(opLabel)
        
        self.leftIcon.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.leftIcon.backgroundColor = UIColor(hex: AppUIConfiguration.MainColor.C0.toHexString, alpha: 0.1)
        self.leftIcon.layer.cornerRadius = 16
        self.leftIcon.titleLabel?.font = UIFont(name: "iconfont", size: 16)
        self.leftIcon.setTitle("\u{e749}", for: .normal)
        self.leftIcon.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        
        self.leftIcon.addTarget(self, action: #selector(swithAction), for: .touchUpInside)
        
        
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        
        opLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        self.opLabel.textColor = AppUIConfiguration.MainColor.C0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.leftIcon.pin.left(12).width(32).height(32).vCenter()
        imgView.pin.right(of: self.leftIcon).marginLeft(8).vCenter().width(40).height(40)
        opLabel.pin.right(20).vCenter().width(24).height(24)
        nameLabel.pin.after(of: imgView, aligned: .center).marginLeft(12).left(of: self.opLabel).marginRight(8)
    }
    
}

class MXLinkageSelectedDeviceHeaderView: UITableViewHeaderFooterView {
    
    public typealias SelectObjectsCallback = (_ item: MXRoomInfo?) -> ()
    public var selectObjectCallback : SelectObjectsCallback?
    
    let nameLabel = UILabel(frame: .zero)
    let opLabel = UIButton(type: .custom)
        
    var room: MXRoomInfo? {
        didSet {
            guard let room = room else {
                return
            }
            nameLabel.text = room.name
                        
            room.isSelected = room.devices.filter({$0.isSelected == true}).count == room.devices.count
            
            if room.isSelected {
                self.opLabel.setTitle("\u{e644}", for: .normal)
            } else {
                self.opLabel.setTitle("\u{e648}", for: .normal)
            }
            
        }
    }
    
    @objc func selectUpdated() -> Void {
        if let isSelected = self.room?.isSelected {
            self.room?.isSelected = !isSelected
            self.room?.devices.forEach({ (device:MXDeviceInfo) in
                device.isSelected = !isSelected
            })
            self.selectObjectCallback?(self.room)
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubviews() -> Void {
        self.backgroundView = UIView()
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(opLabel)
        self.nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        self.nameLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
        
        self.opLabel.titleLabel?.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        self.opLabel.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        self.opLabel.addTarget(self, action: #selector(selectUpdated), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let bgv = self.backgroundView {
            bgv.pin.all()
        }
        nameLabel.pin.left(16).vCenter().sizeToFit()
        opLabel.pin.right(30).width(40).top().bottom()
    }
    
}
