
import Foundation
import SDWebImage
import UIKit

class MXSceneActionCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        
        self.contentView.addSubview(self.iconLB)
        self.iconLB.pin.left(16).width(40).height(40).vCenter()
        
        self.contentView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconLB).marginLeft(16).right(16).height(20).top(19)
        
        self.contentView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(16).height(18)
        
        self.contentView.addSubview(self.tagLab)
        self.tagLab.pin.right(of: self.valueLab, aligned: .center).marginLeft(8).width(70).height(18)
        self.tagLab.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.iconView.frame.size.width == 32 {
            self.iconView.pin.left(20).width(32).height(32).vCenter()
        } else {
            self.iconView.pin.left(16).width(40).height(40).vCenter()
        }
        self.iconLB.pin.left(16).width(40).height(40).vCenter()
        self.nameLab.pin.right(of: self.iconLB).marginLeft(16).right(16).height(20).top(19)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(16).height(18)
        
        if !self.tagLab.isHidden {
            self.valueLab.sizeToFit()
            if self.valueLab.frame.size.width > self.contentView.frame.size.width - 156 {
                self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(84).height(18)
            } else {
                self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).width(0).height(18)
            }
            self.tagLab.pin.right(of: self.valueLab, aligned: .center).marginLeft(8).width(60).height(18)
        }
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    public func refreshView(info: MXDeviceInfo, isTrigger:Bool = false) {
        self.iconLB.text = nil
        self.nameLab.text = nil
        self.valueLab.text = nil
        self.tagLab.isHidden = true
        self.iconView.image = nil
        self.tagLab.isHidden = true
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        
        if let nickName = info.name, nickName.count > 0 {
            self.nameLab.text = nickName
        }
        
        if let property_list =  info.properties {
            let valueString = NSMutableAttributedString()
            property_list.forEach { (item:MXPropertyInfo) in
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
            }
            self.valueLab.attributedText = valueString
        }
        
        if !info.isValid {
            self.tagLab.isHidden = false
            self.valueLab.sizeToFit()
            if self.valueLab.frame.size.width > self.contentView.frame.size.width - 156 {
                self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(84).height(18)
            } else {
                self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).width(0).height(18)
            }
            self.tagLab.pin.right(of: self.valueLab, aligned: .center).marginLeft(8).width(60).height(18)
        }
        
        if let productImage = info.image, productImage.count > 0 {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        } 
    }
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconView.backgroundColor = UIColor.clear
        _iconView.clipsToBounds = true
        return _iconView
    }()
    
    lazy var iconLB : UILabel = {
        let _iconLB = UILabel(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconLB.backgroundColor = UIColor.clear
        _iconLB.textAlignment = .center
        _iconLB.font = UIFont.iconFont(size: 32)
        return _iconLB
    }()
    
    public lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H3);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        return _nameLab
    }()
    
    public lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _valueLab.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _valueLab.textAlignment = .left
        return _valueLab
    }()
    
    lazy var tagLab : UILabel = {
        let _tagLab = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 18))
        _tagLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        _tagLab.backgroundColor = UIColor(hex: "FAAD14")
        _tagLab.textColor = .white
        _tagLab.textAlignment = .center
        _tagLab.layer.masksToBounds = true
        _tagLab.layer.cornerRadius = 4.0
        _tagLab.text = localized(key:"已失效")
        return _tagLab
    }()
}
