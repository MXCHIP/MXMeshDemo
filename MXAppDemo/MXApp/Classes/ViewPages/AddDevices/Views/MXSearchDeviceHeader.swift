
import Foundation

class MXSearchDeviceHeader: UIView {
    
    public typealias DidActionCallback = () -> ()
    public var didActionCallback : DidActionCallback!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.left(20).right(20).top(30).height(20)
        
        self.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB).marginTop(16).height(16).width(200).hCenter()
    }
    
    override func layoutSubviews() {
        self.nameLB.pin.left(20).right(20).top(30).height(20)
        self.desLB.pin.below(of: self.nameLB).marginTop(16).height(16).sizeToFit(.height).hCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H6)
        _desLB.textColor = AppUIConfiguration.MainColor.C0;
        _desLB.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionTap))
        _desLB.addGestureRecognizer(tap)
        
        return _desLB
    }()
    
    @objc func actionTap() {
        self.didActionCallback?()
    }
    
}
