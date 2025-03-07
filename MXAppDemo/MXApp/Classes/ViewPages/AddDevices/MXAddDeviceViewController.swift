
import Foundation

class MXAddDeviceViewController: MXBaseViewController {
    
    @objc func searchDevices(sender: UITapGestureRecognizer) -> Void {
        let url = "com.mxchip.bta/page/device/autoSearch"
        var params = [String :Any]()
        params["roomId"] = self.roomId
        MXURLRouter.open(url: url, params: params)
    }
    
    var vcArray = Array<UIViewController>()
    var pageHeadView:MXPageHeadView!
    var pagevc:MXPageContentView!
    var currentVCIndex = 0
    
    var roomId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var attri = MXPageHeadTextAttribute()
        attri.needBottomLine = true
        attri.defaultFontSize = AppUIConfiguration.TypographySize.H2
        attri.defaultTextColor = AppUIConfiguration.NeutralColor.secondaryText
        attri.selectedFontSize = AppUIConfiguration.TypographySize.H2
        attri.selectedTextColor = AppUIConfiguration.NeutralColor.title
        attri.bottomLineWidth = 4
        attri.bottomLineHeight = 4
        attri.bottomLineColor = AppUIConfiguration.NeutralColor.title
        attri.itemSpacing = 10
        attri.itemOffset = 0
        attri.itemWidth = 80
        
        
        let titles = [localized(key:"自动发现"), localized(key:"手动添加")]
        pageHeadView = MXPageHeadView (frame: CGRect (x: 0, y: 2, width: 200, height: 40), titles: titles, delegate: self ,textAttributes:attri)
        let headWidth = min(200, pageHeadView.contentWidth)
        pageHeadView.backgroundColor = UIColor.clear
        self.mxNavigationBar.titleLB.addSubview(pageHeadView)
        pageHeadView.pin.width(headWidth).height(AppUIConfiguration.navBarH).hCenter()
        
        let searchLabel = UILabel(frame: .zero)
        self.mxNavigationBar.rightView.addSubview(searchLabel)
        searchLabel.textColor = AppUIConfiguration.NeutralColor.title
        searchLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        searchLabel.text = "\u{e727}"
        searchLabel.pin.width(25).height(25).center()
        searchLabel.isUserInteractionEnabled = true
        let tapSearch = UITapGestureRecognizer(target: self, action: #selector(searchDevices(sender:)))
        searchLabel.addGestureRecognizer(tapSearch)
        
        let searchVC = MXAutoSearchViewController()
        searchVC.networkKey = MXHomeManager.shard.currentHome?.networkKey
        searchVC.hideMXNavigationBar = true
        vcArray.append(searchVC)
        let manualVC = MXManualViewController()
        manualVC.networkKey = MXHomeManager.shard.currentHome?.networkKey
        manualVC.hideMXNavigationBar = true
        vcArray.append(manualVC)
        
        let frame = CGRect (x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
        pagevc = MXPageContentView.init(frame: frame, childViewControllers: vcArray, parentViewController: self, delegate: self)
        self.contentView.addSubview(pagevc)
        pagevc.pin.all()
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        pageHeadView.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
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
        self.pagevc.pin.all()
        self.pageHeadView.pin.width(200).height(40).center()
    }
    
    @objc func scanCode() {
        
    }
}

extension MXAddDeviceViewController:MXPageHeadViewDelegate,MXPageViewControllerDelegate {
    
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

extension MXAddDeviceViewController: MXURLRouterDelegate {
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXAddDeviceViewController()
        vc.roomId = params["roomId"] as? Int
        return vc
    }
}
