
import Foundation
import PinLayout
import UIKit
import Lottie

class MXScenePropertyIntCell: UICollectionViewCell {
    
    public typealias SureActionCallback = (_ isSelected: Bool) -> ()
    public var sureActionCallback : SureActionCallback?
    
    var floatNum: Int = 0
    var minValue: Double = 0
    var maxValue: Double = 100
    var unit:String = ""
    
    var currentValue: Double = 100 {
        didSet {
            let precentageValue = (self.currentValue - self.minValue)/(self.maxValue - self.minValue)*100
            self.valueLab.attributedText = NSAttributedString(string: String(format: "%.\(self.floatNum)f%@", self.currentValue,self.unit), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
            self.progressView.percentage = precentageValue
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
    
    @objc func buttonAction() {
        self.isMXSelected = !self.isMXSelected
        if self.isMXSelected {
            self.propertyInfo?.value = self.currentValue as AnyObject
        } else {
            self.propertyInfo?.value = nil
        }
        self.sureActionCallback?(self.isMXSelected)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public var propertyInfo:MXPropertyInfo? {
        didSet {
            if let specParams = self.propertyInfo?.dataType?.specs as? [String: String] {
                self.minValue = Double(specParams["min"] ?? "0") ?? 0
                self.maxValue = Double(specParams["max"] ?? "100") ?? 100
                if let unitStr = specParams["unit"] {
                    self.unit = unitStr
                }
                if let stepStr = specParams["step"], let step = Double(stepStr) {
                    if step < 0.1 {
                        self.floatNum = 2
                    } else if step < 1 {
                        self.floatNum = 1
                    }
                }
                self.progressView.floatNum = self.floatNum
            }
            self.nameLab.text = self.propertyInfo?.name ?? ""
            if let value = self.propertyInfo?.value as? Double {
                self.currentValue = value
                self.isMXSelected = true
            } else {
                self.currentValue = self.maxValue
                self.isMXSelected = false
            }
        }
    }
    
    func refreshView(name: String, value: Double) {
        let nameString = NSMutableAttributedString()
        let str1 = NSAttributedString(string: name, attributes: [.font: UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.NeutralColor.title])
        nameString.append(str1)
        let str2 = NSAttributedString(string: String(format: " | %.\(self.floatNum)f%@", value,self.unit), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
        nameString.append(str2)
        self.nameLab.attributedText = nameString
        
        let precentageValue = (value - self.minValue)/(self.maxValue - self.minValue)*100
        self.progressView.percentage = precentageValue
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.left(20).top(30).height(20).right(80)
        self.bgView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(20).top(30).width(20).height(20)
        self.bgView.addSubview(self.valueLab)
        self.valueLab.pin.left(20).right(20).top(90).height(20)
        self.progressView.valueCallback = { (value: Double) in
            let new_value = value*(self.maxValue - self.minValue)/100 + self.minValue
            self.propertyInfo?.value = new_value as AnyObject
            self.currentValue = new_value
        }
        self.progressView.nameLab.isHidden = true
        self.progressView.valueLab.isHidden = true
        self.bgView.addSubview(self.progressView)
        self.progressView.pin.left(20).right(20).height(44).top(120)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        self.nameLab.pin.left(20).top(30).height(20).right(80)
        self.selectBtn.pin.right(20).top(30).width(20).height(20)
        self.valueLab.pin.left(20).right(20).top(90).height(20)
        self.progressView.pin.left(20).right(20).height(44).top(120)
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
        
        _selectBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return _selectBtn
    }()
    
    lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _valueLab.textColor = .white
        _valueLab.textAlignment = .left
        _valueLab.backgroundColor = .clear
        return _valueLab
    }()
    
    lazy public var progressView : MXProgressView = {
        let _progressView = MXProgressView(frame: .zero)
        return _progressView
    }()
}
