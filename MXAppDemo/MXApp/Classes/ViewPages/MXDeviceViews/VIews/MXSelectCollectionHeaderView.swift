
import Foundation

class MXSelectCollectionHeaderView: UICollectionReusableView {
    
    public typealias DidActionCallback = () -> ()
    public var didActionCallback : DidActionCallback?
    
    var isSelected = false {
        didSet {
            if self.isSelected {
                self.actionBtn.setTitle(localized(key: "全选") + " " + "\u{e6f3}", for: .normal)
                self.actionBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
            } else {
                self.actionBtn.setTitle(localized(key: "全选") + " " + "\u{e6fb}", for: .normal)
                self.actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLB)
        self.titleLB.pin.left(10).right(80).top().bottom()
        self.addSubview(self.actionBtn)
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        self.actionBtn.pin.right(10).top().bottom().width(60)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.left(10).right(80).top().bottom()
        self.actionBtn.pin.right(10).top().bottom().width(60)
    }
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.init(x: 10, y: 0, width: self.frame.size.width-90, height: self.frame.size.height))
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.textAlignment = .left
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
        return _titleLB
    }()
    
    lazy public var actionBtn : UIButton = {
        let _actionBtn = UIButton.init(type: .custom)
        _actionBtn.backgroundColor = UIColor.clear
        _actionBtn.frame = CGRect.init(x: 0, y: 0, width: 60, height: self.frame.size.height)
        _actionBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H5)
        _actionBtn.titleLabel?.textAlignment = .right
        _actionBtn.setTitle(localized(key: "全选") + " " + "\u{e6fb}", for: .normal)
        _actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        return _actionBtn
    }()
    
    @objc func didAction() {
        self.didActionCallback?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
