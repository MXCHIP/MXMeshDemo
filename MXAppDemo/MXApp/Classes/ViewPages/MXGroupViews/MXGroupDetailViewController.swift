
import Foundation

class MXGroupDetailViewController: MXBaseViewController {
    
    var info : MXDeviceInfo?
    var removeList = [MXDeviceInfo]()
    var headerView: MXDeviceDetailHeaderView!
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        return tableView
    }()
    
    private lazy var footerView : UIView = {
        let _footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width-20, height: 60))
        _footerView.backgroundColor = UIColor.clear
        
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.layer.cornerRadius = 25.0
        deleteBtn.layer.masksToBounds = true
        deleteBtn.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        deleteBtn.setTitleColor(AppUIConfiguration.MXAssistColor.red, for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        deleteBtn.setTitle(localized(key:"解散群组"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteGroupAlert), for: .touchUpInside)
        
        _footerView.addSubview(deleteBtn)
        deleteBtn.pin.left().top().right().height(50)
        
        return _footerView
    }()
    
    private lazy var redPointView : UIView = {
        let _redPointView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        _redPointView.backgroundColor = AppUIConfiguration.MXAssistColor.red
        _redPointView.layer.cornerRadius = 3.0
        _redPointView.layer.masksToBounds = true
        return _redPointView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"群组详情")

        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top(12).bottom()
        
        self.headerView = MXDeviceDetailHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 100))
        self.headerView.didActionCallback = { [weak self] (info: Any) in
            if !MXHomeManager.shard.operationAuthorityCheck() {
                return
            }
            let alertView = MXAlertView(title: localized(key:"设备名称"), placeholder: localized(key:"请输入名称"), text:self?.info?.name, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textField: UITextField) in
                

            } rightButtonCallBack: { (textField: UITextField) in
                guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                    MXToastHUD.showInfo(status: localized(key:"输入不能为空"))
                    return
                }
                if let msg = text.toastMessageIfIsInValidDeviceName() {
                    MXToastHUD.showInfo(status: msg)
                    return
                }

                
                self?.info?.name = text
                if let group = self?.info {
                    self?.headerView.refreshView(info: group)
                    MXDeviceManager.shard.update(device: group)
                }
            }
            alertView.show()
        }
        self.tableView.tableHeaderView = self.headerView
        self.headerView.layer.cornerRadius = 16.0
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 60)
        self.tableView.tableFooterView = self.footerView
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
    }
    
    func loadRequestData() {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            if room.roomId == self.info?.roomId {
                if let info = self.info,
                   let gInfo = room.devices.first(where: {$0.isSameFrom(info)}),
                   let infoParams = MXDeviceInfo.mx_keyValue(gInfo),
                   let groupInfo = MXDeviceInfo.mx_Decode(infoParams)  {
                    self.info = groupInfo
                    self.headerView.refreshView(info: groupInfo)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(10).right(10).top(12).bottom()
        self.headerView.layer.cornerRadius = 16.0
    }
    
    @objc func deleteGroupAlert() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        let alert = MXAlertView(title: localized(key:"解散群组"), message: localized(key:"是否解散群组？"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
            
        } rightButtonCallBack: {
            self.deleteGroup()
        }
        alert.show()
    }
    
    @objc func deleteGroup() {
        if let group = self.info {
            MXDeviceManager.shard.delete(device: group, isSave: true)
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func updateDeviceFavorite(isOn: Bool) {
        
        self.info?.isFavorite = isOn
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        if let group = self.info {
            MXDeviceManager.shard.update(device: group)
        }
    }
}

extension MXGroupDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "kCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXActionCell
        if cell == nil{
            cell = MXActionCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        cell?.textLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.title
        cell?.textLabel?.textAlignment = .left
        
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.detailTextLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
        cell?.detailTextLabel?.textAlignment = .right
        cell?.detailTextLabel?.numberOfLines = 1
        cell?.detailTextLabel?.isUserInteractionEnabled = false
        cell?.actionBtn.isHidden = true
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = localized(key:"房间位置")
            cell?.detailTextLabel?.text = localized(key:"未设置")
            if let rName = self.info?.roomName, rName.count > 0 {
                cell?.detailTextLabel?.text = rName
            }
            cell?.accessoryType = .disclosureIndicator
            cell?.cellCorner = [.topLeft, .topRight]
            break
        case 1:
            cell?.textLabel?.text = localized(key:"设备数量")
            cell?.detailTextLabel?.text = "\(self.info?.subDevices?.count ?? 0)" + localized(key:"个")
            cell?.accessoryType = .disclosureIndicator
            break
        case 2:
            cell?.textLabel?.text = localized(key:"设为常用")
            cell?.detailTextLabel?.text = nil
            cell?.accessoryType = .none
            cell?.actionBtn.isHidden = false
            cell?.actionBtn.isOn = self.info?.isFavorite ?? false
            cell?.didActionCallback = { [weak self] (isOn: Bool) in
                self?.updateDeviceFavorite(isOn: isOn)
            }
            cell?.cellCorner = [.bottomLeft, .bottomRight]
            break
        default:
            break
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            self.gotoDeviceRoomSetting()
            break
        case 1:
            
            self.gotoSelectDevicePage()
            break
        case 2:
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12.0))
        header_view.backgroundColor = UIColor.clear
        
        return header_view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12.0))
        footer_view.backgroundColor = UIColor.clear
        
        return footer_view
    }
    
}

extension MXGroupDetailViewController {
    
    
    func gotoDeviceRoomSetting() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        var params = [String : Any]()
        params["device"] = self.info
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/selectRoom", params: params)
    }
    
    func gotoSelectDevicePage() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        var params = [String : Any]()
        params["device"] = self.info
        MXURLRouter.open(url: "https://com.mxchip.bta/page/group/selectDevice", params: params)
    }
}

extension MXGroupDetailViewController: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let vc = MXGroupDetailViewController()
        if let info = params["device"] as? MXDeviceInfo {
            vc.info = info
        } else if let infoParams = params["device"] as? [String: Any],
                  let groupInfo = MXDeviceInfo.mx_Decode(infoParams) {
            vc.info = groupInfo
        }
        return vc
    }
}
