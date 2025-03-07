
import Foundation
import UIKit

class MXHomeListViewController: MXBaseViewController {
    
    
    @objc func createHome() {
        let alert = MXAlertView(title: localized(key: "家庭名称"),
                                placeholder: localized(key: "请输入名称"),
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) { (textField: UITextField) in

        } rightButtonCallBack: { (textField: UITextField) in
            guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                MXToastHUD.showInfo(status: localized(key:"输入不能为空"))
                return
            }
            if let msg = text.toastMessageIfIsInValidHomeName() {
                MXToastHUD.showInfo(status: msg)
                return
            }
            if MXHomeManager.shard.homeList.first(where: {$0.name == text}) != nil {
                MXToastHUD.showInfo(status: localized(key: "名称重复"))
                return
            }
            MXHomeManager.shard.createHome(name: text, rooms: [localized(key: "默认房间")])
            self.loadRequestData()
        }
        alert.show()
        
    }
    
    func joinHomeViaPin() -> Void {
        MXURLRouter.open(url: "https://com.mxchip.bta/page/home/joinInViaPin", params: nil)
    }
    
    func joinHomeViaQRCode() -> Void {
        MXURLRouter.open(url: "https://com.mxchip.bta/page/mxQRCode", params: nil)
    }
    
    
    func loadRequestData() {
        self.dataList = MXHomeManager.shard.homeList
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key: "家庭管理")
        
        self.addButton.titleLabel?.font = UIFont.iconFont(size: 18)
        self.addButton.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        let attrStr = NSMutableAttributedString()
        let str1 = NSAttributedString(string: "\u{e710}  ", attributes: [.font: UIFont.iconFont(size:18),.foregroundColor:AppUIConfiguration.MainColor.C0])
        attrStr.append(str1)
        let str2 = NSAttributedString(string: localized(key:"新建家庭"), attributes: [.font: UIFont.systemFont(ofSize: 18),.foregroundColor:AppUIConfiguration.MainColor.C0])
        attrStr.append(str2)
        self.addButton.mxTitleLB.attributedText = attrStr
        self.addButton.addTarget(self, action: #selector(createHome), for: .touchUpInside)
        self.contentView.addSubview(self.addButton)
        self.addButton.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.addButton.pin.left().bottom().right().height(64 + self.view.pin.safeArea.bottom)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(MXHomeListTableViewCell.self, forCellReuseIdentifier: "MXHomeListTableViewCell")
        self.contentView.addSubview(tableView)
        
        self.view.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.addButton.pin.left().bottom().right().height(64 + self.view.pin.safeArea.bottom)
        self.tableView.pin.left().top(12).right().above(of: self.addButton).marginBottom(12)
    }
    
    var dataList = [MXHomeInfo]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var addButton = MXLabelButton(type: .custom)
    var tableView = UITableView(frame: .zero)
        
}

class MXHomeListTableViewCell: UITableViewCell {
    
    func updateSubviews(with model: MXHomeInfo) -> Void {
        nameLabel.text = model.name
        
        let numberAtt = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),
                         NSAttributedString.Key.foregroundColor : AppUIConfiguration.NeutralColor.secondaryText]
        let lineAtt = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H7),
                       NSAttributedString.Key.foregroundColor : AppUIConfiguration.MXColor.black.withAlphaComponent(0.08),
                       NSAttributedString.Key.baselineOffset: 2] as [NSAttributedString.Key : Any]
        
        let att = NSMutableAttributedString(string: localized(key: "房间") + String(model.rooms.count), attributes: numberAtt)
        att.append(NSAttributedString(string: " | ", attributes: lineAtt))
        att.append(NSAttributedString(string: localized(key: "设备") + String(model.deviceCount), attributes: numberAtt))
        
        contentLabel.attributedText = att
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.selectionStyle = .none
        
        self.contentView.addSubview(nameLabel)
        nameLabel.text = "XXX"
        nameLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H2)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        self.contentView.addSubview(contentLabel)
        
        self.contentView.addSubview(arrowLabel)
        arrowLabel.font = UIFont.iconFont(size: 20)
        arrowLabel.text = "\u{e6df}"
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.pin.left(16).top(16).width(200).height(22)
        contentLabel.pin.below(of: nameLabel, aligned: .left).marginTop(8).width(280).height(18)
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
    }
    
    let nameLabel = UILabel()
    let contentLabel = UILabel()
    let arrowLabel = UILabel()
    
}

extension MXHomeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXHomeListTableViewCell", for: indexPath) as! MXHomeListTableViewCell

        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell.updateSubviews(with: info)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            
            var params = [String : Any]()
            params["data"] = info
            MXURLRouter.open(url: "https://com.mxchip.bta/page/home/detail", params: params)
        }
    }
    
}

extension MXHomeListViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXHomeListViewController()
        if let list = params["dataList"] as? Array<MXHomeInfo> {
            controller.dataList = list
        }
        return controller
    }
}
