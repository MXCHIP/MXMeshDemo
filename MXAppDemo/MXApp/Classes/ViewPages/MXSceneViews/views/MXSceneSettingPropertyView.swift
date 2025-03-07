
import Foundation

class MXSceneSettingPropertyView: UIView {
    
    public typealias SureActionCallback = (_ properties: [MXPropertyInfo]) -> ()
    public var sureActionCallback : SureActionCallback?
    var contentView: UIView!
    public var selectList = [MXPropertyInfo]()
    public var dataList = [MXPropertyInfo]() {
        didSet {
            self.layoutSubviews()
            self.mxCollectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH : CGFloat = 250
        self.contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - viewH - 10, width: self.frame.size.width, height: viewH))
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.addSubview(self.contentView)
        self.contentView.pin.left().right().bottom().height(viewH)
        
        self.contentView.addSubview(self.titleView)
        self.titleView.pin.left().top().right().height(50)
        
        self.contentView.addSubview(self.mxCollectionView)
        self.mxCollectionView.pin.below(of: self.titleView).marginTop(0).left().right().bottom()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var contentH: CGFloat = 50
        if self.dataList.first(where: {$0.identifier == "ColorTemperature" || $0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) != nil {
            if let temperatureProperty = self.dataList.first(where: {$0.identifier == "ColorTemperature"}),
                temperatureProperty.value != nil {
                contentH += 180 + 134 + self.frame.size.width - 96 + 92
            } else if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}),
                        hsvProperty.value != nil {
                contentH += 180 + 134 + self.frame.size.width - 96 + 176
            } else {
                contentH += 180 + 20
            }
        } else {
            self.dataList.forEach { (item:MXPropertyInfo) in
                if item.dataType?.type == "bool" {
                    contentH += 90
                } else if item.dataType?.type == "enum", let spec = item.dataType?.specs as? [String: String] {
                    contentH += CGFloat(spec.count * 90)
                } else {
                    contentH += 134
                }
            }
            contentH += CGFloat(self.dataList.count * 50) + 20
        }
        contentH += self.pin.safeArea.bottom
        let maxH:CGFloat = screenHeight - (AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH)
        let minH:CGFloat = 250
        if contentH > maxH  {
            contentH = maxH
        } else if contentH < minH {
            contentH = minH
        }
        self.contentView.pin.left().right().bottom().height(contentH)
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.titleView.pin.left().top().right().height(50)
        self.titleLB.pin.left(80).right(80).height(20).vCenter()
        self.leftBtn.pin.left(16).top().width(48).bottom()
        self.rightBtn.pin.right(16).top().width(48).bottom()
        self.lineView.pin.left().right().bottom().height(1)
        self.mxCollectionView.pin.below(of: self.titleView).marginTop(0).left().right().bottom()
        self.mxCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.title;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key: "请选择执行动作")
        return _titleLB
    }()
    
    lazy var titleView : UIView = {
        let _titleView = UIView(frame: CGRect(x: 0, y: 0, width:0, height: 50))
        _titleView.backgroundColor = .clear
        
        _titleView.addSubview(self.titleLB)
        self.titleLB.pin.left(80).right(80).height(20).vCenter()
        
        _titleView.addSubview(self.leftBtn)
        self.leftBtn.pin.left(16).top().width(48).bottom()
        
        _titleView.addSubview(self.rightBtn)
        self.rightBtn.pin.right(16).top().width(48).bottom()
        
        _titleView.addSubview(self.lineView)
        self.lineView.pin.left().right().bottom().height(1)
        
        return _titleView
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
        _rightBtn.setTitle(localized(key:"完成"), for: .normal)
        _rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        _rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _rightBtn.backgroundColor = .clear
        _rightBtn.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        return _rightBtn
    }()
    
    lazy var lineView : UIView = {
        let _lineView = UILabel(frame: .zero)
        _lineView.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        return _lineView
    }()
    
    lazy var mxCollectionView: MXCollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 12.0, left: 10.0, bottom: 0.0, right: 10.0)
        _layout.minimumInteritemSpacing = 10.0
        _layout.minimumLineSpacing = 10.0
        _layout.itemSize = CGSize(width: (screenWidth - 30)/2.0, height: 80)
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 254), collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXScenePropertyEnumCell.self, forCellWithReuseIdentifier: String (describing: MXScenePropertyEnumCell.self))
        _collectionview.register(MXScenePropertyIntCell.self, forCellWithReuseIdentifier: String (describing: MXScenePropertyIntCell.self))
        _collectionview.register(MXScenePropertyBrightnessCell.self, forCellWithReuseIdentifier: String (describing: MXScenePropertyBrightnessCell.self))
        _collectionview.register(MXScenePropertyTemperatureCell.self, forCellWithReuseIdentifier: String (describing: MXScenePropertyTemperatureCell.self))
        _collectionview.register(MXScenePropertyHSVCell.self, forCellWithReuseIdentifier: String (describing: MXScenePropertyHSVCell.self))
        
        _collectionview.register(MXCollectionHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: MXCollectionHeaderView.self))
        _collectionview.backgroundColor  = UIColor.clear
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
    
    @objc func leftBtnAction() {
        self.dismiss()
    }
    
    @objc func rightBtnAction() {
        var currentProperties = [MXPropertyInfo]()
        self.dataList.forEach { (item:MXPropertyInfo) in
            if item.value != nil {
                currentProperties.append(item)
            }
        }
        if currentProperties.count > 0 {
            self.sureActionCallback?(currentProperties)
            self.dismiss()
        } else {
            MXToastHUD.showError(status: localized(key: "动作不能为空"))
        }
    }
    
    
    func show() -> Void {
        if self.superview != nil {
            return
        }
        self.syncPropertys()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
        self.pin.left().right().top().bottom()
    }
    
    
    func dismiss() -> Void {
        self.removeFromSuperview()
    }
    
    func syncPropertys() {
        self.dataList.forEach { (item:MXPropertyInfo) in
            if let selectedItem = self.selectList.first(where: {$0.identifier == item.identifier}) {
                item.value = selectedItem.value
            }
        }
        
        if let temperature = self.dataList.first(where: {$0.identifier == "ColorTemperature"}), temperature.value != nil {
            if let switchProperty = self.dataList.first(where: {$0.identifier == "LightSwitch"}) {
                switchProperty.value = 1 as AnyObject
            }
        } else if let hsv = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}), hsv.value != nil {
            if let switchProperty = self.dataList.first(where: {$0.identifier == "LightSwitch"}) {
                switchProperty.value = 1 as AnyObject
            }
        } else if let hsv = self.dataList.first(where: {$0.identifier == "Brightness"}), hsv.value != nil {
            if let switchProperty = self.dataList.first(where: {$0.identifier == "LightSwitch"}) {
                switchProperty.value = 1 as AnyObject
            }
        }
    }
}

extension MXSceneSettingPropertyView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let switchProperty = self.dataList.first(where: {$0.identifier == "LightSwitch"}) {
            if let value = switchProperty.value as? Int, value == 1 {
                if let temperatureProperty = self.dataList.first(where: {$0.identifier == "ColorTemperature"}),
                    temperatureProperty.value != nil {
                    return 4
                } else if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}),
                            hsvProperty.value != nil {
                    return 4
                }
                return 2
            } else {
                return 1
            }
        }
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.dataList.first(where: {$0.identifier == "LightSwitch"}) != nil {
            if section == 0 {
                return 2
            } else if section == 1 {
                if self.dataList.first(where: {$0.identifier == "ColorTemperature"}) != nil && self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) != nil {
                    return 2
                } else {
                    return 1
                }
            }
            return 1
        } else {
            if self.dataList.count > 0 {
                let property = self.dataList[section]
                if let dataType = property.dataType, let type = dataType.type, let specs = dataType.specs as? [String: String] {
                    if type == "bool" {
                        return 2
                    } else if type == "enum" {
                        return specs.count
                    } else {
                        return 1
                    }
                }
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.dataList.first(where: {$0.identifier == "LightSwitch"}) != nil {
            
            if indexPath.section == 0 {
                return CGSize(width: (screenWidth - 30)/2.0, height: 80)
            } else if indexPath.section == 1 {
                if self.dataList.first(where: {$0.identifier == "ColorTemperature"}) != nil && self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) != nil {  
                    return CGSize(width: (screenWidth - 30)/2.0, height: 80)
                } else if self.dataList.first(where: {$0.identifier == "ColorTemperature" || $0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) != nil { 
                    return CGSize(width: screenWidth - 20, height: 80)
                } else if let property = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                    if property.value != nil {
                        return CGSize(width: screenWidth - 20, height: 184)
                    }
                    return CGSize(width: screenWidth - 20, height: 80)
                }
                return CGSize(width: screenWidth - 20, height: 80)
            } else if indexPath.section == 2 {
                return CGSize(width: screenWidth - 20, height: 124)
            } else if indexPath.section == 3 {
                if let temperatureProperty = self.dataList.first(where: {$0.identifier == "ColorTemperature"}), temperatureProperty.value != nil {
                    return CGSize(width: screenWidth - 20, height: screenWidth - 96 + 92)
                } else {
                    return CGSize(width: screenWidth - 20, height: screenWidth - 96 + 176)
                }
            }
        } else {
            if self.dataList.count > 0 {
                let property = self.dataList[indexPath.section]
                if let dataType = property.dataType, let type = dataType.type {
                    if type == "bool" {
                        return CGSize(width: (screenWidth - 30)/2.0, height: 80)
                    } else if type == "enum" {
                        return CGSize(width: screenWidth - 20, height: 80)
                    } else {
                        if property.value != nil {
                            return CGSize(width: screenWidth - 20, height: 184)
                        }
                        return CGSize(width: screenWidth - 20, height: 80)
                    }
                }
            }
        }
        return CGSize(width: (screenWidth - 30)/2.0, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.dataList.first(where: {$0.identifier == "LightSwitch"}) != nil {
            if indexPath.section == 0 {  
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyEnumCell.self), for: indexPath) as! MXScenePropertyEnumCell
                if let property = self.dataList.first(where: {$0.identifier == "LightSwitch"}), let dataType = property.dataType, let specs = dataType.specs as? [String: String] {
                    let keys =  specs.keys.sorted()
                    let list = Array(keys)
                    if list.count > indexPath.row {
                        let keyStr = list[indexPath.row]
                        cell.nameLab.text = specs[keyStr]
                        cell.canSelected = true
                        cell.isMXSelected = false
                        if let value = property.value as? Int {
                            cell.isMXSelected = (value == Int(keyStr))
                        }
                    }
                }
                return cell
            } else if indexPath.section == 1 {
                if self.dataList.first(where: {$0.identifier == "ColorTemperature" || $0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) != nil {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyEnumCell.self), for: indexPath) as! MXScenePropertyEnumCell
                    if let property = self.dataList.first(where: {$0.identifier == "LightSwitch"}) {
                        if let p_value = property.value as? Int, p_value == 1 {
                            cell.canSelected = true
                        } else {
                            cell.canSelected = false
                        }
                        cell.isMXSelected = false
                        if indexPath.row == 0 {
                            if let temperatureProperty = self.dataList.first(where: {$0.identifier == "ColorTemperature"}) {
                                cell.nameLab.text = localized(key: "色温")
                                cell.isMXSelected = (temperatureProperty.value != nil)
                            } else if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                                cell.nameLab.text = localized(key: "颜色")
                                cell.isMXSelected = (hsvProperty.value != nil)
                            }
                        } else if indexPath.row == 1 {
                            cell.nameLab.text = localized(key: "颜色")
                            if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                                cell.isMXSelected = (hsvProperty.value != nil)
                            }
                        }
                    }
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyIntCell.self), for: indexPath) as! MXScenePropertyIntCell
                    if let property = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                        cell.propertyInfo = property
                        cell.sureActionCallback = { [weak self] (value: Bool) in
                            DispatchQueue.main.async {
                                self?.mxCollectionView.reloadData()
                            }
                        }
                    }
                    return cell
                }
            } else if indexPath.section == 2 {  
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyBrightnessCell.self), for: indexPath) as! MXScenePropertyBrightnessCell
                if let temperatureProperty = self.dataList.first(where: {$0.identifier == "ColorTemperature"}), temperatureProperty.value != nil, let property = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                    cell.propertyInfo = property
                    cell.name = localized(key: "亮度")
                    cell.valueCallback = nil
                } else if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex"}), let value = hsvProperty.value as? Int32 {
                    let hsvParams = MXHSVColorHandle.getHSVFromColorHex(value: value)
                    if let brightness = hsvParams["Value"] {
                        cell.propertyInfo = nil
                        cell.name = localized(key: "亮度")
                        cell.minValue = 1
                        cell.maxValue = 100
                        cell.unit = "%"
                        cell.currentValue = Double(brightness)
                        cell.valueCallback = { (brightness_value: Double) in
                            print("颜色的亮度:\(brightness_value)")
                            if let colorCell = self.mxCollectionView.cellForItem(at: IndexPath(row: 0, section: 3)) as? MXScenePropertyHSVCell {
                                colorCell.colorView.brightness = Int(brightness_value)
                            }
                            
                            if let newProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex"}), var newValue = newProperty.value as? Int32 {
                                let newParams = MXHSVColorHandle.getHSVFromColorHex(value: newValue)
                                let hue = newParams["Hue"] ?? 0
                                let saturation = newParams["Saturation"] ?? 0
                                let valueHex = String(format: "%04X", hue).littleEndian + String(format: "%02X", saturation) + String(format: "%02X", Int(brightness_value))
                                var hsvValue: UInt32 = UInt32(valueHex, radix: 16) ?? 0
                                newProperty.value = Int32(bitPattern: hsvValue) as AnyObject
                            }
                        }
                    }
                } else if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColor"}), let value = hsvProperty.value as? [String: Int] {
                    if let brightness = value["Value"] {
                        cell.propertyInfo = nil
                        cell.name = localized(key: "亮度")
                        cell.minValue = 1
                        cell.maxValue = 100
                        cell.unit = "%"
                        cell.currentValue = Double(brightness)
                        cell.valueCallback = { (brightness_value: Double) in
                            print("颜色的亮度:\(brightness_value)")
                            if let colorCell = self.mxCollectionView.cellForItem(at: IndexPath(row: 0, section: 3)) as? MXScenePropertyHSVCell {
                                colorCell.colorView.brightness = Int(brightness_value)
                            }
                            
                            if let newProperty = self.dataList.first(where: {$0.identifier == "HSVColor"}), var newValue = newProperty.value as? [String: Int] {
                                newValue["Value"] = Int(brightness_value)
                                newProperty.value = newValue as AnyObject
                            }
                        }
                    }
                }
                return cell
            } else {  
                if let temperatureProperty = self.dataList.first(where: {$0.identifier == "ColorTemperature"}), temperatureProperty.value != nil {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyTemperatureCell.self), for: indexPath) as! MXScenePropertyTemperatureCell
                    cell.propertyInfo = temperatureProperty
                    cell.temperatureView.valueCallback = { (value: Double) in
                        temperatureProperty.value = value as AnyObject
                    }
                    return cell
                } else if let hsvProperty = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}), hsvProperty.value != nil {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyHSVCell.self), for: indexPath) as! MXScenePropertyHSVCell
                    cell.propertyInfo = hsvProperty
                    return cell
                }
            }
        } else {
            if self.dataList.count > 0 {
                let property = self.dataList[indexPath.section]
                if let dataType = property.dataType, let type = dataType.type, let specs = dataType.specs as? [String: String] {
                    if type == "bool" || type == "enum" {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyEnumCell.self), for: indexPath) as! MXScenePropertyEnumCell
                        let keys =  specs.keys.sorted()
                        let list = Array(keys)
                        if list.count > indexPath.row {
                            let keyStr = list[indexPath.row]
                            cell.nameLab.text = specs[keyStr]
                            cell.canSelected = true
                            cell.isMXSelected = false
                            if let value = property.value as? Int {
                                cell.isMXSelected = (value == Int(keyStr))
                            }
                        }
                        return cell
                    } else {
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyIntCell.self), for: indexPath) as! MXScenePropertyIntCell
                        cell.propertyInfo = property
                        cell.sureActionCallback = { [weak self] (value: Bool) in
                            DispatchQueue.main.async {
                                self?.mxCollectionView.reloadData()
                            }
                        }
                        return cell
                    }
                }
            }
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyEnumCell.self), for: indexPath) as! MXScenePropertyEnumCell
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataList.first(where: {$0.identifier == "LightSwitch"}) != nil {
            
            if indexPath.section == 0 {
                if let property = self.dataList.first(where: {$0.identifier == "LightSwitch"}) {
                    if indexPath.row == 0 {
                        if let value = property.value as? Int, value == 0 {
                            property.value = nil
                        } else {
                            property.value = 0 as AnyObject
                            if let temperature = self.dataList.first(where: {$0.identifier == "ColorTemperature"}) {
                                temperature.value = nil
                            }
                            if let hsvColor = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                                hsvColor.value = nil
                            }
                            if let Brightness = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                                Brightness.value = nil
                            }
                            self.layoutSubviews()
                        }
                    } else {
                        if let value = property.value as? Int, value == 1 {
                            property.value = nil
                            if let temperature = self.dataList.first(where: {$0.identifier == "ColorTemperature"}) {
                                temperature.value = nil
                            }
                            if let hsvColor = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                                hsvColor.value = nil
                            }
                            if let Brightness = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                                Brightness.value = nil
                            }
                            self.layoutSubviews()
                        } else {
                            property.value = 1 as AnyObject
                        }
                    }
                }
                self.mxCollectionView.reloadData()
            } else if indexPath.section == 1 {
                if self.dataList.first(where: {$0.identifier == "ColorTemperature" || $0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) != nil {
                    if let switchProperty = self.dataList.first(where: {$0.identifier == "LightSwitch"})  {
                        if let p_value = switchProperty.value as? Int, p_value != 1 {
                            return
                        } else if switchProperty.value == nil {
                            return
                        }
                    }
                    if indexPath.row == 0 {
                        if let temperature = self.dataList.first(where: {$0.identifier == "ColorTemperature"}) {
                            if temperature.value != nil {
                                temperature.value = nil
                                if let Brightness = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                                    Brightness.value = nil
                                }
                            } else {
                                temperature.value = 0 as AnyObject
                                if let hsvColor = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                                    hsvColor.value = nil
                                }
                                if let Brightness = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                                    Brightness.value = 100 as AnyObject
                                }
                            }
                        } else if let hsvColor = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                            if hsvColor.value !=  nil {
                                hsvColor.value = nil
                            } else {
                                if hsvColor.identifier == "HSVColorHex" {
                                    hsvColor.value = 0x00006464 as AnyObject
                                } else {
                                    hsvColor.value = ["Hue":0, "Saturation":100, "Value":100] as AnyObject
                                }
                                if let temperature = self.dataList.first(where: {$0.identifier == "ColorTemperature"}) {
                                    temperature.value = nil
                                }
                                if let Brightness = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                                    Brightness.value = nil
                                }
                            }
                        }
                    } else {
                        if let hsvColor = self.dataList.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}) {
                            if hsvColor.value !=  nil {
                                hsvColor.value = nil
                            } else {
                                if hsvColor.identifier == "HSVColorHex" {
                                    hsvColor.value = 0x00006464 as AnyObject
                                } else {
                                    hsvColor.value = ["Hue":0, "Saturation":100, "Value":100] as AnyObject
                                }
                                if let temperature = self.dataList.first(where: {$0.identifier == "ColorTemperature"}) {
                                    temperature.value = nil
                                }
                                if let Brightness = self.dataList.first(where: {$0.identifier == "Brightness"}) {
                                    Brightness.value = nil
                                }
                            }
                        }
                    }
                    self.layoutSubviews()
                    self.mxCollectionView.reloadData()
                }
            }
        } else {
            if self.dataList.count > indexPath.section {
                let property = self.dataList[indexPath.section]
                if let dataType = property.dataType, let type = dataType.type, let specs = dataType.specs as? [String:String] {
                    if type == "bool" || type == "enum" {
                        let keys =  specs.keys.sorted()
                        let list = Array(keys)
                        if list.count > indexPath.row {
                            let keyStr = list[indexPath.row]
                            if let pValue = property.value as? Int, pValue == Int(keyStr) {
                                property.value = nil
                            } else {
                                property.value = Int(keyStr) as AnyObject
                            }
                        }
                    }
                }
                self.mxCollectionView.reloadData()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if self.dataList.first(where: {$0.identifier == "LightSwitch"}) == nil {
            return CGSize(width: self.frame.size.width, height: 50)
        }
        return CGSize.zero
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXCollectionHeaderView.self), for: indexPath as IndexPath) as! MXCollectionHeaderView
            reusableview.backgroundColor = UIColor.clear
            if self.dataList.count > indexPath.section {
                let property = self.dataList[indexPath.section]
                reusableview.titleLB.text = property.name
            }
            reusableview.moreBtn.isHidden = true
            return reusableview
        }
        return UICollectionReusableView()
    }
}

extension MXSceneSettingPropertyView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let view = touch.view else {
            return
        }
        if view.isKind(of: MXRadialCircleView.self) {
            self.mxCollectionView.isScrollEnabled = false
        } else {
            self.mxCollectionView.isScrollEnabled = true
        }
    }
}
