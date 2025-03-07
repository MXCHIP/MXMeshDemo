
import Foundation
import UIKit


class MXGroupDevicesPage: MXBaseViewController {
    
    @objc func doneAction(sender: UIButton) -> Void {
        if self.selectedDevices.count > 0 {
            self.updateGroupDevices()

        } else {
            let alertView = MXAlertView(title: localized(key: "设备选择"),
                                        message: localized(key: "请选择设备"),
                                        confirmButtonTitle: localized(key: "好")) {
                
            }
            alertView.show()
        }
    }
    
    func updateGroupDevices() {
        if self.groupInfo.meshInfo?.meshAddress != nil {
            MXGroupManager.shared.update(with: self.groupInfo, devices: self.selectedDevices) { list in
                self.groupInfo.subDevices = list
                MXDeviceManager.shard.update(device: self.groupInfo)
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "MXGroupDevicesUpdate"), object: nil, userInfo: ["devices": self.selectedDevices])
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func editAction(sender: UIButton) -> Void {
        guard let category_id = self.groupInfo.category_id else { return }
        
        let alertView = MXGroupSelectCategoryAlertView()
        alertView.show(in: self.view, category_id: category_id, info: self.groupInfo, selectedDevices: self.selectedDevices) { devices in
            self.selectedDevices = devices
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key: "编辑群组")
        
        let color = AppUIConfiguration.NeutralColor.primaryText
        let font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let att = NSAttributedString(string: localized(key: "完成"), attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: font])
        let rightButton = UIButton(type: .custom)
        rightButton.setAttributedTitle(att, for: .normal)
        rightButton.addTarget(self, action: #selector(doneAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightButton)
        rightButton.pin.right(20).sizeToFit().vCenter()
        
        initSubview()
        
        if let nodes = self.groupInfo.subDevices {
            self.selectedDevices = nodes
        }
    }
    
    func initSubview() -> Void {
        self.contentView.addSubview(tableView)
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MXGroupDevicesTableViewCell.self, forCellReuseIdentifier: "MXGroupDevicesTableViewCell")
        
        self.contentView.addSubview(bottomView)
        bottomView.addSubview(bottomButton)
        bottomView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        bottomButton.setBackgroundColor(color: AppUIConfiguration.MainColor.C0, forState: UIControl.State.normal)
        bottomButton.setTitleColor(AppUIConfiguration.MXColor.white, for: UIControl.State.normal)
        bottomButton.layer.cornerRadius = 25
        
        let att = NSAttributedString(string: localized(key: "添加/移除设备"), attributes: nil)
        bottomButton.setAttributedTitle(att, for: UIControl.State.normal)
        bottomButton.addTarget(self, action: #selector(editAction(sender:)), for: UIControl.Event.touchUpInside)

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        bottomView.pin.left().right().bottom().height(self.view.safeAreaInsets.bottom + 70)
        bottomButton.pin.left(16).top(10).right(16).height(50)
        
        tableView.pin.above(of: bottomView).left().right().top()
    }
    
    var groupInfo = MXDeviceInfo()
    var selectedDevices = [MXDeviceInfo]()
    
    let tableView =  UITableView(frame: .zero, style: UITableView.Style.grouped)
    
    let bottomView = UIView(frame: .zero)
    let bottomButton = UIButton(frame: .zero)

}


extension MXGroupDevicesPage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension MXGroupDevicesPage: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXGroupDevicesTableViewCell", for: indexPath) as! MXGroupDevicesTableViewCell
        if self.selectedDevices.count > indexPath.row {
            let node = self.selectedDevices[indexPath.row]
            cell.node = node
            
            if indexPath.row == 0 {
                if self.selectedDevices.count == 1 {
                    cell.round(with: .both, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                } else {
                    cell.round(with: .top, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                }
            } else {
                if indexPath.row == self.selectedDevices.count - 1 {
                    cell.round(with: .bottom, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                } else {
                    cell.removeRound()
                }
            }
            
        }

        return cell
    }
    
}

class MXGroupDevicesTableViewCell: UITableViewCell {
    
    
    var node: MXDeviceInfo? {
        
        didSet {
            guard let node = node else {
                return
            }
            
            if let img = node.image {
                self.imgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: img))
            } else if let img = node.productInfo?.image {
                self.imgView.sd_setImage(with: URL(string: img), placeholderImage: UIImage(named: img))
            }
            
            self.titleLabel.text = node.showName
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubview()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubview() -> Void {
        self.selectionStyle = .none
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.pin.left(26).width(40).height(40).vCenter()
        titleLabel.pin.after(of: imgView, aligned: .center).marginLeft(16).sizeToFit()
        
    }
    
    let imgView = UIImageView()
    let titleLabel = UILabel()

}

extension MXGroupDevicesPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXGroupDevicesPage()
        if let info = params["device"] as? MXDeviceInfo,
           let infoParams = MXDeviceInfo.mx_keyValue(info),
           let groupInfo = MXDeviceInfo.mx_Decode(infoParams) {
            vc.groupInfo = groupInfo
        } else if let infoParams = params["device"] as? [String: Any],
                  let groupInfo = MXDeviceInfo.mx_Decode(infoParams) {
            vc.groupInfo = groupInfo
        }
        return vc
    }
    
}
