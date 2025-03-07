
import Foundation

class MXSceneListHearderView: UIView {
    
    public typealias DidActionCallback = () -> ()
    public var didActionCallback : DidActionCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(self.bgView)
        self.bgView.pin.left(10).right(10).top(16).height(40)
        
        self.bgView.addSubview(self.iconLB)
        self.iconLB.pin.left(8).width(20).height(20).vCenter()
        
        self.bgView.addSubview(self.arrowLB)
        self.arrowLB.pin.right(10).width(20).height(20).vCenter()
        
        self.bgView.addSubview(self.contentLB)
        self.contentLB.pin.right(of: self.iconLB).marginLeft(6).top().bottom().left(of: self.arrowLB).marginRight(10)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didAction))
        self.bgView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top(16).height(40)
        self.iconLB.pin.left(8).width(20).height(20).vCenter()
        self.arrowLB.pin.right(10).width(20).height(20).vCenter()
        self.contentLB.pin.right(of: self.iconLB).marginLeft(6).top().bottom().left(of: self.arrowLB).marginRight(10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didAction() {
        self.didActionCallback?()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF;
        _bgView.layer.cornerRadius = 20.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconLB : UILabel = {
        let _iconLB = UILabel(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        _iconLB.backgroundColor = UIColor.clear
        _iconLB.textAlignment = .center
        _iconLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        _iconLB.textColor = AppUIConfiguration.MXAssistColor.gold
        _iconLB.text = "\u{e73a}"
        return _iconLB
    }()
    
    public lazy var contentLB : UILabel = {
        let _contentLB = UILabel(frame: .zero)
        _contentLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _contentLB.textColor = AppUIConfiguration.MXAssistColor.gold;
        _contentLB.textAlignment = .left
        return _contentLB
    }()
    
    lazy var arrowLB : UILabel = {
        let _arrowLB = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        _arrowLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H5);
        _arrowLB.textColor = AppUIConfiguration.NeutralColor.disable
        _arrowLB.textAlignment = .center
        _arrowLB.text = "\u{e6df}"
        return _arrowLB
    }()
}
