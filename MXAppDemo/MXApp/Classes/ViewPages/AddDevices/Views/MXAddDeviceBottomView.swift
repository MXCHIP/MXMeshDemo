
import Foundation


class MXAddDeviceBottomView: UIView {
    
    public typealias DidActionCallback = (_ index: Int) -> ()
    public var didActionCallback : DidActionCallback!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(self.leftBtn)
        self.leftBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        self.addSubview(self.rightBtn)
        self.rightBtn.pin.width(136).height(44).bottom(24).hCenter(74)
        
        self.leftBtn.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        self.rightBtn.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
    }
    
    @objc func leftAction() {
        self.didActionCallback?(0)
    }
    
    @objc func rightAction() {
        self.didActionCallback?(1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.leftBtn.pin.width(136).height(44).bottom(24).hCenter(-74)
        self.rightBtn.pin.width(136).height(44).bottom(24).hCenter(74)
    }
    
    lazy var leftBtn : UIButton = {
        let _leftBtn = UIButton(type: .custom)
        _leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _leftBtn.setTitle(localized(key:"继续添加"), for: .normal)
        _leftBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        _leftBtn.backgroundColor = AppUIConfiguration.MXColor.white
        _leftBtn.layer.borderWidth = 1
        _leftBtn.layer.borderColor = AppUIConfiguration.MainColor.C0.cgColor
        _leftBtn.layer.cornerRadius = 22
        return _leftBtn
    }()
    
    lazy var rightBtn : UIButton = {
        let _rightBtn = UIButton(type: .custom)
        _rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _rightBtn.setTitle(localized(key:"下一步"), for: .normal)
        _rightBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        _rightBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        _rightBtn.layer.cornerRadius = 22
        return _rightBtn
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
