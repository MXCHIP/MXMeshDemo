
import Foundation

class MXWifiInputView: UIView {
    
    public typealias DidActionCallback = () -> ()
    public var didActionCallback : DidActionCallback!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = AppUIConfiguration.NeutralColor.dividers.cgColor
        self.layer.cornerRadius = self.frame.height/2.0
        
        self.addSubview(self.iconView)
        self.iconView.pin.left(24).width(20).height(20).vCenter()
        
        self.addSubview(self.actionBtn)
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(10).left(of: self.actionBtn).marginRight(0).top().bottom()
    }
    
    override func layoutSubviews() {
        self.iconView.pin.left(24).width(20).height(20).vCenter()
        self.actionBtn.pin.right(14).width(40).height(40).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(10).left(of: self.actionBtn).marginRight(0).top().bottom()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var iconView : UILabel = {
        let _iconView = UILabel(frame: .zero)
        _iconView.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1);
        _iconView.textColor = AppUIConfiguration.NeutralColor.primaryText;
        _iconView.textAlignment = .center
        return _iconView
    }()
    
    lazy var nameLB : UITextField = {
        let _nameLB = UITextField(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy public var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        _actionBtn.setTitle(nil, for: .normal)
        _actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        _actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        return _actionBtn
    }()
    
    @objc func didAction() {
        self.didActionCallback?()
    }
    
}
