
import Foundation
import UIKit

class MXMainTabBarController: UITabBarController {
        
    var mainTabBarView: MXTabbarView! 
    public var mxHeardView: HomeTitleView = HomeTitleView()
    
    let bleStatusView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
    let bleStatusLB: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageChange), name: Notification.Name("MXNotificationAppLanguageChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        self.view.backgroundColor = AppUIConfiguration.NeutralColor.background
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(self.mxHeardView)
        self.mxHeardView.pin.left().right().top().height(AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH)
        
        self.bleStatusView.backgroundColor = AppUIConfiguration.backgroundColor.level4.FFFFFF
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoBleGuide))
        self.bleStatusView.addGestureRecognizer(tap)
        self.view.addSubview(self.bleStatusView)
        self.bleStatusView.isHidden = true
        self.bleStatusView.pin.left().right().below(of: self.mxHeardView).marginTop(0).height(44)
        
        bleStatusLB.backgroundColor = .clear
        bleStatusLB.font = UIFont.iconFont(size: 16)
        bleStatusLB.textColor = AppUIConfiguration.MXAssistColor.gold
        bleStatusLB.textAlignment = .left
        bleStatusLB.text = "\u{e70c}" + " " + localized(key: "未连接蓝牙提示")
        self.bleStatusView.addSubview(bleStatusLB)
        bleStatusLB.pin.left(16).right(16).top().bottom()
        
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        self.tabBar.layer.shadowOffset = CGSize.zero
        self.tabBar.layer.shadowOpacity = 1
        self.tabBar.layer.shadowRadius = 8
        self.tabBar.backgroundColor = AppUIConfiguration.backgroundColor.level2.FFFFFF

        initSubviews()
        self.createMainTabBarView()
    }
    
    @objc func appDidBecomeActive() {
        if MXHomeManager.shard.currentHome != nil {
            MeshSDK.sharedInstance.connect()
        }
    }
    
    @objc func appLanguageChange() {
        self.mainTabBarView.removeFromSuperview()
        self.initSubviews()
        self.createMainTabBarView()
    }
    
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.bleStatusView.isHidden = !MXHomeManager.shard.isShowBleConnectStatus
        }
    }
    
    @objc func gotoBleGuide() {
        let url = "https://com.mxchip.bta/page/home/bleConnectGuide"
        MXURLRouter.open(url: url, params: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MeshSDK.sharedInstance.connect()
        if MXHomeManager.shard.currentHome != nil {
            self.discoverDevice()
        }
        self.checkNewMessage()
        self.mxHeardView.homeNameChange()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mxHeardView.pin.left().right().top().height(AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH)
        self.bleStatusView.pin.left().right().below(of: self.mxHeardView).marginTop(0).height(44)
        self.bleStatusLB.pin.left(16).right(16).top().bottom()
        self.viewControllers?.forEach({ (vc:UIViewController) in
            vc.view.pin.all()
        })
    }
    
    override func viewSafeAreaInsetsDidChange() {
        self.viewWillLayoutSubviews()
    }
    
    func initSubviews() -> Void {
        var pageList = [UIViewController]()
        let homePage = MXMainHomePage()
        homePage.tabBarItem = UITabBarItem(title: localized(key: "首页"), image: UIImage(named: "tabbar_home_unSelected"), selectedImage: nil)
        pageList.append(homePage)
        let roomPage = MXMainRoomPage()
        roomPage.tabBarItem = UITabBarItem(title: localized(key: "设备"), image: UIImage(named: "tabbar_device_unSelected"), selectedImage: nil)
        pageList.append(roomPage)
        let scenesPage = MXMainScenePage()
        scenesPage.tabBarItem = UITabBarItem(title: localized(key: "智能"), image: UIImage(named: "tabbar_scene_unSelected"), selectedImage: nil)
        pageList.append(scenesPage)
        self.viewControllers = pageList
        self.selectedIndex = 0
    }
    
    
    private func createMainTabBarView(){
        
        let tabBarRect = CGRect(x: 0, y: 0, width: self.tabBar.frame.size.width, height: 49);
        
        self.mainTabBarView = MXTabbarView(frame: tabBarRect,tabBarItems: self.tabBar.items ?? [UITabBarItem](), animations: ["home","device","smart"]);
        self.mainTabBarView.delegate = self
        self.tabBar.addSubview(mainTabBarView)
    }
    
    func discoverDevice() {
        self.mxHeardView.addButton.hintLB.isHidden = true
    }
    
    @objc func checkNewMessage() {
        self.mxHeardView.remindButton.hintLB.isHidden = true
        
    }

}

extension MXMainTabBarController : MXCustomTabBarViewDelegate {
    func mxCustomTabBarView(customTabBarView: MXTabbarView, _ didSelectedIndex: Int) {
        self.selectedIndex = didSelectedIndex
    }
}
