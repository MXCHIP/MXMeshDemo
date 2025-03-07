
import Foundation
import UIKit

class MXHomeDetailViewController: MXBaseViewController {
    
    
    @objc func deleteAction() {
        
        let alert = MXAlertView(title: localized(key: "确定要删除家庭吗？"),
                                message: localized(key: "删除家庭提示"),
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) {
            
        } rightButtonCallBack: {
            self.deleteHome()
        }
        
        alert.show()
    }
    
    func deleteHome() -> Void {
        if MXHomeManager.shard.homeList.count < 2 {
            let msg = localized(key: "抱歉，无法删除，账号至少要保留一个家庭")
            let alert = MXAlertView(title: localized(key: "提示"), message: msg, confirmButtonTitle:  localized(key: "确定")) {
                
            }
            alert.show()
            return
        }
        MXHomeManager.shard.homeList.removeAll(where: {$0.homeId == self.info.homeId})
        MXHomeManager.shard.updateHomeList()
        //如果删除的是当前家庭
        if self.info.homeId == MXHomeManager.shard.currentHome?.homeId {
            MXHomeManager.shard.refreshCurrentHome()
        }
        self.gotoBack()
    }
    
    
    func updateHomeName() -> Void {
        
        if self.info.role == 2 {
            MXHomeManager.showNoAuthorityAlert()
            return
        }
        
        let alert = MXAlertView(title: localized(key: "家庭名称"),
                                placeholder: localized(key: "请输入名称"),
                                text: self.info.name,
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) { (textField: UITextField) in
            
        } rightButtonCallBack: { [weak self] (textField: UITextField) in
            if let text = textField.text?.trimmingCharacters(in: .whitespaces) {
                if let msg = text.toastMessageIfIsInValidHomeName() {
                    MXToastHUD.showInfo(status: msg)
                    return
                }
                if MXHomeManager.shard.homeList.first(where: {$0.name == text}) != nil {
                    MXToastHUD.showInfo(status: localized(key: "名称重复"))
                    return
                }
                self?.info.name = text
                MXHomeManager.shard.updateHomeList()
                self?.tableView.reloadData()
            }
        }
        
        alert.show()
    }
    
    
    func roomManage() -> Void {
        
        if self.info.role == 2 {
            MXHomeManager.showNoAuthorityAlert()
            return
        }
        
        let params = ["homeId": self.info.homeId]
        MXURLRouter.open(url: "https://com.mxchip.bta/page/home/rooms", params: params)
    }
    
    var info : MXHomeInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key: "家庭设置")
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle(localized(key:"删除"), for: .normal)
        rightBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        self.contentView.addSubview(self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.info = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.info.homeId})
        self.tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.pin.all()
    }
    
    let tableView = MXBaseTableView(frame: .zero, style: UITableView.Style.grouped)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
}

extension MXHomeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellIdentifier = "CellIdentifier1"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            if cell == nil{
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            }
            cell?.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
            cell?.contentView.backgroundColor = .clear
            if self.info.role == 2 {
                cell?.accessoryType = UITableViewCell.AccessoryType.none
            } else {
                cell?.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
            cell?.selectionStyle = UITableViewCell.SelectionStyle.none
            cell?.textLabel?.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
            cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.title
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
            cell?.detailTextLabel?.textColor = AppUIConfiguration.NeutralColor.secondaryText
            cell?.detailTextLabel?.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
            switch indexPath.row {
            case 0:
                cell?.textLabel?.text = localized(key:"家庭名称")
                cell?.detailTextLabel?.text = self.info.name
            case 1:
                cell?.textLabel?.text = localized(key:"房间管理")
                cell?.detailTextLabel?.text = "\(self.info.rooms.count)" + localized(key:"个") + localized(key:"房间")
            case 2:
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                cell?.textLabel?.text = localized(key:"设备数量")
                cell?.detailTextLabel?.text = "\(self.info.deviceCount)" + localized(key:"个") + localized(key:"设备")
            default:
                break
            }
            
            return cell!
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if self.info.role == 2 {
                return
            }
            switch indexPath.row {
            case 0:
                updateHomeName()
            case 1:
                roomManage()
            default:
                return
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12))
        header.backgroundColor = .clear
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 12.0
        } else if section == 1 {
            return 50.0
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
}

extension MXHomeDetailViewController: MXURLRouterDelegate {
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXHomeDetailViewController()
        if let homeInfo = params["data"] as? MXHomeInfo{
            vc.info = homeInfo
        }
        return vc
    }
}
