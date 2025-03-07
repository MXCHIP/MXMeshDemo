
import Foundation
import UIKit
class MXScenePropertyTemperatureCell: UICollectionViewCell {
    
    public var temperatureView :MXColorTemperatureView =  MXColorTemperatureView(frame: CGRect(x: 38, y: 20, width: screenWidth - 96, height: screenWidth - 96 + 72))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public var propertyInfo:MXPropertyInfo? {
        didSet {
            if let value = self.propertyInfo?.value as? Double {
                self.temperatureView.currentPercent = value
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
        
        self.temperatureView.valueCallback = { (value:Double) in
            self.propertyInfo?.value = value as AnyObject
        }
        
        self.bgView.addSubview(self.temperatureView)
        self.temperatureView.pin.left(38).right(38).top(20).bottom(20)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.bgView.layer.masksToBounds = true
        self.bgView.clipsToBounds = true
        self.bgView.layer.cornerRadius = 16
        self.temperatureView.pin.left(38).right(38).top(20).bottom(20)
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
