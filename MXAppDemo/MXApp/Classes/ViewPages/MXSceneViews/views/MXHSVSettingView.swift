
import Foundation
import FlexColorPicker
import UIKit
import Network
import MeshSDK

class MXHSVSettingView: UIView {
    
    public typealias SureActionCallback = (_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat) -> ()
    public var sureActionCallback : SureActionCallback?
    
    public var hsvColorValue : Int = 0 {
        didSet {
            if let color = MXHSVColorHandle.colorFromHSVColor(value: Int32(self.hsvColorValue)) {
                self.pickerController.selectedColor = color
            }
        }
    }
    
    public var hsvValue : [String:Int]? {
        didSet {
            if let params = self.hsvValue, let hValue = params["Hue"], let sValue = params["Saturation"], let vValue = params["Value"] {
                self.pickerController.selectedColor = UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0)
            }
        }
    }
    
    var contentView: UIView!
    
    let pickerController = ColorPickerController()
    let colorControl = RadialPaletteControl()
    let preview = ColorPreviewWithHex()
    
    var saturationTitleLB : UILabel!
    var saturationSliderControl: SaturationSliderControl!
    var brightnessTitleLB : UILabel!
    var brightnessSliderControl: BrightnessSliderControl!
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        self.pickerController.selectedColor = UIColor(hue: 0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        let viewH = 155 + UIScreen.main.bounds.width - 116 + 150
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
        
        self.colorControl.paletteDelegate = RadialHueColorPaletteDelegate()
        self.colorControl.thumbView.autoDarken = false
        self.contentView.addSubview(self.colorControl)
        self.colorControl.pin.below(of: self.titleLB).marginTop(30).left(48).right(48).height(self.contentView.frame.size.width - 96)
        
        self.pickerController.radialHsbPalette = self.colorControl
        
        self.contentView.addSubview(self.preview)
        self.preview.pin.width(self.colorControl.frame.size.width * 0.25).height(self.colorControl.frame.size.height * 0.25).top(self.colorControl.center.y - self.colorControl.frame.size.height * 0.125).hCenter()
        self.preview.layer.cornerRadius = self.colorControl.frame.size.height * 0.125
        self.preview.layer.masksToBounds = true
        self.preview.displayHex = false
        self.pickerController.colorPreview = self.preview
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(60)
        
        self.saturationTitleLB = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.size.width - 40, height: 20))
        self.saturationTitleLB.backgroundColor = .clear
        self.saturationTitleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        self.saturationTitleLB.textColor = AppUIConfiguration.NeutralColor.primaryText
        self.saturationTitleLB.textAlignment = .center
        self.saturationTitleLB.text = localized(key:"饱和度")
        self.contentView.addSubview(self.saturationTitleLB)
        self.saturationTitleLB.pin.below(of: self.colorControl).marginTop(8).left(20).right(20).height(20)
        
        self.saturationSliderControl = SaturationSliderControl(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.size.width - 60, height: 40))
        self.saturationSliderControl.showPercentage = false
        self.contentView.addSubview(self.saturationSliderControl)
        self.saturationSliderControl.pin.below(of: self.saturationTitleLB).marginTop(3).left(30).right(30).height(40)
        
        self.pickerController.saturationSlider = self.saturationSliderControl
        
        self.brightnessTitleLB = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.size.width - 40, height: 20))
        self.brightnessTitleLB.backgroundColor = .clear
        self.brightnessTitleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        self.brightnessTitleLB.textColor = AppUIConfiguration.NeutralColor.primaryText
        self.brightnessTitleLB.textAlignment = .center
        self.brightnessTitleLB.text = localized(key:"亮度")
        self.contentView.addSubview(self.brightnessTitleLB)
        self.brightnessTitleLB.pin.below(of: self.saturationSliderControl).marginTop(8).left(20).right(20).height(20)
        
        self.brightnessSliderControl = BrightnessSliderControl(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.size.width - 60, height: 40))
        self.brightnessSliderControl.showPercentage = false
        self.brightnessSliderControl.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        self.contentView.addSubview(self.brightnessSliderControl)
        self.brightnessSliderControl.pin.below(of: self.brightnessTitleLB).marginTop(3).left(30).right(30).height(40)
        
        self.pickerController.brightnessSlider = self.brightnessSliderControl
        
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewH = 155 + UIScreen.main.bounds.width - 116 + 150
        var bottomH: CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            bottomH = self.pin.safeArea.bottom
        }
        self.contentView.pin.left(10).right(10).bottom(bottomH).height(viewH)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.primaryText
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"颜色调节")
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
        let color_hsb = self.pickerController.selectedColor.hsbColor
        self.sureActionCallback?(color_hsb.hue, color_hsb.saturation, color_hsb.brightness)
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
