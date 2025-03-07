
import Foundation
import SDWebImage

class DiscoveryDeviceCell: UITableViewCell {
    public typealias MoreDeviceActionCallback = (_ item: MXProvisionDeviceInfo) -> ()
    public var moreActionCallback : MoreDeviceActionCallback!
    var deviceInfo : MXProvisionDeviceInfo!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        
        self.bgView.layer.cornerRadius = 16
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(16).top(20).width(40).height(40)
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).top(20).height(20).right(60)
        
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(4).height(16).right(60)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
        self.actionBtn.isUserInteractionEnabled = false
        
        
        self.actionBtn.setTitle("\u{e715}", for: .normal)
        self.actionBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moreAction() {
        if self.deviceInfo.isSelected {
            self.deviceInfo.isSelected = false
        } else {
            self.deviceInfo.isSelected = true
        }
        self.refreshView(info: self.deviceInfo)
        self.moreActionCallback?(self.deviceInfo)
    }
    
    public func refreshView(info: MXProvisionDeviceInfo, isReplace: Bool? = nil) {
        self.iconView.image = nil
        self.nameLB.text = nil
        self.desLB.text = nil
        
        self.deviceInfo = info
        self.nameLB.text = info.showName
        
        if let mac = self.deviceInfo.mac {
            self.desLB.text = mac
        } else if let dn = self.deviceInfo.deviceName {  
            self.desLB.text = dn
        }
        if let _ = isReplace {
            self.actionBtn.isHidden = true
        } else {
            self.actionBtn.isHidden = false
            if self.deviceInfo.isSelected {
                self.actionBtn.setTitle("\u{e6f3}", for: .normal)
                self.actionBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
            } else {
                self.actionBtn.setTitle("\u{e6fb}", for: .normal)
                self.actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
            }
        }
        if let productImage = info.productInfo?.image {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        self.iconView.pin.left(16).top(20).width(40).height(40)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).top(20).height(20).right(60)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(4).height(16).right(60)
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font =  UIFont.systemFont(ofSize:AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        return _nameLB
    }()
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font =  UIFont.systemFont(ofSize:AppUIConfiguration.TypographySize.H6);
        _desLB.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        return _desLB
    }()
    
    lazy public var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        _actionBtn.setTitle("\u{e715}", for: .normal)
        _actionBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        return _actionBtn
    }()
}
