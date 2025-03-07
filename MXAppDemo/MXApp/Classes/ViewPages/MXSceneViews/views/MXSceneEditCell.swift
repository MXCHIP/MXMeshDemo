
import Foundation
import SDWebImage

class MXSceneEditCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ item: MXSceneInfo) -> ()
    public var didActionCallback : DidActionCallback!
    
    var itemInfo : MXSceneInfo!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.left(10).right(10).top().bottom(12)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(70).height(21).top(29)
        
        self.bgView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(70).height(18)
        
        self.bgView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(12).width(40).height(40).vCenter()
    }
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.selectBtn.setTitle("\u{e6f3}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
            } else {
                self.selectBtn.setTitle("\u{e6fb}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
            }
        }
    }
    
    public func refreshView(info: MXSceneInfo) {
        self.iconView.image = nil
        self.nameLab.text = nil
        self.valueLab.text = nil
        
        self.itemInfo = info
        
        if let name = info.name {
            self.nameLab.text = name
        }
        let desStr = NSMutableAttributedString()
        if let value = info.des, value.count > 0 {
            let des_str = NSAttributedString(string: value, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
            desStr.append(des_str)
        } else {
            info.actions.forEach({ (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo, let objName = obj.name, let property_list = obj.properties, property_list.count > 0, obj.status != 3 {
                    property_list.forEach { (property:MXPropertyInfo) in
                        guard let type = property.dataType?.type, let pName = property.name else {
                            return
                        }
                        if type == "bool" || type == "enum" {
                            if let dataValue = property.value as? Int, let specsParams = property.dataType?.specs as? [String: String] {
                                let acitonStr = objName + "-" + pName + "-" + (specsParams[String(dataValue)] ?? "")
                                let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                                desStr.append(des_str)
                            }
                        } else if type == "struct" {
                            guard let dataValue = property.value as? [String:Int] else {
                                return
                            }
                            if let p_identifier = property.identifier, p_identifier == "HSVColor", let hValue = dataValue["Hue"], let sValue = dataValue["Saturation"], let vValue = dataValue["Value"] {
                                let nameStr = NSAttributedString(string: objName + "-" + pName, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                                desStr.append(nameStr)
                                let valueStr = NSAttributedString(string: "\u{e72e}", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0),.baselineOffset:-4])
                                desStr.append(valueStr)
                            }
                        } else {
                            if let p_identifier = property.identifier, p_identifier == "HSVColorHex", let dataValue = property.value as? Int32 {
                                let nameStr = NSAttributedString(string: objName + "-" + pName, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                                desStr.append(nameStr)
                                let valueStr = NSAttributedString(string: "\u{e72e}", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:MXHSVColorHandle.colorFromHSVColor(value: dataValue),.baselineOffset:-4])
                                desStr.append(valueStr)
                            } else if let dataValue = property.value as? Int {
                                var compareType = property.compare_type
                                if compareType == "==" {
                                    compareType = "-"
                                }
                                let acitonStr = objName + "-" + pName + compareType + String(dataValue)
                                let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                                desStr.append(des_str)
                            } else if let dataValue = property.value as? Double {
                                var compareType = property.compare_type
                                if compareType == "==" {
                                    compareType = "-"
                                }
                                var floatNum = 0
                                if let stepStr = property.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                                    if step < 0.1 {
                                        floatNum = 2
                                    } else if step < 1 {
                                        floatNum = 1
                                    }
                                }
                                let acitonStr = objName + "-" + pName + compareType + String(format: "%.\(floatNum)f", dataValue) + " "
                                let des_str = NSAttributedString(string: acitonStr, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                                desStr.append(des_str)
                            }
                        }
                        let spaceStr = NSAttributedString(string: " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        desStr.append(spaceStr)
                    }
                }
            })
        }
        self.valueLab.attributedText = desStr
        
        if let imageUrl = info.iconImage {
            self.iconView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: imageUrl)?.mx_imageByTintColor(color: UIColor(hex: self.itemInfo.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))) { [weak self] (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                if let img = image {
                    self?.iconView.image = img.mx_imageByTintColor(color: UIColor(hex: self?.itemInfo.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top().bottom(12)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(70).height(21).top(29)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(70).height(18)
        self.selectBtn.pin.right(12).width(40).height(40).vCenter()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF;
        _bgView.layer.cornerRadius = 16.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        _iconView.backgroundColor = UIColor.clear
        _iconView.clipsToBounds = true
        return _iconView
    }()
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H3);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        return _nameLab
    }()
    
    lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _valueLab.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _valueLab.textAlignment = .left
        return _valueLab
    }()
    
    lazy var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        _selectBtn.isUserInteractionEnabled = false
        return _selectBtn
    }()
}
