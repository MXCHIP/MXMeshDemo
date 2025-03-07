
import Foundation
import UIKit

class MXSceneDevicesSelectRoomViewModel: NSObject {
    
    var ifSelected = false
    
    var name = ""
    
    var roomId = 0
    
    var devices = [MXDeviceInfo]()
    
    
    init(from device: MXDeviceInfo) {
        self.name = device.roomName ?? ""
        self.roomId = device.roomId ?? 0
    }
    
}

class MXSceneDevicesSelectDeviceViewModel: NSObject {
    
    var ifSelected = false
    
    var image = ""
    
    var name = ""
    
    var uuid: String?
    
    var roomName = ""
    
    var roomId = 0
    
    var device = MXDeviceInfo()
    
    init(with device: MXDeviceInfo) {
        self.device = device
        self.name = device.showName
        
        if let image = device.image, image.count > 0 {
            self.image = image
        } else if let image = device.productInfo?.image, image.count > 0 {
            self.image = image
        }
        self.roomId = device.roomId ?? 0
        self.roomName = device.roomName ?? ""
    }
    
}

class MXSceneSelectDeviceViewV2: UIView {
    
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
    
    func show(in view: UIView, with devices: [MXDeviceInfo]? = nil, properties:[MXPropertyInfo]? = nil, selected: @escaping (_ devices: [MXDeviceInfo]) -> Void ) -> Void {
        view.addSubview(self)
        if let newList = devices {
            self.selectedDevices = newList
        }
        self.filterRole = 0
        if let pList = properties {
            if pList.first(where: {($0.identifier == "HSVColor" || $0.identifier == "HSVColorHex") && $0.value != nil}) != nil {
                self.filterRole = 2
            } else if pList.first(where: {$0.identifier == "ColorTemperature" && $0.value != nil}) != nil {
                self.filterRole = 1
            }
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
        
        titleLabel.text = localized(key: "添加设备")
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        cancelLabel.text = localized(key: "取消")
        cancelLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        cancelLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        nextLabel.text = localized(key: "下一步")
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
    
    typealias deviceListCallBack = (_ devices: [MXDeviceInfo]) -> ()
    var nextCallBack: deviceListCallBack?
    
    var dataSources = [MXSceneDevicesSelectRoomViewModel]()
    var pageNo = 1
    var selectedDevices = [MXDeviceInfo]()
    var filterRole: Int = 0 
    
    let tableHeaderView = UIView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let cancelLabel = UILabel(frame: .zero)
    let nextLabel = UILabel(frame: .zero)
    let lineView = UIView(frame: .zero)
    let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
    
}

extension MXSceneSelectDeviceViewV2 {
    
    func loadDeviceList() {
        var list = [MXDeviceInfo]()
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            let roomDevices = room.devices.filter({ (device:MXDeviceInfo) in
                let categoryId = device.productInfo?.category_id ?? 0
                if self.filterRole == 2 {
                    if categoryId == 100104 ||
                        categoryId == 100105 ||
                        categoryId == 100106 ||
                        device.properties?.first(where: {$0.identifier == "HSVColor" || $0.identifier == "HSVColorHex"}) != nil {
                        return true
                    }
                } else if self.filterRole == 1 {
                    if categoryId == 100103 ||
                        categoryId == 100104 ||
                        device.properties?.first(where: {$0.identifier == "ColorTemperature"}) != nil {
                        return true
                    }
                } else if categoryId >= 100103, categoryId <= 100106 {
                    return true
                }
                return false
            })
            list.append(contentsOf: roomDevices)
        })
        for item  in list {
            item.isSelected = false
            if let rvm = self.dataSources.first(where: {$0.roomId == item.roomId}) {
                rvm.devices.append(item)
            } else {
                let rvm = MXSceneDevicesSelectRoomViewModel(from: item)
                rvm.devices.append(item)
                self.dataSources.append(rvm)
            }
        }
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


extension MXSceneSelectDeviceViewV2: UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneSelectDeviceTableViewCell", for: indexPath) as! MXSceneSelectDeviceTableViewCell
        if self.dataSources.count > indexPath.section {
            let room = self.dataSources[indexPath.section]
            let device = room.devices[indexPath.row]
            cell.info = device
            
        }
        return cell
    }

}

extension MXSceneSelectDeviceViewV2: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSources.count > indexPath.section {
            let room = dataSources[indexPath.section]
            if room.devices.count > indexPath.row {
                let dev = room.devices[indexPath.row]
                dev.isSelected = !dev.isSelected
                if room.devices.count > 0 {
                    let selectedDevices = room.devices.filter({$0.isSelected})
                    let ifSelectedAll = selectedDevices.count == room.devices.count
                    room.ifSelected = ifSelectedAll
                }
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MXSceneSelectDeviceTableViewHeaderView") as! MXSceneSelectDeviceTableViewHeaderView
        view.delegate = self
        view.section = section
        if self.dataSources.count > section {
            let room = self.dataSources[section]
            view.room = room
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension MXSceneSelectDeviceViewV2: MXSceneSelectDeviceTableViewHeaderViewDelegate {
    
    func didSelected(section: Int) {
        if self.dataSources.count > section {
            let room = dataSources[section]
            room.ifSelected = !room.ifSelected
            room.devices.forEach { dvm in
                dvm.isSelected = room.ifSelected
            }
            self.tableView.reloadData()
        }
    }
    
}


class MXSceneSelectDeviceTableViewCell: UITableViewCell {
    
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
                self.nameLabel.text = newInfo.showName
            }
            if let isSelected = info?.isSelected, isSelected {
                opLabel.text = "\u{e644}"
            } else {
                opLabel.text = "\u{e648}"
            }
            
            layoutSubviews()
        }
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
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(opLabel)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        
        opLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        self.opLabel.textColor = AppUIConfiguration.MainColor.C0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.pin.left(26).vCenter().width(40).height(40)
        nameLabel.pin.after(of: imgView, aligned: .center).marginLeft(16).sizeToFit()
        if self.isOnLine {
            opLabel.pin.right(30).vCenter().width(24).height(24)
        } else {
            opLabel.pin.right(30).vCenter().sizeToFit()
        }
    }
    
    
    let imgView = UIImageView(frame: .zero)
    let nameLabel = UILabel(frame: .zero)
    let opLabel = UILabel(frame: .zero)
    
    var isOnLine = false
    
}

protocol MXSceneSelectDeviceTableViewHeaderViewDelegate {
    
    func didSelected(section: Int) -> Void
    
}

class MXSceneSelectDeviceTableViewHeaderView: UITableViewHeaderFooterView {
        
    var room: MXSceneDevicesSelectRoomViewModel? {
        didSet {
            guard let room = room else {
                return
            }
            nameLabel.text = room.name
                        
            let allSelected = room.devices.filter({$0.isSelected == true}).count == room.devices.count
            
            if allSelected {
                self.opLabel.text = "\u{e644}"
            } else {
                self.opLabel.text = "\u{e648}"
            }
            
        }
    }
    
    var section = 0

    @objc func selectUpdated(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.didSelected(section: section)
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
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        self.nameLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
        opLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        self.opLabel.textColor = AppUIConfiguration.MainColor.C0
        
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        self.backgroundView!.isUserInteractionEnabled = true
        self.opLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectUpdated(sender:)))
        self.opLabel.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let bgv = self.backgroundView {
            bgv.pin.all()
        }
        nameLabel.pin.left(16).vCenter().sizeToFit()
        opLabel.pin.right(30).vCenter().width(24).height(24)
    }
    
    let nameLabel = UILabel(frame: .zero)
    let opLabel = UILabel(frame: .zero)
    
    var delegate: MXSceneSelectDeviceTableViewHeaderViewDelegate?
    
}
