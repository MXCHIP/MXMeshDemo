
import Foundation
import SDWebImage


class MXAddDeviceInitViewController: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String!
    public var wifiSSID : String?
    public var wifiPassword : String?
    public var productInfo : MXProductInfo?
    public var deviceList = Array<MXProvisionDeviceInfo>()
    public var isReplace: Bool?
    public var replacedDevice: MXDeviceInfo?
    
    var helpImageUrl:String?
    
    var roomId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"初始化设备")
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.bottomView.addSubview(self.nextBtn)
        self.nextBtn.pin.left(16).right(16).height(50).vCenter()
        
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.above(of: self.bottomView).marginBottom(10).left(10).top(10).right(10)
        
        self.bgView.addSubview(self.headerView)
        self.headerView.pin.left().top().right().height(118)
        self.headerView.titleLB.text = localized(key:"初始化设备")
        self.headerView.desLB.text = localized(key:"长按重置按键5秒钟，指示灯闪烁。")
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.width(200).height(200).center()
        if let productImage = self.productInfo?.image {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        }
        
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.left(24).right(24).bottom(24).height(20)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.bottomView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        self.nextBtn.pin.left(16).right(16).height(50).top(10)
        self.bgView.pin.above(of: self.bottomView).marginBottom(10).left(10).top(10).right(10)
        self.headerView.pin.left().top().right().height(118)
        self.iconView.pin.width(200).height(200).center()
        self.desLB.pin.left(24).right(24).bottom(24).height(20)
    }
    
    private lazy var bgView : UIView = {
        let _bgView = UIView()
        _bgView.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    private lazy var headerView : MXAddDeviceHeaderView = {
        let _headerView = MXAddDeviceHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 134))
        return _headerView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    private lazy var desLB : UILabel = {
        
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _desLB.textColor = AppUIConfiguration.NeutralColor.title
        _desLB.textAlignment = .center
        
        let str = NSMutableAttributedString()
        let str1 = NSAttributedString(string: localized(key:"设备状态不对？"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.primaryText])
        str.append(str1)
        let str2 = NSAttributedString(string: localized(key:"请尝试"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.MainColor.C0])
        str.append(str2)
        _desLB.attributedText = str
        
        _desLB.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoIntroducePage))
        _desLB.addGestureRecognizer(tap)
        
        return _desLB
    }()
    
    private lazy var bottomView : UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70))
        _bottomView.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        _bottomView.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        _bottomView.layer.shadowOffset = CGSize.zero
        _bottomView.layer.shadowOpacity = 1
        _bottomView.layer.shadowRadius = 8
        return _bottomView
    }()
    
    lazy var nextBtn : UIButton = {
        let _nextBtn = UIButton(type: .custom)
        _nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _nextBtn.setTitle(localized(key:"确定指示灯闪烁"), for: .normal)
        _nextBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        _nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        _nextBtn.layer.cornerRadius = 25
        _nextBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return _nextBtn
    }()
}

extension MXAddDeviceInitViewController {
    
    @objc func nextPage() {
        var params = [String :Any]()
        params["networkKey"] = self.networkKey
        params["productInfo"] = productInfo
        params["ssid"] = self.wifiSSID
        params["password"] = self.wifiPassword
        if let isReplace = self.isReplace {
            params["isReplace"] = isReplace
        }
        if let replacedDevice = self.replacedDevice {
            params["replacedDevice"] = replacedDevice
        }
        params["roomId"] = self.roomId
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/autoSearch", params: params)
    }
    
    @objc func gotoIntroducePage() {
        if self.helpImageUrl != nil {
            var params = [String :Any]()
            params["imageUrl"] = self.helpImageUrl
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/addHelp", params: params)
        }
    }
}

extension MXAddDeviceInitViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceInitViewController()
        controller.networkKey = params["networkKey"] as? String
        controller.wifiSSID = params["ssid"] as? String
        controller.wifiPassword = params["password"] as? String
        controller.productInfo = params["productInfo"] as? MXProductInfo
        controller.isReplace = params["isReplace"] as? Bool
        controller.replacedDevice = params["replacedDevice"] as? MXDeviceInfo
        if let list = params["devices"] as? Array<MXProvisionDeviceInfo> {
            controller.deviceList = list
        }
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
