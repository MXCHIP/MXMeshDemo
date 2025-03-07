
import Foundation
import PinLayout
import UIKit
import Lottie

class MXScenePropertyBrightnessCell: UICollectionViewCell {
    
    public typealias PropertyValueChangeCallback = (_ value: Double) -> ()
    public var valueCallback : PropertyValueChangeCallback?
    
    var floatNum: Int = 0
    var minValue: Double = 0
    var maxValue: Double = 100
    var unit:String = ""
    
    var name: String = "" {
        didSet {
            if self.propertyInfo != nil {
                self.refreshView(name: self.name, value: self.currentValue)
            }
        }
    }
    var currentValue: Double = 100 {
        didSet {
            self.refreshView(name: self.name, value: self.currentValue)
        }
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
            self.name = self.propertyInfo?.name ?? ""
            if let value = self.propertyInfo?.value as? Double {
                self.currentValue = value
            } else {
                self.currentValue = (self.propertyInfo?.value as? Double) ?? self.maxValue
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
        self.nameLab.pin.left(20).top(20).height(20).right(20)
        self.progressView.valueCallback = { (value: Double) in
            let new_value = value*(self.maxValue - self.minValue)/100 + self.minValue
            self.propertyInfo?.value = new_value as AnyObject
            self.currentValue = new_value
            self.valueCallback?(new_value)
        }
        self.progressView.nameLab.isHidden = true
        self.progressView.valueLab.isHidden = true
        self.bgView.addSubview(self.progressView)
        self.progressView.pin.left(20).right(20).height(44).bottom(20)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        self.nameLab.pin.left(20).top(20).height(20).right(20)
        self.progressView.pin.left(20).right(20).height(44).bottom(20)
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
    
    lazy public var progressView : MXProgressView = {
        let _progressView = MXProgressView(frame: .zero)
        return _progressView
    }()
}

class MXProgressView: UIView {
    
    public typealias ValueChangeCallback = (_ value: Double) -> ()
    public var valueCallback : ValueChangeCallback?
    var floatNum: Int = 0
    public let gradientLayer = CAGradientLayer()
    public var percentage: Double = 100 {
        didSet {
            
            
            
            
            self.gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width * (self.percentage/100), height: self.frame.size.height)
            self.gradientLayer.isHidden = (self.percentage == 0)
            self.valueLab.text = String(format: "%.\(self.floatNum)f%%", self.percentage)
        }
    }
    var startX: CGFloat = 0  
    var startPercentage: CGFloat = 0  
    

    @objc func panGestureAction(sender: UIPanGestureRecognizer) -> Void {
        
        let updating = sender.translation(in: sender.view).x
        
        if sender.state == .began {
            startX = updating
            self.startPercentage = self.percentage
        } else if sender.state == .changed {
            let width: CGFloat = sender.view?.bounds.size.width ?? 0.0
            let per = (updating - startX) / width * 100.0
            var pValue: CGFloat = self.startPercentage + per
            if pValue < 0 {
                pValue = 0
            } else if pValue > 100 {
                pValue = 100
            }
            self.percentage = pValue
            self.valueCallback?(self.percentage)
        } else if sender.state == .ended {
            self.valueCallback?(self.percentage)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        self.backgroundColor = UIColor(hex: "EEEEEE", alpha: 0.45)
        
        self.gradientLayer.colors = [UIColor(hex: "3C3C3C").cgColor, UIColor(hex: "E7E7E7").cgColor]
        
        self.gradientLayer.locations = [0.0,1.0]
        
        self.gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        
        self.gradientLayer.endPoint  = CGPoint.init(x: 1.0, y: 0.0)
        
        self.gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        self.addSubview(self.nameLab)
        self.nameLab.pin.left(10).width(180).height(20).vCenter()
        self.addSubview(self.valueLab)
        self.valueLab.pin.right(10).width(100).height(20).vCenter()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(sender:)))
        self.addGestureRecognizer(pan)
    }
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4);
        _nameLab.textColor = .white
        _nameLab.textAlignment = .left
        _nameLab.backgroundColor = .clear
        return _nameLab
    }()
    
    lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _valueLab.textColor = .white
        _valueLab.textAlignment = .right
        _valueLab.backgroundColor = .clear
        return _valueLab
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLab.pin.left(10).width(180).height(20).vCenter()
        self.valueLab.pin.right(10).width(100).height(20).vCenter()
        self.gradientLayer.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width * (self.percentage/100), height: self.frame.size.height)
    }
}
