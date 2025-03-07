
import Foundation

class MXAddDeviceHeaderView: UIView {
    
    public typealias DidMoreCallback = () -> ()
    public var didMoreCallback : DidMoreCallback!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLB)
        self.titleLB.pin.left(16).top(26).right(16).height(24)
        self.addSubview(self.desLB)
        self.desLB.pin.below(of: self.titleLB).marginTop(16).left(16).right(16).height(44)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.left(16).top(26).right(16).height(24)
        self.desLB.pin.below(of: self.titleLB).marginTop(16).left(16).right(16).height(44)
    }
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.zero)
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.textAlignment = .left
        _titleLB.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H0)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.title
        _titleLB.text = localized(key:"设备添加中")
        
        return _titleLB
    }()
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.systemFont(ofSize:AppUIConfiguration.TypographySize.H4);
        _desLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        _desLB.textAlignment = .left
        _desLB.numberOfLines = 2
        _desLB.text = localized(key:"请把手机、设备和路由器尽量靠近，保证手机网络畅通")
        
        return _desLB
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
