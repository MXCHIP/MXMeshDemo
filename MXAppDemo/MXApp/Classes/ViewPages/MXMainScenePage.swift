
import Foundation
import UIKit

class MXMainScenePage: MXBaseViewController {
    
    var vcArray = Array<UIViewController>()
    var headerView: UIView!
    var pageHeadView:MXPageHeadView!
    var pagevc:MXPageContentView!
    var currentVCIndex = 0
    
    let gradientLayer = CAGradientLayer()
    let moreBtn = UIButton.init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mxNavigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = false
        self.view.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(homeNameChange), name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
        
        self.addGradientBackground()
        
        self.title = nil
        
        self.loadPageView()
    }
    
    func addGradientBackground() {
        
        self.gradientLayer.colors = [AppUIConfiguration.MXBackgroundColor.bg7.cgColor,UIColor(hex: AppUIConfiguration.MXBackgroundColor.bg7.toHexString, alpha: 0.0).cgColor]
        
        self.gradientLayer.locations = [0.0,1.0]
        
        self.gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        
        self.gradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        
        self.gradientLayer.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 480)
        gradientLayer.opacity = 0.45
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.viewWillAppear(animated)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.viewWillDisappear(animated)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerH = AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH + (!MXHomeManager.shard.isShowBleConnectStatus ? 0 : 44)
        self.contentView.pin.left().right().top(headerH).bottom()
        self.headerView.pin.top(16).left().right().height(44)
        self.pagevc.pin.left().right().below(of: self.headerView).marginTop(0).bottom()
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    func loadPageView()  {
        
        self.headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        self.headerView.backgroundColor = UIColor.clear
        self.contentView.addSubview(headerView)
        self.headerView.pin.top(16).left().right().height(44)
        
        var attri = MXPageHeadTextAttribute()
        attri.itemWidth = 80
        attri.needBottomLine = true
        attri.defaultFontSize = AppUIConfiguration.TypographySize.H1
        attri.defaultTextColor = AppUIConfiguration.NeutralColor.secondaryText
        attri.selectedFontSize = AppUIConfiguration.TypographySize.H1
        attri.selectedTextColor = AppUIConfiguration.NeutralColor.title
        attri.bottomLineWidth = 4
        attri.bottomLineHeight = 4
        attri.bottomLineColor = AppUIConfiguration.NeutralColor.title
        
        
        self.moreBtn.backgroundColor = UIColor.clear
        self.moreBtn.frame = CGRect.init(x: self.view.frame.size.width - 50, y: 0, width: 50, height: 44)
        self.moreBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        self.moreBtn.setTitle("\u{e6fa}", for: .normal)
        self.moreBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        self.moreBtn.addTarget(self, action: #selector(gotoManager), for: .touchUpInside)
        self.headerView.addSubview(self.moreBtn)
        
        
        var titles:[String] = [String]()
        
        titles.append(localized(key:"我的场景"))
        let sceneVC = ScenesListViewController()
        sceneVC.hideMXNavigationBar = true
        vcArray.append(sceneVC)
        
        pageHeadView = MXPageHeadView (frame: CGRect (x: 0, y: 0, width: self.view.frame.size.width-60, height: 44), titles: titles, delegate: self ,textAttributes:attri)
        self.headerView.addSubview(pageHeadView)
        
        let frame = CGRect (x: 0, y: pageHeadView.frame.size.height, width: self.view.frame.width, height: self.view.frame.size.height - pageHeadView.frame.size.height)
        pagevc = MXPageContentView.init(frame: frame, childViewControllers: vcArray, parentViewController: self, delegate: self)
        self.contentView.addSubview(pagevc)
        self.pagevc.pin.left().right().below(of: self.headerView).marginTop(0).bottom()
    }
    
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.viewDidLayoutSubviews()
        }
    }
    
    @objc func homeNameChange() {
        DispatchQueue.main.async {
            self.viewWillAppear(false)
        }
    }
    
    @objc func gotoManager() {
        
        var menu_list = [MXMenuInfo]()
        let menuInfo = MXMenuInfo()
        menuInfo.name = localized(key:"场景管理")
        menuInfo.jumpUrl = "https://com.mxchip.bta/page/scene/editList"
        var params = [String : Any]()
        params["sceneType"] = "one_click"
        menuInfo.isAuthorityCheck = true
        menuInfo.params = params
        menu_list.append(menuInfo)
        
        let menuInfo2 = MXMenuInfo()
        menuInfo2.name = localized(key:"自动化管理")
        menuInfo2.jumpUrl = "https://com.mxchip.bta/page/scene/editList"
        var params2 = [String : Any]()
        params2["sceneType"] = "local_auto"
        menuInfo2.isAuthorityCheck = true
        menuInfo2.params = params2
        menu_list.append(menuInfo2)
        
        let menuAlertView = MXMenuAlertView(contentFrame: CGRect(x: self.view.frame.size.width - 130, y: AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH + self.headerView.frame.maxY, width: 120, height: 60), menuList: menu_list)
        menuAlertView.show()
    }
}

extension MXMainScenePage:MXPageHeadViewDelegate,MXPageViewControllerDelegate {
    
    func mx_pageHeadViewSelectedAt(_ index: Int) {
        
        pagevc.scrollToPageAtIndex(index)
    }
    
    func mx_pageControllerSelectedAt(_ index: Int) {
        
        guard index != self.currentVCIndex else{ return }
        
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.viewWillDisappear(false)
        }
        self.currentVCIndex = index
        if self.vcArray.count > self.currentVCIndex {
            let currentVC = self.vcArray[self.currentVCIndex]
            currentVC.viewWillAppear(false)
        }
        pageHeadView.scrollToItemAtIndex(index)
    }
}
