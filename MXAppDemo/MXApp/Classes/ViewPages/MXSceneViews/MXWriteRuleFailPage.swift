
import Foundation

class MXWriteRuleFailPage: MXBaseViewController {
    var stepList = Array<String>()
    
    public var networkKey : String!
    public var wifiSSID : String?
    public var wifiPassword : String?
    public var productInfo : MXProductInfo?
    public var deviceList = Array<MXProvisionDeviceInfo>()
    public var isReplace: Bool?
    public var replacedDevice: MXDeviceInfo?
    
    var helpImageUrl:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"保存失败")
        
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.left(10).right(10).top(12).minHeight(240).maxHeight(screenHeight - AppUIConfiguration.navBarH - AppUIConfiguration.statusBarH - 24)
        
        
        self.subTitleLB2.text = localized(key: "保存失败原因")
        self.bgView.addSubview(self.subTitleLB2)
        self.subTitleLB2.pin.top(16).left(16).right(16).height(18)
        
        self.subContentLB2.text = localized(key: "保存原因描述")
        self.bgView.addSubview(self.subContentLB2)
        self.subContentLB2.pin.below(of: self.subTitleLB2).marginTop(24).left(16).right(16).sizeToFit(.width)
        
        self.bgView.pin.left(10).right(10).top(12).minHeight(476).maxHeight(screenHeight - AppUIConfiguration.navBarH - AppUIConfiguration.statusBarH - 24).sizeToFit(.width)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MXSceneDeviceStatusView.shard.show()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.subTitleLB2.pin.top(16).left(16).right(16).height(18)
        self.subContentLB2.pin.below(of: self.subTitleLB2).marginTop(24).left(16).right(16).sizeToFit(.width)
        
        self.bgView.pin.left(10).right(10).top(12).minHeight(240).maxHeight(screenHeight - AppUIConfiguration.navBarH - AppUIConfiguration.statusBarH - 24).sizeToFit(.width)
    }
    
    private lazy var bgView : UIScrollView = {
        let _bgView = UIScrollView(frame: .zero)
        _bgView.showsVerticalScrollIndicator = false
        _bgView.showsHorizontalScrollIndicator = false
        _bgView.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    lazy var subTitleLB2 : UILabel = {
        let _subTitleLB2 = UILabel(frame: .zero)
        _subTitleLB2.backgroundColor = .clear
        _subTitleLB2.textAlignment = .left
        _subTitleLB2.textColor = AppUIConfiguration.NeutralColor.title
        _subTitleLB2.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        return _subTitleLB2
    }()
    
    lazy var subContentLB2 : UILabel = {
        let _subContentLB2 = UILabel(frame: .zero)
        _subContentLB2.backgroundColor = .clear
        _subContentLB2.textAlignment = .left
        _subContentLB2.numberOfLines = 0
        _subContentLB2.textColor = AppUIConfiguration.NeutralColor.primaryText
        _subContentLB2.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        return _subContentLB2
    }()
}

extension MXWriteRuleFailPage: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXWriteRuleFailPage()
        return controller
    }
}
