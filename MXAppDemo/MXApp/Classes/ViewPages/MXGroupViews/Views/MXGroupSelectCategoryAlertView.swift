
import Foundation
import UIKit

class MXGroupSelectCategoryAlertView: UIView {
    
    @objc func cancelAction(sender: UITapGestureRecognizer) -> Void {
        self.removeFromSuperview()
    }
    
    @objc func nextAction(sender: UITapGestureRecognizer) -> Void {
        
        let devices = dataList.values.reduce([], +)
        let selectedDevices = devices.filter({$0.isSelected == true})
        if selectedDevices.count == 0 {
            return
        }
        
        self.removeFromSuperview()
        self.nextCallBack?(selectedDevices)
    }
    
    func show(in view: UIView, category_id: Int, info: MXDeviceInfo? = nil, selectedDevices: [MXDeviceInfo]? = nil, selected: @escaping (_ devices: [MXDeviceInfo]) -> Void ) -> Void {
        self.category_id = category_id
        self.group = info
        self.selectedDevices = selectedDevices
        self.nextCallBack = selected
        view.addSubview(self)
        mxDataSource()
    }
    
    func mxDataSource() {
        var list = [Int:[MXDeviceInfo]]()
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            var subList = [MXDeviceInfo]()
            var newList = [MXDeviceInfo]()
            if self.group?.meshInfo?.meshAddress != nil, self.group?.roomId == room.roomId, let subList = self.group?.subDevices {
                newList.append(contentsOf: subList)
            }
            room.devices.forEach { (device:MXDeviceInfo) in
                if device.objType == 0, (device.category_id == self.category_id || device.productInfo?.category_id == self.category_id) {
                    newList.append(device)
                }
            }
            newList.forEach { (device:MXDeviceInfo) in
                device.isSelected = false
                if self.selectedDevices?.first(where: {$0.isSameFrom(device)}) != nil {
                    device.isSelected = true
                }
                device.roomId = room.roomId
                device.roomName = room.name
                subList.append(device)
            }
            if subList.count > 0 {
                list[room.roomId] = subList
            }
        })
        self.dataList = list
        self.tableView.reloadData()
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
        tableHeaderView.round(with: .top, rect: CGRect(x: 0, y: 0, width: screenWidth, height: 52), radius: 12)
        
        tableHeaderView.addSubview(titleLabel)
        tableHeaderView.addSubview(cancelLabel)
        tableHeaderView.addSubview(nextLabel)
        tableHeaderView.addSubview(lineView)
        self.addSubview(tableView)
        tableView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(MXGroupSelectCategoryTableViewCell.self, forCellReuseIdentifier: "MXGroupSelectCategoryTableViewCell")
        tableView.register(MXGroupSelectCategoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: "MXGroupSelectCategoryTableViewHeaderView")
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
    
    var category_id: Int! 
    var group: MXDeviceInfo?   
    var selectedDevices: [MXDeviceInfo]?
    var dataList = [Int:[MXDeviceInfo]]()
    
    let tableHeaderView = UIView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let cancelLabel = UILabel(frame: .zero)
    let nextLabel = UILabel(frame: .zero)
    let lineView = UIView(frame: .zero)
    let tableView = UITableView(frame: .zero, style: UITableView.Style.grouped)
    
}


extension MXGroupSelectCategoryAlertView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let keys = Array(self.dataList.keys)
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keys = Array(self.dataList.keys)
        if keys.count > section {
            let key = keys[section]
            if let devices = self.dataList[key] {
                return devices.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXGroupSelectCategoryTableViewCell", for: indexPath) as! MXGroupSelectCategoryTableViewCell
        let keys = Array(self.dataList.keys)
        if keys.count > indexPath.section {
            let key = keys[indexPath.section]
            if let devices = self.dataList[key] {
                if devices.count > indexPath.row {
                    let device = devices[indexPath.row]
                    cell.info = device
                }
                
                if indexPath.row == 0 {
                    if devices.count == 1 {
                        cell.round(with: .both, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                    } else {
                        cell.round(with: .top, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                    }
                } else {
                    if indexPath.row == devices.count - 1 {
                        cell.round(with: .bottom, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                    } else {
                        cell.removeRound()
                    }
                }
                
            }
        }
        
        return cell
    }

}

extension MXGroupSelectCategoryAlertView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = Array(self.dataList.keys)
        if keys.count > indexPath.section {
            let key = keys[indexPath.section]
            if var devices = self.dataList[key] {
                if devices.count > indexPath.row {
                    let device = devices[indexPath.row]
                    device.isSelected = !device.isSelected
                    devices[indexPath.row] = device
                }
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MXGroupSelectCategoryTableViewHeaderView") as! MXGroupSelectCategoryTableViewHeaderView
        view.delegate = self
        view.section = section
        let keys = Array(self.dataList.keys)
        if keys.count > section {
            let key = keys[section]
            if let devices = self.dataList[key] {
                view.infos = devices
            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension MXGroupSelectCategoryAlertView: MXGroupSelectCategoryTableViewHeaderViewDelegate {
    
    func didSelected(section: Int) {
        let keys = Array(self.dataList.keys)
        if keys.count > section {
            let key = keys[section]
            if let devices = self.dataList[key] {
                let allSelected = devices.filter({$0.isSelected == true}).count == devices.count
                devices.forEach { (info:MXDeviceInfo) in
                        info.isSelected = !allSelected
                    
                }
                self.dataList[key] = devices
                self.tableView.reloadData()
            }
        }
    }
}


class MXGroupSelectCategoryTableViewCell: UITableViewCell {
    
    var info: MXDeviceInfo? {
        didSet {
            guard let info = info else {
                return
            }
            
            if let img = info.image {
                self.imgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: img))
            } else if let img = info.productInfo?.image {
                self.imgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: img))
            }
            self.nameLabel.text = info.showName
                        
                self.isOnLine = true
                self.alpha = 1.0
                opLabel.textColor = AppUIConfiguration.MainColor.C0
                opLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
                if info.isSelected {
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
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(opLabel)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
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

protocol MXGroupSelectCategoryTableViewHeaderViewDelegate {
    
    func didSelected(section: Int) -> Void
    
}

class MXGroupSelectCategoryTableViewHeaderView: UITableViewHeaderFooterView {
        
    var infos: [MXDeviceInfo]? {
        didSet {
            guard let infos = infos,
                  let theFirst = infos.first
            else {
                return
            }
            
            nameLabel.text = theFirst.roomName
                        
            let allSelected = infos.filter({$0.isSelected == true}).count == infos.count
            
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
    
    var delegate: MXGroupSelectCategoryTableViewHeaderViewDelegate?
    
}
