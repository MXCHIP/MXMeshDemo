
import Foundation
import UIKit
import MeshSDK
import SDWebImage

class MXLinkageSelectedScenePage: MXBaseViewController {
    
    var dataList = [MXSceneInfo]()
    var backList = [String]()
    var selectedList = [String]()
    var pageNo : Int = 1
    
    var iotId : String = ""
    var uuidString: String?
    var isCheckbox: Bool = false
    var attrType: String?
    var identifier: String?
    var attrValue: String = "00"
    
    var footerView: UIView = UIView(frame: .zero)
    var addButton: MXLabelButton!
    var resetBtn: UIButton!
    
    @objc func saveButtonAction(sender: UIButton) -> Void {
        
        if self.backList == self.selectedList {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        guard let uuid = self.uuidString, let attr_type = self.attrType else {
            MXToastHUD.showInfo(status: localized(key:"保存失败"))
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        var attrStr = "000B".littleEndian
        if self.selectedList.count > 0 {
            for vidStr in self.selectedList {
                attrStr = attrStr + attr_type.littleEndian + self.attrValue + vidStr
            }
        } else {  
            attrStr = attrStr + attr_type.littleEndian + self.attrValue + "00"
        }
        MXToastHUD.show()
        MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuid, message: attrStr) { (result:[String : Any]) in
            guard  let resultMsg = result["message"] as? String else {
                MXToastHUD.showInfo(status: localized(key: "保存失败"))
                return
            }
            print("收到设备回消息：\(resultMsg)")
            if resultMsg.count > 4 {
                let attrValue = String(resultMsg.suffix(resultMsg.count-4))
                if Int(attrValue, radix: 16) == 0 {
                    MXToastHUD.dismiss()
                    self.navigationController?.popViewController(animated: true)
                    return
                }
            }
            MXToastHUD.showInfo(status: localized(key: "保存失败"))
        }
    }
    
    @objc func resetAction() -> Void {
        
        let msgStr = localized(key: "是否要重置设置？") + "\n" + localized(key: "重置后将清除原来的设置")
        let alert = MXAlertView(title: localized(key: "提示"), message: msgStr, leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) {
            
        } rightButtonCallBack: {
            guard let uuid = self.uuidString, let attr_type = self.attrType else {
                MXToastHUD.showInfo(status: localized(key: "清除设置失败"))
                self.navigationController?.popViewController(animated: true)
                return
            }
            let attrStr = "000B".littleEndian + attr_type.littleEndian + self.attrValue + String(format: "%02X", 0)
            MXToastHUD.show()
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuid, message: attrStr) { (result:[String : Any]) in
                guard  let resultMsg = result["message"] as? String else {
                    MXToastHUD.showInfo(status: localized(key: "清除设置失败"))
                    return
                }
                if resultMsg.count > 4 {
                    let attrValue = String(resultMsg.suffix(resultMsg.count-4))
                    if Int(attrValue, radix: 16) == 0 {
                        MXToastHUD.dismiss()
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                }
                MXToastHUD.showInfo(status: localized(key: "清除设置失败"))
            }
        }
        alert.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
        
        self.footerView.backgroundColor = .clear
        self.tableView.tableFooterView = self.footerView
        self.footerView.pin.left().right().top().height(160)
        
        self.addButton = MXLabelButton(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        self.addButton.layer.masksToBounds = true
        self.addButton.layer.cornerRadius = 16.0
        let titleStr = NSMutableAttributedString()
        let iconStr = NSAttributedString(string: "\u{e6db}  ", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H2),.foregroundColor:AppUIConfiguration.MainColor.C0])
        titleStr.append(iconStr)
        let nameStr = NSAttributedString(string: localized(key: "添加场景"), attributes: [.font: UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.MainColor.C0,.baselineOffset:1])
        titleStr.append(nameStr)
        self.addButton.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.addButton.mxTitleLB.attributedText = titleStr
        self.addButton.addTarget(self, action: #selector(gotoCreatePage), for: .touchUpInside)
        self.footerView.addSubview(self.addButton)
        self.addButton.pin.left().right().top(12).height(80)
        
        self.resetBtn = UIButton(type: .custom)
        self.resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        self.resetBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        self.resetBtn.setTitle(localized(key: "重置设置"), for: .normal)
        self.resetBtn.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        self.footerView.addSubview(self.resetBtn)
        self.resetBtn.pin.below(of: self.addButton).marginTop(12).width(120).height(40).hCenter()
    }
    
    func initSubviews() -> Void {
        self.title = localized(key: "选择场景")
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle(localized(key:"保存"), for: .normal)
        rightBtn.addTarget(self, action: #selector(saveButtonAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.contentView.addSubview(tableView)
        self.tableView.pin.all(12)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
    }
    
    @objc func gotoCreatePage() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        let sceneInfo = MXSceneInfo(type: "one_click")
        var params = [String : Any]()
        params["sceneInfo"] = sceneInfo
        MXURLRouter.open(url: "com.mxchip.bta/page/scene/sceneDetail", params: params)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.pin.all(12)
        self.footerView.pin.left().right().top().height(160)
        self.addButton.pin.left().right().top(12).height(80)
        self.resetBtn.pin.below(of: self.addButton).marginTop(12).width(120).height(40).hCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDataList()
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(MXSceneSelectionViewCell.self, forCellReuseIdentifier: "MXSceneSelectionViewCell")
        return tableView
    }()
    
    func loadDataList() {
        self.dataList = MXHomeManager.shard.currentHome?.scenes ?? [MXSceneInfo]()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MXLinkageSelectedScenePage: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneSelectionViewCell", for: indexPath) as! MXSceneSelectionViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell.info = info
            cell.mxSelected = (self.selectedList.first(where: {Int($0, radix: 16) == info.vid}) != nil) ? true : false
        }
        cell.cellCorner = []
        if indexPath.row == 0 {
            if self.dataList.count == 1 {
                cell.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            } else {
                cell.cellCorner = [.topLeft, .topRight]
            }
        } else if indexPath.row == self.dataList.count - 1 {
            cell.cellCorner = [.bottomLeft, .bottomRight]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if let sceneIndex = self.selectedList.firstIndex(where: {Int($0, radix: 16) == info.vid}) {
                self.selectedList.remove(at: sceneIndex)
            } else {
                if !self.isCheckbox {  
                    self.selectedList.removeAll()
                }
                self.selectedList.append(String(format: "%02x", info.vid))
            }
            
            tableView.reloadData()
        }
    }
}

extension MXLinkageSelectedScenePage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXLinkageSelectedScenePage()
        if let list = params["bind_values"] as? [String] {
            vc.backList = list
            vc.selectedList = list
        }
        if let device = params["device"] as? MXDeviceInfo, let uuidStr = device.meshInfo?.uuid {
            vc.uuidString = uuidStr
        }
        vc.iotId = params["iotId"] as? String ?? ""
        if let uuid = params["uuid"] as? String {
            vc.uuidString = uuid
        }
        if let attr_type = params["attrType"] as? String {
            vc.attrType = attr_type
        }
        if let identifierStr = params["identifier"] as? String {
            vc.identifier = identifierStr
        }
        vc.isCheckbox = params["checkbox"] as? Bool ?? false
        vc.attrValue = params["attrValue"] as? String ?? "00"
        return vc
    }
    
}

class MXSceneSelectionViewCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    public typealias SelectDeviceActionCallback = (_ item: MXDeviceInfo) -> ()
    public var selectDeviceCallback : SelectDeviceActionCallback!
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.selectBtn.setTitle("\u{e6f3}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
            } else {
                self.selectBtn.setTitle("\u{e6fb}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
            }
        }
    }
    
    var info : MXSceneInfo! {
        didSet {
            self.refreshView()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        
        self.contentView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(16).width(24).height(24).vCenter()
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(20).height(20).left(of: self.selectBtn).marginRight(16).vCenter()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshView() {
        
        if self.mxSelected {
            self.selectBtn.setTitle("\u{e6f3}", for: .normal)
            self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        } else {
            self.selectBtn.setTitle("\u{e6fb}", for: .normal)
            self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        }
        
        self.nameLB.text = self.info.name
        
        if let imageUrl = self.info.iconImage {
            self.iconView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: imageUrl)?.mx_imageByTintColor(color: UIColor(hex: self.info.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))) { [weak self] (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                if let img = image {
                    self?.iconView.image = img.mx_imageByTintColor(color: UIColor(hex: self?.info.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))
                }
            }
        }
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        self.selectBtn.pin.right(16).width(24).height(24).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(20).height(20).left(of: self.selectBtn).marginRight(16).vCenter()
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconView.backgroundColor = UIColor.clear
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        _selectBtn.isUserInteractionEnabled = false
        return _selectBtn
    }()
}
