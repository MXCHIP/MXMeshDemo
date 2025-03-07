
import Foundation
import UIKit

class MXMainRoomPage: MXBaseViewController {
    
    var vcArray = Array<MXRoomDevicesPage>()
    var pageHeadView:MXPageHeadView?
    var pagevc:MXPageContentView?
    var currentVCIndex = 0
    var roomTitles = Array<String>()
    
    var roomBgColorHex: String?
    
    let gradientLayer = CAGradientLayer()
    
    let headerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mxNavigationBar.isHidden = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(homeNameChange), name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDataSource(notif:)), name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
        
        self.view.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
        self.addGradientBackground()
        self.hidesBottomBarWhenPushed = false
        self.title = nil
        
        self.headerView.backgroundColor = .clear
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left().right().top(16).height(44)
        
        self.setupRoomData()
    }
    
    public func setupRoomData() {
        for vc in self.vcArray {
            vc.removeFromParent()
        }
        self.roomTitles.removeAll()
        self.vcArray.removeAll()
        
        self.currentVCIndex = 0
        if let rooms = MXHomeManager.shard.currentHome?.rooms {
            for info in rooms {
                if let room_name = info.name {
                    self.roomTitles.append(room_name)
                    let vc = MXRoomDevicesPage()
                    vc.type = 3
                    vc.roomId = info.roomId
                    vc.hideMXNavigationBar = true
                    self.vcArray.append(vc)
                }
            }
        }
        
        self.loadPageView()
    }
    
    func addGradientBackground() {
        
        self.gradientLayer.colors = [UIColor(hex: AppUIConfiguration.MXBackgroundColor.bg7.toHexString, alpha: 1.0).cgColor,UIColor(hex: AppUIConfiguration.MXBackgroundColor.bg7.toHexString, alpha: 0.0).cgColor]
        
        self.gradientLayer.locations = [0.0,1.0]
        
        self.gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        
        self.gradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        
        self.gradientLayer.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 480)
        gradientLayer.opacity = 0.45
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let rooms = MXHomeManager.shard.currentHome?.rooms {
            let room_names = rooms.map({$0.name ?? ""}) as [String]
            let find_namesSet = Set(room_names)
            let namesSet = Set(self.roomTitles)
            if !find_namesSet.isSubset(of: namesSet) {  
                self.roomTitles.removeAll()
                self.roomTitles.append(contentsOf: room_names)
                self.pageHeadView?._titles = self.roomTitles
            }
            
            if self.vcArray.count > self.currentVCIndex {
                let currentVC = self.vcArray[self.currentVCIndex]
                currentVC.viewWillAppear(animated)
            }
            self.refreshBgColor()
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
        self.headerView.pin.left().right().top(16).height(44)
        self.pagevc?.pin.left().right().below(of: self.headerView).marginTop(0).bottom()
    }
    
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.viewDidLayoutSubviews()
        }
    }
    
    @objc func homeNameChange() {
        DispatchQueue.main.async {
            self.setupRoomData()
        }
    }
    
    @objc func refreshDataSource(notif: Notification) {
        DispatchQueue.main.async {
            self.setupRoomData()
        }
    }
    
    
    deinit {
        
        print("页面释放了")
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadPageView()  {
        
        self.pageHeadView?.removeFromSuperview()
        self.pagevc?.removeFromSuperview()
        
        var attri = MXPageHeadTextAttribute()
        attri.needBottomLine = true
        attri.defaultFontSize = AppUIConfiguration.TypographySize.H1
        attri.defaultTextColor = AppUIConfiguration.NeutralColor.secondaryText
        attri.selectedFontSize = AppUIConfiguration.TypographySize.H1
        attri.selectedTextColor = AppUIConfiguration.NeutralColor.title
        attri.bottomLineWidth = 4
        attri.bottomLineHeight = 4
        attri.bottomLineColor = AppUIConfiguration.NeutralColor.title
        
        pageHeadView = MXPageHeadView (frame: CGRect (x: 0, y: 0, width: self.view.frame.size.width-35, height: 44), titles: roomTitles, delegate: self ,textAttributes:attri)
        pageHeadView?.backgroundColor = UIColor.clear
        self.headerView.addSubview(pageHeadView!)
        
        let moreBtn = UIButton.init(type: .custom)
        moreBtn.backgroundColor = UIColor.clear
        moreBtn.frame = CGRect.init(x: self.view.frame.size.width - 50, y: 0, width: 50, height: 44)
        moreBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        moreBtn.setTitle("\u{e6fa}", for: .normal)
        moreBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        
        moreBtn.addTarget(self, action: #selector(gotoRoomManager), for: .touchUpInside)
        self.headerView.addSubview(moreBtn)
        
        let frame = CGRect (x: 0, y: pageHeadView!.frame.size.height, width: self.view.frame.width, height: self.view.frame.size.height - pageHeadView!.frame.size.height)
        pagevc = MXPageContentView.init(frame: frame, childViewControllers: vcArray, parentViewController: self, delegate: self)
        self.contentView.addSubview(pagevc!)
        self.pagevc?.pin.left().right().below(of: self.headerView).marginTop(0).bottom()
    }
    
    @objc func gotoRoomManager() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        var menu_list = [MXMenuInfo]()
        let menuInfo = MXMenuInfo()
        menuInfo.name = localized(key:"Room_房间管理")
        menuInfo.jumpUrl = "https://com.mxchip.bta/page/home/rooms"
        if let home_info = MXHomeManager.shard.currentHome, let result = MXHomeInfo.mx_keyValue(home_info)  {
            let params = ["data": result]
            menuInfo.params = params
        }
        menuInfo.isAuthorityCheck = true
        menu_list.append(menuInfo)
        let menuInfo2 = MXMenuInfo()
        menuInfo2.name = localized(key:"Room_设备管理")
        menuInfo2.jumpUrl = "com.mxchip.bta/page/device/editList"
        if self.vcArray.count > self.currentVCIndex {
            let vc = self.vcArray[self.currentVCIndex]
            var params2 = [String: Any]()
            params2["roomId"] = vc.roomId
            params2["type"] = 3
            menuInfo2.params = params2
        }
        menuInfo2.isAuthorityCheck = true
        menu_list.append(menuInfo2)
        let menuInfo3 = MXMenuInfo()
        menuInfo3.name = localized(key:"Room_所有设备")
        menuInfo3.jumpUrl = "com.mxchip.bta/page/device/list"
        var params3 = [String: Any]()
        params3["type"] = 3
        menuInfo3.params = params3
        menuInfo3.isAuthorityCheck = true
        menu_list.append(menuInfo3)
        let menuAlertView = MXMenuAlertView(contentFrame: CGRect(x: self.view.frame.size.width - 130, y: AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH + self.headerView.frame.maxY, width: 120, height: 180), menuList: menu_list)
        menuAlertView.show()
    }
}

extension MXMainRoomPage:MXPageHeadViewDelegate,MXPageViewControllerDelegate {
    
    func mx_pageHeadViewSelectedAt(_ index: Int) {
        
        pagevc?.scrollToPageAtIndex(index)
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
        self.refreshBgColor()
        pageHeadView?.scrollToItemAtIndex(index)
    }
    
    func refreshBgColor() {
        guard let rooms = MXHomeManager.shard.currentHome?.rooms else {
            return
        }
        self.roomBgColorHex = nil
        let roomIndex = self.currentVCIndex
        if roomIndex >= 0, rooms.count > roomIndex {
            let info = rooms[roomIndex]
            if let bgColor = info.bg_color, bgColor.count > 0 {
                self.roomBgColorHex = bgColor
            }
        }
        if let bg_colorHex = self.roomBgColorHex {
            self.gradientLayer.colors = [UIColor(hex: bg_colorHex, alpha: 1.0).cgColor,UIColor(hex: bg_colorHex, alpha: 0.0).cgColor]
        } else {
            self.gradientLayer.colors = [UIColor(hex: AppUIConfiguration.MXBackgroundColor.bg7.toHexString, alpha: 1.0).cgColor,UIColor(hex: AppUIConfiguration.MXBackgroundColor.bg7.toHexString, alpha: 0.0).cgColor]
        }
    }
}
