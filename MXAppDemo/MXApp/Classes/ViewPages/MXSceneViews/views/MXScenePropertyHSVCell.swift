
import Foundation
import MeshSDK

class MXScenePropertyHSVCell: UICollectionViewCell {
    
    public var colorView :MXHSVColorView =  MXHSVColorView(frame: CGRect(x: 20, y: 20, width: screenWidth - 60, height: screenWidth - 96 + 72 + 64))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public var propertyInfo:MXPropertyInfo? {
        didSet {
            if let value = self.propertyInfo?.value as? Int32 {
                let hsvParams = MXHSVColorHandle.getHSVFromColorHex(value: value)
                if let hue = hsvParams["Hue"], let saturation = hsvParams["Saturation"], let brightness = hsvParams["Value"] {
                    self.colorView.saturation = saturation
                    self.colorView.brightness = brightness
                    self.colorView.hue = hue
                }
            } else if let value = self.propertyInfo?.value as? [String: Int], let hue = value["Hue"], let saturation = value["Saturation"], let brightness = value["Value"] {
                self.colorView.saturation = saturation
                self.colorView.brightness = brightness
                self.colorView.hue = hue
            }
        }
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        
        self.colorView.valueCallback = { (hue:Int, saturation:Int, brightness:Int) in
            if let type = self.propertyInfo?.dataType?.type {
                if type == "struct" {
                    var newValue = [String:Int]()
                    newValue["Hue"] = hue
                    newValue["Saturation"] = saturation
                    newValue["Value"] = brightness
                    self.propertyInfo?.value = newValue as AnyObject
                } else {
                    let valueHex = String(format: "%04X", hue).littleEndian + String(format: "%02X", saturation) + String(format: "%02X", brightness)
                    var hsvValue: UInt32 = UInt32(valueHex, radix: 16) ?? 0
                    self.propertyInfo?.value = Int32(bitPattern: hsvValue) as AnyObject
                }
            }
        }
        
        self.bgView.addSubview(self.colorView)
        self.colorView.pin.left(20).right(20).top(20).bottom(20)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        self.colorView.pin.left(20).right(20).top(20).bottom(20)
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
}
