
import Foundation
import SDWebImage

class MXSceneDeviceCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    var info : MXDeviceInfo? {
        didSet {
            self.refreshView()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.floatViewColor.level2.FFFFFF
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter()
        self.contentView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLB, aligned: .left).marginTop(4).right(16).height(18)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshView() {
        self.nameLB.text = nil
        self.iconView.image = nil
        if let newInfo = self.info {
            self.nameLB.text = newInfo.showName
            if let imageStr = newInfo.image {
                self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
            } else if let imageStr = newInfo.productInfo?.image {
                self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
            }
        }
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    func refreshPropertyInfo(device:MXDeviceInfo) {
        var valueString = NSMutableAttributedString()
        device.properties?.forEach({ (item:MXPropertyInfo) in
            if let type = item.dataType?.type {
                if (type == "bool" || type == "enum") {
                    if let dataValue = item.value as? Int, let specsParams = item.dataType?.specs as? [String: String] {
                        let valueStr = NSAttributedString(string: ((item.name ?? "") + "-" + (specsParams[String(dataValue)] ?? "") + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        valueString.append(valueStr)
                    }
                } else if type == "struct" {
                    if let dataValue = item.value as? [String: Int] {
                        if let p_identifier = item.identifier, p_identifier == "HSVColor",let hValue = dataValue["Hue"], let sValue = dataValue["Saturation"], let vValue = dataValue["Value"] {
                            let str = NSMutableAttributedString()
                            let nameStr = NSAttributedString(string: (item.name ?? "") + " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                            str.append(nameStr)
                            let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0),.baselineOffset:-4])
                            str.append(valueStr)
                            valueString.append(str)
                        }
                    }
                } else {
                    if let p_identifier = item.identifier, p_identifier == "HSVColorHex", let dataValue = item.value as? Int32 {
                        let str = NSMutableAttributedString()
                        let nameStr = NSAttributedString(string: (item.name ?? "") + " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        str.append(nameStr)
                        let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:MXHSVColorHandle.colorFromHSVColor(value: dataValue),.baselineOffset:-4])
                        str.append(valueStr)
                        valueString.append(str)
                    } else if let dataValue = item.value as? Int {
                        var compareType = item.compare_type
                        if compareType == "==" {
                            compareType = "-"
                        }
                        let valueStr = NSAttributedString(string: ((item.name ?? "") + compareType + String(dataValue) + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        valueString.append(valueStr)
                    } else if let dataValue = item.value as? Double {
                        var compareType = item.compare_type
                        if compareType == "==" {
                            compareType = "-"
                        }
                        var floatNum = 0
                        if let stepStr = item.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                            if step < 0.1 {
                                floatNum = 2
                            } else if step < 1 {
                                floatNum = 1
                            }
                        }
                        let valueStr = NSAttributedString(string: ((item.name ?? "") + compareType + String(format: "%.\(floatNum)f", dataValue) + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        valueString.append(valueStr)
                    }
                }
            }
        })
        self.valueLab.attributedText = valueString
        if (self.valueLab.attributedText?.length ?? 0) > 0 {
            self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter(-11)
        } else {
            self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter()
        }
        self.valueLab.pin.below(of: self.nameLB, aligned: .left).marginTop(4).marginLeft(4).right(16).height(18)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        if (self.valueLab.attributedText?.length ?? 0) > 0 {
            self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter(-11)
        } else {
            self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter()
        }
        self.valueLab.pin.below(of: self.nameLB, aligned: .left).marginTop(4).marginLeft(4).right(16).height(18)
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    public lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _valueLab.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _valueLab.textAlignment = .left
        return _valueLab
    }()
}
