
import Foundation
import FlexColorPicker
import MeshSDK
import UIKit


class MXHSVColorView: UIView {
    
    public typealias ValueChangeCallback = (_ hue: Int, _ saturation: Int, _ brightness: Int) -> ()
    public var valueCallback : ValueChangeCallback?
    
    public var hue : Int = 0 {
        didSet {
            self.pickerController.selectedColor = UIColor(hue: CGFloat(self.hue)/360, saturation: CGFloat(self.saturation)/100, brightness: CGFloat(self.brightness)/100, alpha: 1.0)
            self.preview.backgroundColor = self.pickerController.selectedColor
            self.saturationProgress.gradientLayer.colors = [UIColor(hue: CGFloat(self.hue)/360, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor, UIColor(hue: CGFloat(self.hue)/360, saturation: 1.0, brightness: 1.0, alpha: 0.45).cgColor]
            self.selectView.reloadData()
        }
    }
    public var saturation : Int = 100 {
        didSet {
            self.pickerController.selectedColor = UIColor(hue: CGFloat(self.hue)/360, saturation: CGFloat(self.saturation)/100, brightness: CGFloat(self.brightness)/100, alpha: 1.0)
            self.preview.backgroundColor = self.pickerController.selectedColor
            self.saturationProgress.percentage = CGFloat(self.saturation)
        }
    }
    public var brightness : Int = 100 {
        didSet {
            self.pickerController.selectedColor = UIColor(hue: CGFloat(self.hue)/360, saturation: CGFloat(self.saturation)/100, brightness: CGFloat(self.brightness)/100, alpha: 1.0)
            self.preview.backgroundColor = self.pickerController.selectedColor
        }
    }
    
    let pickerController = ColorPickerController()
    let colorControl = RadialPaletteControl()
    let preview = UIView()
    
    let saturationProgress : MXProgressView = MXProgressView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pickerController.selectedColor = UIColor(hue: 0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        self.colorControl.paletteDelegate = RadialHueColorPaletteDelegate()
        self.colorControl.thumbView.autoDarken = false
        self.addSubview(self.colorControl)
        self.colorControl.pin.left(18).top().right(18).height(self.frame.size.width - 36)
        self.pickerController.radialHsbPalette = self.colorControl
        
        self.pickerController.delegate = self
        
        self.addSubview(self.preview)
        self.preview.pin.width(self.colorControl.frame.size.width * 0.25).height(self.colorControl.frame.size.height * 0.25).top(self.colorControl.center.y - self.colorControl.frame.size.height * 0.125).hCenter()
        self.preview.layer.cornerRadius = self.colorControl.frame.size.height * 0.125
        self.preview.layer.masksToBounds = true
        
        var selectW: CGFloat = 3*32 + 2*24
        var selectX: CGFloat = (self.frame.size.width - selectW)/2.0
        if selectX < 0 {
            selectX = 0
            selectW = self.frame.size.width
        }
        self.addSubview(self.selectView)
        self.selectView.pin.below(of: self.colorControl).marginTop(20).left(selectX).width(selectW).height(32)
        
        self.saturationProgress.nameLab.text = localized(key: "饱和度")
        self.saturationProgress.percentage = CGFloat(self.saturation)
        self.saturationProgress.nameLab.isHidden = false
        self.saturationProgress.valueLab.isHidden = false
        self.saturationProgress.valueCallback = { (value: Double) in
            self.saturation = Int(value)
            self.valueCallback?(self.hue, self.saturation, self.brightness)
        }
        self.addSubview(self.saturationProgress)
        self.saturationProgress.pin.below(of: self.selectView).marginTop(20).left().right().height(44)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleClick))
        doubleTap.numberOfTapsRequired = 2
        self.preview.addGestureRecognizer(doubleTap)
    }
    
    @objc func doubleClick() {
        let alert = MXAlertView(title: "", placeholder: localized(key: "请输入颜色RGB值"), text: self.pickerController.selectedColor.toHexString, leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) { textField in
            
        } rightButtonCallBack: { textField in
            if let colorHex = textField.text {
                self.hue = Int(UIColor(hex: colorHex).hsbColor.hue * 360)
                self.saturation = Int(UIColor(hex: colorHex).hsbColor.saturation * 100)
                self.valueCallback?(self.hue, self.saturation, self.brightness)
            }
        }
        alert.show()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorControl.pin.left(18).top().right(18).height(self.frame.size.width - 36)
        self.preview.pin.width(self.colorControl.frame.size.width * 0.25).height(self.colorControl.frame.size.height * 0.25).top(self.colorControl.center.y - self.colorControl.frame.size.height * 0.125).hCenter()
        self.preview.layer.cornerRadius = self.colorControl.frame.size.height * 0.125
        var selectW: CGFloat = 3*32 + 2*24
        var selectX: CGFloat = (self.frame.size.width - selectW)/2.0
        if selectX < 0 {
            selectX = 0
            selectW = self.frame.size.width
        }
        self.selectView.pin.below(of: self.colorControl).marginTop(20).left(selectX).width(selectW).height(32)
        self.saturationProgress.pin.below(of: self.selectView).marginTop(20).left().right().height(44)
    }
    
    lazy var selectView: MXCollectionView = {
        let _layout = MXHeadersFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        _layout.minimumInteritemSpacing = 24.0
        _layout.minimumLineSpacing = 24.0
        _layout.itemSize = CGSize(width: 32, height: 32)
        _layout.scrollDirection = .horizontal
        
        let _collectionview = MXCollectionView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 32), collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXSceneSelectIconCell.self, forCellWithReuseIdentifier: String (describing: MXSceneSelectIconCell.self))
        _collectionview.backgroundColor  = .clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = false
        _collectionview.alwaysBounceHorizontal = false
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            _collectionview.contentInsetAdjustmentBehavior = .never
        }
        return _collectionview
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MXHSVColorView:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXSceneSelectIconCell.self), for: indexPath) as! MXSceneSelectIconCell
        cell.backgroundColor = UIColor.clear
        cell.iconView.image = nil
        cell.iconView.backgroundColor = .clear
        cell.bgView.layer.cornerRadius = 16.0
        cell.bgView.layer.borderWidth = 2
        cell.bgView.layer.borderColor = UIColor.clear.cgColor
        cell.iconView.pin.width(24).height(24).center()
        cell.iconView.layer.cornerRadius = 12
        if indexPath.row == 0 {
            cell.bgView.layer.borderColor = UIColor(hex: "FF0000").cgColor
            cell.iconView.backgroundColor = UIColor(hex: "FF0000")
            cell.bgView.backgroundColor = (self.hue == 0 ? .clear : UIColor(hex: "FF0000"))
        } else if indexPath.row == 1 {
            cell.bgView.layer.borderColor = UIColor(hex: "00FF00").cgColor
            cell.iconView.backgroundColor = UIColor(hex: "00FF00")
            cell.bgView.backgroundColor = (self.hue == 120 ? .clear : UIColor(hex: "00FF00"))
        } else if indexPath.row == 2 {
            cell.bgView.layer.borderColor = UIColor(hex: "0000FF").cgColor
            cell.iconView.backgroundColor = UIColor(hex: "0000FF")
            cell.bgView.backgroundColor = (self.hue == 240 ? .clear : UIColor(hex: "0000FF"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if self.hue != 0 {
                self.hue = 0
            }
        } else if indexPath.row == 1 {
            if self.hue != 120 {
                self.hue = 120
            }
        } else if indexPath.row == 2 {
            if self.hue != 240 {
                self.hue = 240
            }
        }
        self.valueCallback?(self.hue, self.saturation, self.brightness)
    }
}

extension MXHSVColorView:ColorPickerDelegate {
    
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        let newHue = Int(selectedColor.hsbColor.hue * 360)
        print("颜色转动：\(newHue)")
        if self.hue != newHue {
            self.hue = newHue
            self.valueCallback?(self.hue, self.saturation, self.brightness)
        }
    }
}
