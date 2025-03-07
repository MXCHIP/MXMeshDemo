
import Foundation
import UIKit

class MXColorTemperatureSettingView: UIView {
    
    public typealias SureActionCallback = (_ percent: Double) -> ()
    public var sureActionCallback : SureActionCallback?
    
    public var percent: Double = 0 {
        didSet {
            self.colorControl.refreshPointLocation(precent: self.percent)
        }
    }
    
    var contentView: UIView!
    
    var colorControl: MXRadialCircleView!
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH = 155 + UIScreen.main.bounds.width - 116
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
        
        self.colorControl = MXRadialCircleView(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.size.width - 96, height: self.contentView.frame.size.width - 96))
        self.contentView.addSubview(self.colorControl)
        self.colorControl.pin.below(of: self.titleLB).marginTop(30).left(48).right(48).height(self.contentView.frame.size.width - 96)
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(60)
        
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewH = 155 + UIScreen.main.bounds.width - 116
        var bottomH: CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            bottomH = self.pin.safeArea.bottom
        }
        self.contentView.pin.left(10).right(10).bottom(bottomH).height(viewH)
    }
    
    lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.primaryText;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"色温调节")
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
        let newPercent = self.colorControl.currentPercent
        self.sureActionCallback?(newPercent)
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

class MXRadialCircleView: UIView {
    
    public typealias ValueChangeCallback = (_ value: Double) -> ()
    public var valueCallback : ValueChangeCallback?
    
    let temperatureStep : Double = (6500 - 2700)/100
    
    public var currentPercent: Double = 0 {
        didSet {
            
            self.colorPreview.text = String(Int(temperatureStep * self.currentPercent) + 2700)
            self.valueCallback?(self.currentPercent)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initCircle()
        
        self.addSubview(self.redDotView)
        
        self.addSubview(self.colorPreview)
        self.colorPreview.pin.width(frame.size.width/4).height(frame.size.width/4).center()
        
        self.refreshPointLocation(precent: 100)
        
        self.isExclusiveTouch = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initCircle() {
        let layerWidth : CGFloat = self.frame.width/4.0
        let layer = CAShapeLayer()
        layer.lineWidth = layerWidth
        
        layer.strokeColor = UIColor.red.cgColor
        
        layer.fillColor = UIColor.clear.cgColor
        
        layer.lineCap = .round
        
        let radius: CGFloat = self.frame.width/2.0 - layerWidth/2.0
        
        let clockWise = true
        let path = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.width/2.0), radius: radius, startAngle: -(.pi*0.5), endAngle: .pi*1.5, clockwise: clockWise)
        layer.path = path.cgPath
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor(red: 189/255.0, green: 151/255.0, blue: 89/255.0, alpha: 1.0).cgColor,UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,UIColor(red: 72/255.0, green: 144/255.0, blue: 198/255.0, alpha: 1.0).cgColor]

        gradientLayer.startPoint =  CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint =  CGPoint.init(x: 0, y: 1)
        self.layer.addSublayer(gradientLayer)
        gradientLayer.mask = layer
        
    }
    
    lazy var redDotView : UIView = {
        let viewW : CGFloat = self.frame.size.width/4.0 - 20
        let _redDotView = UIView(frame: CGRect(x: 0, y: 0, width: viewW, height: viewW))
        _redDotView.backgroundColor = .clear
        _redDotView.layer.cornerRadius = viewW/2
        _redDotView.layer.borderColor = UIColor.white.cgColor
        _redDotView.layer.borderWidth = 4.0
        _redDotView.isUserInteractionEnabled = false
        return _redDotView
    }()
    
    lazy var colorPreview : UILabel = {
        let viewW : CGFloat = self.frame.size.width/4.0
        let _colorPreview = UILabel(frame: CGRect(x: 0, y: 0, width: viewW, height: viewW))
        _colorPreview.backgroundColor = .black
        _colorPreview.layer.cornerRadius = viewW/2
        _colorPreview.layer.masksToBounds = true
        _colorPreview.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H7)
        _colorPreview.textAlignment = .center
        _colorPreview.textColor =  AppUIConfiguration.NeutralColor.primaryText
        
        _colorPreview.isUserInteractionEnabled = true
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleClick))
        doubleTap.numberOfTapsRequired = 2
        _colorPreview.addGestureRecognizer(doubleTap)
        return _colorPreview
    }()
    
    @objc func doubleClick() {
        let alert = MXAlertView(title: "", placeholder: localized(key: "请输入色温值"), text: self.colorPreview.text, leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) { textField in
            
        } rightButtonCallBack: { textField in
            if let tempValueStr = textField.text, let tempValue = Int(tempValueStr) {
                var newValue:Double = Double(tempValue - 2700)/self.temperatureStep
                if newValue < 0 {
                    newValue = 0
                } else if newValue > 100 {
                    newValue = 100
                }
                self.refreshPointLocation(precent: newValue)
                self.valueCallback?(self.currentPercent)
            }
        }
        alert.show()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let lastPoint = touch.location(in: self)
        
        
        let centerPoint = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        let deltaX:CGFloat = lastPoint.x - centerPoint.x
        let deltaY:CGFloat = lastPoint.y - centerPoint.y;
        let distanceBetweenPoints:CGFloat = sqrt(deltaX*deltaX + deltaY*deltaY);
        let circleRadius = self.bounds.size.width/2.0
        let radius = self.bounds.size.width/2.0 - self.bounds.size.width/4
        
        if (distanceBetweenPoints >= radius && distanceBetweenPoints <= circleRadius) {
            self.movehandle(point: lastPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let lastPoint = touch.location(in: self)
        
        
        let centerPoint = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        let deltaX:CGFloat = lastPoint.x - centerPoint.x
        let deltaY:CGFloat = lastPoint.y - centerPoint.y;
        let distanceBetweenPoints:CGFloat = sqrt(deltaX*deltaX + deltaY*deltaY);
        let circleRadius = self.bounds.size.width/2.0
        let radius = self.bounds.size.width/2.0 - self.bounds.size.width/4
        
        if (distanceBetweenPoints >= radius && distanceBetweenPoints <= circleRadius) {
            self.movehandle(point: lastPoint)
        }
    }
    
    func calculationAngle(point: CGPoint) -> CGFloat {
        let centerPoint = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        
        var angle_x = point.x - centerPoint.x
        var angle_y = point.y - centerPoint.y
        let vmag = sqrt(angle_x*angle_x + angle_y*angle_y)
        angle_x = angle_x/vmag
        angle_y = angle_y/vmag
        let  radians = atan2(angle_y,angle_x);
        return (radians >= 0  ? radians : radians + (.pi*2));
    }
    
    func movehandle(point: CGPoint) {
        let angle = self.calculationAngle(point: point)
        
        self.refreshEndPointFrame(angle: angle)
        
        var progress = abs((angle - (1.5 * .pi))/(.pi))
        if progress > 1 {
            progress = 2 - progress
        }
        self.currentPercent = progress * 100
    }
    
    func refreshEndPointFrame(angle: CGFloat) {
        
        let circleRadius = Float(self.bounds.size.width/2.0)
        let radius : Float = Float((self.bounds.size.width - self.bounds.size.width/4)/2)
        var index: Int = Int(angle/(.pi/2))
        index = (index + 1) % 4
        let needAngle = Float(angle) + .pi/2 - Float(index)*(.pi/2)
        var x: Float = 0
        var y: Float = 0
        switch (index) {
            case 0:
                x = circleRadius + sinf(needAngle)*radius;
                y = circleRadius - cosf(needAngle)*radius;
                break;
            case 1:
                x = circleRadius + cosf(needAngle)*radius;
                y = circleRadius + sinf(needAngle)*radius;
                break;
            case 2:
                x = circleRadius - sinf(needAngle)*radius;
                y = circleRadius + cosf(needAngle)*radius;
                break;
            case 3:
                x = circleRadius - cosf(needAngle)*radius;
                y = circleRadius - sinf(needAngle)*radius;
                break;
                
            default:
                break;
        }
        
        self.redDotView.center = CGPoint(x: CGFloat(x), y: CGFloat(y))
        
        self.colorPreview.backgroundColor = self.colorOfPoint(point: self.redDotView.center)
    }
    
    func colorOfPoint(point: CGPoint) -> UIColor {
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        context.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context)
        return UIColor(red: CGFloat(pixel [0]) / 255.0, green: CGFloat(pixel [1]) / 255.0, blue: CGFloat(pixel [2]) / 255.0 , alpha: CGFloat(pixel [3]) / 255.0)
    }
    
    func refreshPointLocation(precent: Double) {
        let angleToCal = (-precent/100 + 1.5) * .pi
        self.refreshEndPointFrame(angle: angleToCal)
        self.currentPercent = precent
    }
    
}
