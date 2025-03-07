
import Foundation
import PinLayout
import UIKit

class HomeTitleView: UIView {

    var menuButton = MXHintButton()
    var homeButton = MXLabelButton()
    var addButton = MXHintButton()
    var remindButton = MXHintButton()
    
    @objc func menuButtonAction(sender: UIButton) -> Void {
        let root = MXMenuViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.view.backgroundColor = UIColor.clear
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .overCurrentContext

        if let appdelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appdelegate.window,
           let rootvc = window.rootViewController {
            rootvc.present(nav, animated: false) {
                root.showMenu()
            }
        }
    }
    
    @objc func showHomeMenuView() {
        let homeMenu = MXHomeMenuView(frame: UIScreen.main.bounds)
        homeMenu.dataList = MXHomeManager.shard.homeList
        homeMenu.didSelectedHomeCallback = { (info : MXHomeInfo) in
            MXHomeManager.shard.currentHome = info
        }
        homeMenu.show()
    }
    
    @objc func remindButtonAction(sender: UIButton) -> Void {
        
    }
    
    @objc func addButtonAction(sender: UIButton) -> Void {
        var menu_list = [MXMenuInfo]()
        let menuInfo = MXMenuInfo()
        menuInfo.name = localized(key:"添加设备")
        menuInfo.jumpUrl = "https://com.mxchip.bta/page/device/autoSearch"
        menuInfo.isAuthorityCheck = true
        menu_list.append(menuInfo)
        let menuInfo2 = MXMenuInfo()
        menuInfo2.name = localized(key:"添加群组")
        menuInfo2.jumpUrl = "https://com.mxchip.bta/page/group/selectCategory"
        menuInfo2.isAuthorityCheck = true
        menu_list.append(menuInfo2)
        let menuInfo4 = MXMenuInfo()
        menuInfo4.name = localized(key:"添加智能")
        menuInfo4.jumpUrl = "https://com.mxchip.bta/page/scene/selectSceneType"
        menuInfo4.isAuthorityCheck = true
        menu_list.append(menuInfo4)
        let menuAlertView = MXMenuAlertView(contentFrame: CGRect(x: UIScreen.main.bounds.width - 130, y: 88, width: 120, height: 120), menuList: menu_list)
        menuAlertView.show()
    }
    
    @objc func homeNameChange() {
        DispatchQueue.main.async {
            var homeName = localized(key: "我的家")
            if let currentName = MXHomeManager.shard.currentHome?.name  {
                homeName = currentName
            }
            let titleStr = NSMutableAttributedString()
            let nameStr = NSAttributedString(string: homeName, attributes: [.font: UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H2),.foregroundColor:AppUIConfiguration.NeutralColor.title])
            titleStr.append(nameStr)
            let iconStr = NSAttributedString(string: "\u{e78c}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.primaryText,.baselineOffset:2])
            titleStr.append(iconStr)
            self.homeButton.mxTitleLB.attributedText = titleStr
            let homeNameWidth = min(titleStr.size().width, UIScreen.main.bounds.width - 170)
            self.homeButton.pin.right(of: self.menuButton).marginLeft(6).width(homeNameWidth).height(44).top(AppUIConfiguration.statusBarH)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(homeNameChange), name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
        self.initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = .clear
        
        menuButton.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        menuButton.setTitle("\u{e728}", for: .normal)
        menuButton.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        self.addSubview(menuButton)
        menuButton.pin.left(10).top(AppUIConfiguration.statusBarH).bottom().width(44)
        menuButton.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        
        homeButton = MXLabelButton(frame: CGRect(x: 20, y: AppUIConfiguration.statusBarH, width: 80, height: 44))
        let titleStr = NSMutableAttributedString()
        let nameStr = NSAttributedString(string: localized(key: "我的家"), attributes: [.font: UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H2),.foregroundColor:AppUIConfiguration.NeutralColor.title])
        titleStr.append(nameStr)
        let iconStr = NSAttributedString(string: "\u{e78c}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.primaryText,.baselineOffset:2])
        titleStr.append(iconStr)
        homeButton.mxTitleLB.attributedText = titleStr
        homeButton.addTarget(self, action: #selector(showHomeMenuView), for: .touchUpInside)
        let homeNameWidth = min(titleStr.size().width, UIScreen.main.bounds.width - 170)
        self.addSubview(homeButton)
        self.homeButton.pin.right(of: self.menuButton).marginLeft(6).width(homeNameWidth).height(44).top(AppUIConfiguration.statusBarH)
        
        addButton.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        addButton.setTitle("\u{e6db}", for: .normal)
        addButton.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        self.addSubview(addButton)
        addButton.pin.right(10).top(AppUIConfiguration.statusBarH).bottom().width(44)
        addButton.addTarget(self, action: #selector(addButtonAction(sender:)), for: .touchUpInside)
        self.addButton.isHidden = false
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.menuButton.pin.left(10).top(AppUIConfiguration.statusBarH).bottom().width(44)
        self.addButton.pin.right(10).top(AppUIConfiguration.statusBarH).bottom().width(44)
        self.remindButton.pin.left(of: addButton).marginRight(4).top(AppUIConfiguration.statusBarH).bottom().width(44)
        
        var homeName = localized(key: "我的家")
        if let currentName = MXHomeManager.shard.currentHome?.name  {
            homeName = currentName
        }
        let titleStr = NSMutableAttributedString()
        let nameStr = NSAttributedString(string: homeName, attributes: [.font: UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H2),.foregroundColor:AppUIConfiguration.NeutralColor.title])
        titleStr.append(nameStr)
        let iconStr = NSAttributedString(string: "\u{e78c}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.primaryText,.baselineOffset:2])
        titleStr.append(iconStr)
        self.homeButton.mxTitleLB.attributedText = titleStr
        let homeNameWidth = min(titleStr.size().width, UIScreen.main.bounds.width - 170)
        self.homeButton.pin.right(of: self.menuButton).marginLeft(6).width(homeNameWidth).height(44).top(AppUIConfiguration.statusBarH)
    }
    
}

class MXHintButton: UIButton {
    
    var hintLB = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.hintLB.frame = CGRect(x: 0, y: 0, width: 6, height: 6)
        self.hintLB.backgroundColor = .red
        self.hintLB.layer.cornerRadius = 3.0
        self.hintLB.layer.masksToBounds = true
        self.addSubview(self.hintLB)
        self.hintLB.pin.top(8).right(8).width(6).height(6)
        self.hintLB.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.hintLB.pin.top(8).right(8).width(6).height(6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
