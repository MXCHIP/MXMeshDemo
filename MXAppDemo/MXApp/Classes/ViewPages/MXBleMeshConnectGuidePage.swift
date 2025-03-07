
import Foundation
import UIKit

class MXBleMeshConnectGuidePage: MXBaseViewController {
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
        
        self.title = localized(key:"未连接蓝牙")
        
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.left(10).right(10).top(12).minHeight(476).maxHeight(screenHeight - AppUIConfiguration.navBarH - AppUIConfiguration.statusBarH - 24)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.width(80).height(80).top(40).hCenter()
        
        self.nameLB.text = localized(key: "蓝牙未连接设备")
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.below(of: self.iconView).marginTop(16).left(16).right(16).height(20)
        
        
        self.subTitleLB1.text = localized(key: "说明：")
        self.bgView.addSubview(self.subTitleLB1)
        self.subTitleLB1.pin.below(of: self.nameLB).marginTop(24).left(16).right(16).height(18)
        
        self.subContentLB1.text = localized(key: "蓝牙未连接描述")
        self.bgView.addSubview(self.subContentLB1)
        self.subContentLB1.pin.below(of: self.subTitleLB1).marginTop(8).left(16).right(16).sizeToFit(.width)
        
        self.subTitleLB2.text = localized(key: "蓝牙未连接设备问题：")
        self.bgView.addSubview(self.subTitleLB2)
        self.subTitleLB2.pin.below(of: self.subContentLB1).marginTop(24).left(16).right(16).height(18)
        
        self.subContentLB2.text = localized(key: "蓝牙未连接原因描述")
        self.bgView.addSubview(self.subContentLB2)
        self.subContentLB2.pin.below(of: self.subTitleLB2).marginTop(8).left(16).right(16).sizeToFit(.width)
        
        self.bgView.pin.left(10).right(10).top(12).minHeight(476).maxHeight(screenHeight - AppUIConfiguration.navBarH - AppUIConfiguration.statusBarH - 24).sizeToFit(.width)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.iconView.pin.width(80).height(80).top(40).hCenter()
        self.nameLB.pin.below(of: self.iconView).marginTop(16).left(16).right(16).height(20)
        self.subTitleLB1.pin.below(of: self.nameLB).marginTop(24).left(16).right(16).height(18)
        self.subContentLB1.pin.below(of: self.subTitleLB1).marginTop(8).left(16).right(16).sizeToFit(.width)
        self.subTitleLB2.pin.below(of: self.subContentLB1).marginTop(24).left(16).right(16).height(18)
        self.subContentLB2.pin.below(of: self.subTitleLB2).marginTop(8).left(16).right(16).sizeToFit(.width)
        
        self.bgView.pin.left(10).right(10).top(12).minHeight(476).maxHeight(screenHeight - AppUIConfiguration.navBarH - AppUIConfiguration.statusBarH - 24).sizeToFit(.width)
    }
    
    private lazy var bgView : UIScrollView = {
        let _bgView = UIScrollView(frame: .zero)
        _bgView.showsVerticalScrollIndicator = false
        _bgView.showsHorizontalScrollIndicator = false
        _bgView.backgroundColor = AppUIConfiguration.MXBackgroundColor.bg0
        _bgView.layer.cornerRadius = 16.0
        return _bgView
    }()
    
    lazy var iconView : UILabel = {
        let _iconView = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        _iconView.backgroundColor = UIColor(hex: AppUIConfiguration.MXAssistColor.green.toHexString, alpha: 0.1)
        _iconView.text = "\u{e7cd}"
        _iconView.textAlignment = .center
        _iconView.textColor = AppUIConfiguration.MXAssistColor.green
        _iconView.font = UIFont.iconFont(size: 30)
        _iconView.layer.masksToBounds = true
        _iconView.layer.cornerRadius = 40
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.backgroundColor = .clear
        _nameLB.textAlignment = .center
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title
        _nameLB.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4)
        return _nameLB
    }()
    
    lazy var subTitleLB1 : UILabel = {
        let _subTitleLB1 = UILabel(frame: .zero)
        _subTitleLB1.backgroundColor = .clear
        _subTitleLB1.textAlignment = .left
        _subTitleLB1.textColor = AppUIConfiguration.NeutralColor.title
        _subTitleLB1.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        return _subTitleLB1
    }()
    
    lazy var subContentLB1 : UILabel = {
        let _subContentLB1 = UILabel(frame: .zero)
        _subContentLB1.backgroundColor = .clear
        _subContentLB1.textAlignment = .left
        _subContentLB1.numberOfLines = 0
        _subContentLB1.textColor = AppUIConfiguration.NeutralColor.primaryText
        _subContentLB1.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        return _subContentLB1
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

extension MXBleMeshConnectGuidePage: MXURLRouterDelegate {
    
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXBleMeshConnectGuidePage()
        return controller
    }
}
