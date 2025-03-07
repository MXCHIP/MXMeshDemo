
import Foundation

class MXSceneSliderSettingView: UIView {
    
    public typealias SureActionCallback = (_ percent: Float, _ compare: String) -> ()
    public var sureActionCallback : SureActionCallback?
    
    public var compare: String = "==" {
        didSet {
            self.sliderView.compare = self.compare
        }
    }
    public var percent: Float = 100 {
        didSet {
            self.sliderView.currentValue = self.percent
        }
    }
    
    var contentView: UIView!
    var sliderView: MXSceneConditionSliderSettingView!
    
    public var minValue: Float = 1 {
        didSet {
            self.sliderView.minValue = self.minValue
        }
    }
    
    public var maxValue: Float = 100 {
        didSet {
            self.sliderView.maxValue = self.maxValue
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH : CGFloat = 345
        self.contentView = UIView(frame: CGRect(x: 10, y: UIScreen.main.bounds.height - viewH - 10, width: UIScreen.main.bounds.width - 20, height: viewH))
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 16.0
        self.addSubview(self.contentView)
        var bottomH: CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            bottomH = self.pin.safeArea.bottom
        }
        self.contentView.pin.left(10).right(10).bottom(bottomH).height(viewH)
        
        self.contentView.addSubview(self.titleLB)
        self.titleLB.pin.left(15).top(15).right(15).height(20)
        
        self.sliderView = MXSceneConditionSliderSettingView(frame: .zero)
        self.sliderView.valueCallback = { (value: Float, compare: String) in
            self.compare = compare
            self.percent = value
        }
        self.contentView.addSubview(self.sliderView)
        self.sliderView.pin.below(of: self.titleLB).marginTop(0).left().right().height(250)
        
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(60)
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewH : CGFloat = 345
        var bottomH: CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            bottomH = self.pin.safeArea.bottom
        }
        self.contentView.pin.left(10).right(10).bottom(bottomH).height(viewH)
        self.titleLB.pin.left(15).top(15).right(15).height(20)
        self.sliderView.pin.below(of: self.titleLB).marginTop(0).left().right().height(250)
        self.bottomView.pin.left().right().bottom().height(60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.primaryText
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"亮度调节")
        return _titleLB
    }()
    
    lazy var bottomView : UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 60))
        _bottomView.backgroundColor = .clear
        
        let line1 = UIView(frame: .zero)
        line1.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        _bottomView.addSubview(line1)
        line1.pin.left().right().top().height(1)
        
        let line2 = UIView(frame: .zero)
        line2.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        _bottomView.addSubview(line2)
        line2.pin.below(of: line1).marginTop(0).width(1).bottom().hCenter()
        
        _bottomView.addSubview(self.leftBtn)
        self.leftBtn.pin.left().left(of: line2).marginRight(0).below(of: line1).marginTop(0).bottom()
        
        _bottomView.addSubview(self.rightBtn)
        self.rightBtn.pin.right(of: line2).marginLeft(0).right().below(of: line1).marginTop(0).bottom()
        
        return _bottomView
    }()
    
    lazy var leftBtn : UIButton = {
        let _leftBtn = UIButton(type: .custom)
        _leftBtn.setTitle(localized(key:"取消"), for: .normal)
        _leftBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        _leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _leftBtn.backgroundColor = .clear
        _leftBtn.addTarget(self, action: #selector(leftBtnAction), for: .touchUpInside)
        return _leftBtn
    }()
    lazy var rightBtn : UIButton = {
        let _rightBtn = UIButton(type: .custom)
        _rightBtn.setTitle(localized(key:"确定"), for: .normal)
        _rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        _rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _rightBtn.backgroundColor = .clear
        _rightBtn.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        return _rightBtn
    }()
    
    @objc func leftBtnAction() {
        self.dismiss()
    }
    
    @objc func rightBtnAction() {
        self.dismiss()
        self.sureActionCallback?(self.percent, self.compare)
    }
    
    
    func show() -> Void {
        if self.superview != nil {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
        self.pin.left().right().top().bottom()
    }
    
    
    func dismiss() -> Void {
        self.removeFromSuperview()
    }
}
