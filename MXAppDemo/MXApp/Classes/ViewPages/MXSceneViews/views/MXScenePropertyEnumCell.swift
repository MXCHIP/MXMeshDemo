
import Foundation

class MXScenePropertyEnumCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public var canSelected:Bool = true {
        didSet {
            if self.canSelected {
                self.nameLab.alpha = 1.0
            } else {
                self.nameLab.alpha = 0.5
            }
        }
    }
    
    public var isMXSelected:Bool = false {
        didSet {
            if self.isMXSelected {
                self.selectBtn.setTitle("\u{e79c}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
                self.nameLab.textColor = AppUIConfiguration.MainColor.C0
            } else {
                self.selectBtn.setTitle("\u{e79b}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.dividers, for: .normal)
                self.nameLab.textColor = AppUIConfiguration.NeutralColor.title;
            }
        }
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        
        self.bgView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(20).top(30).width(20).height(20)
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.left(of: self.selectBtn).marginRight(10).left(20).top(30).height(20)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        self.selectBtn.pin.right(20).top(30).width(20).height(20)
        self.nameLab.pin.left(of: self.selectBtn).marginRight(10).left(20).top(30).height(20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var bgView : UIView = {
        let _bgView = UIView(frame: .zero)
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        _bgView.layer.masksToBounds = true
        _bgView.clipsToBounds = true
        _bgView.layer.cornerRadius = 16
        return _bgView
    }()
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        return _nameLab
    }()
    
    lazy public var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        _selectBtn.setTitle("\u{e79b}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.dividers, for: .normal)
        _selectBtn.isEnabled = false
        return _selectBtn
    }()
}
