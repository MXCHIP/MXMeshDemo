
import Foundation

class MXSceneTemperatureView: UIView {
    
    var sliderView = MXSceneConditionSliderSettingView(frame: .zero)

    public var compare: String = "==" {
        didSet {
            self.sliderView.compare = self.compare
        }
    }
    
    public var percent: Float = 80 {
        didSet {
            self.sliderView.currentValue = self.percent
        }
    }
    
    
    public var minValue: Float = 0 {
        didSet {
            self.sliderView.minValue = self.minValue
        }
    }
    
    public var maxValue: Float = 80 {
        didSet {
            self.sliderView.maxValue = self.maxValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.addSubview(self.sliderView)
        self.minValue = -40
        self.maxValue = 40
        self.percent = 40
        self.sliderView.stepValue = 0.1
        self.sliderView.unit = "°C"
        self.sliderView.valueCallback = { (value: Float, compare: String) in
            self.compare = compare
            self.percent = value
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.sliderView.pin.all()
    }
    
}
