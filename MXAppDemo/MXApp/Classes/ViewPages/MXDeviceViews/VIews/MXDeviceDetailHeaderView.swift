
import Foundation
import SDWebImage

class MXDeviceDetailHeaderView: UIView {
    
    public typealias DidActionCallback = (_ item: Any) -> ()
    public var didActionCallback : DidActionCallback!
    
    var info : Any!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(16).width(48).height(48).vCenter()
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).right(60).height(20).top(28)
        
        self.bgView.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(8).right(60).height(16)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(0).width(52).height(52).bottom(10)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
    }
    
    @objc func didAction() {
        self.didActionCallback?(self.info as Any)
    }
    
    public func refreshView(info: MXDeviceInfo) {
        self.nameLB.text = info.showName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if info.objType == 0 {
            let create_time = Date.init(timeIntervalSince1970: TimeInterval(info.bindTime))
            let timeStr = formatter.string(from: create_time)
            self.desLB.text = localized(key:"加入时间") + ": " + "\(timeStr)"
        } else {
            let create_time = Date.init(timeIntervalSince1970: TimeInterval(info.createTime))
            let timeStr = formatter.string(from: create_time)
            self.desLB.text = localized(key:"创建时间") + ": " + "\(timeStr)"
        }
        
        if let imageStr = info.image, imageStr.count > 0 {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        } else if let imageStr = info.productInfo?.image, imageStr.count > 0 {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        }
        
        self.info = info
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.iconView.pin.left(16).width(48).height(48).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).right(50).height(20).top(28)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(8).right(50).height(16)
        self.actionBtn.pin.right(0).width(52).height(52).bottom(10)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        _bgView.layer.cornerRadius = 16.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 48, height: 48))
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6);
        _desLB.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _desLB.textAlignment = .left
        return _desLB
    }()
    
    lazy var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        _actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        _actionBtn.setTitle("\u{e71e}", for: .normal)
        return _actionBtn
    }()
}
