
import Foundation
import UIKit
import SwiftUI

class MXHomeMenuView: UIView {
    
    public typealias DidSelectedHomeCallback = (_ info: MXHomeInfo) -> ()
    public var didSelectedHomeCallback : DidSelectedHomeCallback!
    
    var contentH : CGFloat = 244
    var contentView : UIView!
    public var dataList = [MXHomeInfo]() {
        didSet {
            self.contentH = AppUIConfiguration.statusBarH + (CGFloat(self.dataList.count) * 60.0) + 80
            if self.contentH > AppUIConfiguration.statusBarH + 320  {
                self.contentH = AppUIConfiguration.statusBarH + 320
            }
            DispatchQueue.main.async {
                self.contentView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.contentH)
                self.contentView.corner(byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], radii: 16.0)
                self.layoutSubviews()
                self.tableView.reloadData()
            }
        }
    }
    var footerView : MXHomeMenuFooterView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(homeChange), name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
        
        self.contentView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 244))
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.contentView.corner(byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], radii: 16.0)
        self.addSubview(self.contentView)
        
        self.footerView = MXHomeMenuFooterView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 80))
        self.footerView.didActionCallback = { [weak self] (index : Int) in
            switch index {
            case 1:
                self?.createHome()
            case 2:
                self?.gotoListController()
            default:
                break
            }
        }
        self.contentView.addSubview(self.footerView)
        self.footerView.pin.left().bottom().right().height(80)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left().top(AppUIConfiguration.statusBarH).right().above(of: self.footerView).marginBottom(0)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.pin.left().right().top().height(self.contentH)
        self.footerView.pin.left().bottom().right().height(80)
        self.tableView.pin.left().top(AppUIConfiguration.statusBarH).right().above(of: self.footerView).marginBottom(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var tableView :MXBaseTableView = {
        let viewFrame = CGRect(x: 0, y: AppUIConfiguration.statusBarH, width: self.frame.size.width, height: 120)
        let tableView = MXBaseTableView(frame: viewFrame, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    
    func createHome() {
        let alert = MXAlertView(title: localized(key: "家庭名称"),
                                placeholder: localized(key: "请输入名称"),
                                leftButtonTitle: localized(key: "取消"),
                                rightButtonTitle: localized(key: "确定")) { (textField: UITextField) in

        } rightButtonCallBack: { (textField: UITextField) in
            if let text = textField.text?.trimmingCharacters(in: .whitespaces) {
                if let msg = text.toastMessageIfIsInValidHomeName() {
                    MXToastHUD.showInfo(status: msg)
                    return
                }
                if MXHomeManager.shard.homeList.first(where: {$0.name == text}) != nil {
                    MXToastHUD.showInfo(status: localized(key: "名称重复"))
                    return
                }
                MXHomeManager.shard.createHome(name: text, rooms: [localized(key: "默认房间")])
                self.dataList = MXHomeManager.shard.homeList
            }
        }
        alert.show()
    }
    
    func gotoListController()  {
        var params = [String : Any]()
        params["dataList"] = self.dataList
        
        MXURLRouter.open(url: "https://com.mxchip.bta/page/home/list", params: params)
        
        self.hide()
    }
    
    
    func inviteMmbers(info: MXHomeInfo) {
        hide()
        if info.role >= 2 {
            let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"普通成员没有权限描述"), confirmButtonTitle: localized(key:"确定")) {
                
            }
            alert.show()
            return
        }
        let url = "com.mxchip.bta/page/home/invite"
        var params = [String : Any]()
        params["id"] = info.homeId
        params["name"] = info.name
        params["role"] = info.role
        
        MXURLRouter.open(url: url, params: params)
    }
    
    
    @objc func hide() {
        self.removeFromSuperview()
    }
    
    func show() {
        self.frame = UIScreen.main.bounds
        UIApplication.shared.delegate?.window?!.addSubview(self)
    }
    
    @objc func homeChange() {
        self.dataList = MXHomeManager.shard.homeList
    }
}

extension MXHomeMenuView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier2 = "HomeCellIdentifier2"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier2) as? MXHomeMenuCell
        if cell == nil{
            cell = MXHomeMenuCell(style: .default, reuseIdentifier: cellIdentifier2)
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell?.refreshView(info: info)
        }
        cell?.actionBtn.isHidden = true
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if MXHomeManager.shard.currentHome?.homeId != info.homeId {
                MXHomeManager.shard.currentHome = info
                self.didSelectedHomeCallback?(info)
            }
            self.hide()
        }
    }
}

extension MXHomeMenuView : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         
         let touchClass = NSStringFromClass((touch.view?.classForCoder)!)
        if let superCoder = touch.view?.superview!.superview?.classForCoder  {
            let supClass = NSStringFromClass(superCoder)
            if touchClass.hasPrefix("UITableView") || touchClass.hasPrefix("UICollectionView") ||
                supClass.hasPrefix("UITableView") || supClass.hasPrefix("UICollectionView") {
                return false
            }
        }
         return true
    }


}

class MXHomeMenuCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ item: MXHomeInfo) -> ()
    public var didActionCallback : DidActionCallback!
    
    var itemInfo : MXHomeInfo!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.iconLB)
        self.iconLB.pin.left(16).width(20).height(20).vCenter()
        
        self.contentView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(16).width(32).top().bottom()
        
        self.contentView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconLB).marginLeft(16).left(of: self.actionBtn).marginRight(16).top().bottom()
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
    }
    
    @objc func didAction() {
        self.didActionCallback?(self.itemInfo)
    }
    
    public func refreshView(info: MXHomeInfo) {
        self.itemInfo = info
        self.nameLab.text = info.name
        
        if info.homeId == MXHomeManager.shard.currentHome?.homeId {
            self.iconLB.textColor = AppUIConfiguration.MainColor.C0
            self.nameLab.textColor = AppUIConfiguration.MainColor.C0
        } else {
            self.iconLB.textColor = AppUIConfiguration.NeutralColor.dividers
            self.nameLab.textColor = AppUIConfiguration.NeutralColor.title
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconLB.pin.left(16).width(20).height(20).vCenter()
        self.actionBtn.pin.right(12).width(40).top().bottom()
        self.nameLab.pin.right(of: self.iconLB).marginLeft(16).left(of: self.actionBtn).marginRight(12).top().bottom()
    }
    
    lazy var iconLB : UILabel = {
        let _iconLB = UILabel(frame: .zero)
        let font = UIFont.iconFont(size: 20)
        _iconLB.font = font
        _iconLB.text = "\u{e70f}"
        _iconLB.backgroundColor = UIColor.clear
        return _iconLB
    }()
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        return _nameLab
    }()
    
    lazy var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _actionBtn.setTitle(localized(key:"邀请"), for: .normal)
        _actionBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        return _actionBtn
    }()
}
