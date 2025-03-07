
import Foundation
import UIKit

class MXSceneConditionSliderSettingView: UIView {
    
    public typealias PropertyValueChangeCallback = (_ value: Float, _ compare: String) -> ()
    public var valueCallback : PropertyValueChangeCallback?
    var stepValue: Float = 1
    var delBtn : UIButton!
    var addBtn : UIButton!
    
    var unit:String = "" {
        didSet {
            self.minValueLB.text = String(format: "%.\(self.floatNum)f%@", self.minValue, self.unit)
            self.maxValueLB.text = String(format: "%.\(self.floatNum)f%@", self.maxValue, self.unit)
            
            let str = NSMutableAttributedString()
            let valueStr = NSAttributedString(string: String(format: "%.\(self.floatNum)f", self.currentValue), attributes: [.font: UIFont.mxBlodFont(size: 40),.foregroundColor:AppUIConfiguration.NeutralColor.title])
            str.append(valueStr)
            let unitStr = NSAttributedString(string: self.unit, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText,.baselineOffset:12])
            str.append(unitStr)
            self.valueLB.attributedText = str
        }
    }
    
    var floatNum: Int = 0 {
        didSet {
            self.minValueLB.text = String(format: "%.\(self.floatNum)f%@", self.minValue, self.unit)
            self.maxValueLB.text = String(format: "%.\(self.floatNum)f%@", self.maxValue, self.unit)
            
            let str = NSMutableAttributedString()
            let valueStr = NSAttributedString(string: String(format: "%.\(self.floatNum)f", self.currentValue), attributes: [.font: UIFont.mxBlodFont(size: 40),.foregroundColor:AppUIConfiguration.NeutralColor.title])
            str.append(valueStr)
            let unitStr = NSAttributedString(string: self.unit, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText,.baselineOffset:12])
            str.append(unitStr)
            self.valueLB.attributedText = str
        }
    }
    var compare: String = "==" {
        didSet {
            if self.compare == "<" {
                self.compareSegment.selectedSegmentIndex = 0
            } else if self.compare == "==" {
                self.compareSegment.selectedSegmentIndex = 1
            } else if self.compare == ">" {
                self.compareSegment.selectedSegmentIndex = 2
            }
        }
    }
    public var minValue: Float = 0 {
        didSet {
            self.slider.minimumValue = self.minValue
            self.minValueLB.text = String(format: "%.\(self.floatNum)f%@", self.minValue, self.unit)
        }
    }
    public var maxValue: Float = 100 {
        didSet {
            self.slider.maximumValue = self.maxValue
            self.maxValueLB.text = String(format: "%.\(self.floatNum)f%@", self.maxValue, self.unit)
        }
    }
    public var currentValue: Float = 0 {
        didSet {
            let str = NSMutableAttributedString()
            let valueStr = NSAttributedString(string: String(format: "%.\(self.floatNum)f", self.currentValue), attributes: [.font: UIFont.mxBlodFont(size: 40),.foregroundColor:AppUIConfiguration.NeutralColor.title])
            str.append(valueStr)
            let unitStr = NSAttributedString(string: self.unit, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText,.baselineOffset:12])
            str.append(unitStr)
            self.valueLB.attributedText = str
            self.slider.value = currentValue
            self.layoutSubviews()
        }
    }
    
    var compareSegment = UISegmentedControl(items: [localized(key: "小于"),localized(key: "等于"),localized(key: "大于")])
    var slider = UISlider(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        self.compareSegment.addTarget(self, action: #selector(compareChange(sender:)), for: .valueChanged)
        self.compareSegment.selectedSegmentIndex = 1
        self.addSubview(self.compareSegment)
        self.compareSegment.pin.left(20).right(20).top(20).height(44)
        
        self.addSubview(self.valueLB)
        self.valueLB.pin.below(of: self.compareSegment).marginTop(40).left(60).right(60).height(40)
        
        self.delBtn = UIButton(type: .custom)
        self.delBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H0)
        self.delBtn.setTitle("-", for: .normal)
        self.delBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        self.delBtn.addTarget(self, action: #selector(delBtnAction), for: .touchUpInside)
        self.addSubview(self.delBtn)
        self.delBtn.pin.left(of: self.valueLB, aligned: .center).marginRight(0).width(40).height(40)
        
        self.addBtn = UIButton(type: .custom)
        self.addBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H0)
        self.addBtn.setTitle("+", for: .normal)
        self.addBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        self.addBtn.addTarget(self, action: #selector(addBtnAction), for: .touchUpInside)
        self.addSubview(self.addBtn)
        self.addBtn.pin.right(of: self.valueLB, aligned: .center).marginLeft(0).width(40).height(40)
        
        self.slider.minimumValue = self.minValue
        self.slider.maximumValue = self.maxValue
        self.slider.value = self.currentValue
        self.slider.tintColor = AppUIConfiguration.MXAssistColor.main
        self.slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.addSubview(self.slider)
        self.slider.pin.left(20).right(20).below(of: self.valueLB).marginTop(40).height(32).left(20).right(20)
        
        self.addSubview(self.minValueLB)
        self.minValueLB.pin.below(of: self.slider).marginTop(0).height(18).left(30).width(self.frame.size.width/2.0 - 40)
        self.addSubview(self.maxValueLB)
        self.maxValueLB.pin.below(of: self.slider).marginTop(0).height(18).right(30).width(self.frame.size.width/2.0 - 40)
    }
    
    @objc func delBtnAction() {
        if self.currentValue > self.minValue {
            var newValue = self.currentValue - self.stepValue
            if newValue < self.minValue {
                newValue = self.minValue
            }
            self.currentValue = newValue
            self.valueCallback?(self.currentValue, self.compare)
        }
    }
    
    @objc func addBtnAction() {
        if self.currentValue < self.maxValue {
            var newValue = self.currentValue + self.stepValue
            if newValue > self.maxValue {
                newValue = self.maxValue
            }
            self.currentValue = newValue
            self.valueCallback?(self.currentValue, self.compare)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.compareSegment.pin.left(20).right(20).top(20).height(44)
        self.valueLB.pin.below(of: self.compareSegment).marginTop(40).height(40).minWidth(100).maxWidth(200).hCenter().sizeToFit(.widthFlexible)
        self.delBtn.pin.left(of: self.valueLB, aligned: .center).marginRight(0).width(40).height(40)
        self.addBtn.pin.right(of: self.valueLB, aligned: .center).marginLeft(0).width(40).height(40)
        self.slider.pin.left(20).right(20).below(of: self.valueLB).marginTop(40).height(32).left(20).right(20)
        self.minValueLB.pin.below(of: self.slider).marginTop(0).height(18).left(30).width(self.frame.size.width/2.0 - 40)
        self.maxValueLB.pin.below(of: self.slider).marginTop(0).height(18).right(30).width(self.frame.size.width/2.0 - 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var valueLB : UILabel = {
        let _valueLB = UILabel(frame: .zero)
        _valueLB.font = UIFont.boldSystemFont(ofSize: 40)
        _valueLB.textColor = AppUIConfiguration.NeutralColor.title;
        _valueLB.textAlignment = .center
        _valueLB.text = "\(self.currentValue)"
        return _valueLB
    }()
    
    lazy var minValueLB : UILabel = {
        let _minValueLB = UILabel(frame: .zero)
        _minValueLB.font = UIFont.boldSystemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        _minValueLB.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _minValueLB.textAlignment = .left
        return _minValueLB
    }()
    
    lazy var maxValueLB : UILabel = {
        let _maxValueLB = UILabel(frame: .zero)
        _maxValueLB.font = UIFont.boldSystemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        _maxValueLB.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _maxValueLB.textAlignment = .right
        return _maxValueLB
    }()
    
    @objc func sliderValueChanged() {
        self.currentValue = Float(String(format: "%.\(self.floatNum)f", self.slider.value)) ?? self.slider.value
        self.valueCallback?(self.currentValue, self.compare)
    }
    
    @objc func compareChange(sender:UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.compare = "<"
        } else if sender.selectedSegmentIndex == 1 {
            self.compare = "=="
        } else if sender.selectedSegmentIndex == 2 {
            self.compare = ">"
        }
        self.valueCallback?(self.currentValue, self.compare)
    }
}
