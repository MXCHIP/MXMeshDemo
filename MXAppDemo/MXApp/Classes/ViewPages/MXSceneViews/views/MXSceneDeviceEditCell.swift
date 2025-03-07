
import Foundation
import UIKit

protocol MXSceneDeviceEditCellDelegate {
    
    func add(at indexPath: IndexPath) -> Void
    
    func remove(at indexPath: IndexPath) -> Void

}

class MXSceneDeviceEditCell: UITableViewCell {
    
    var ifAdded = false

    var isOffLine = false
    
    var device: MXDeviceInfo? {
        didSet {
            self.imgView.image = nil
            self.titleLabel.text = nil
            self.contentLabel.text = nil
            
            self.isOffLine = false
            
            if let newDevice = device {
                self.titleLabel.text = newDevice.showName
                if let image = newDevice.image {
                    self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
                } else if let image = newDevice.productInfo?.image {
                    self.imageView?.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
                }
                
            }
            
            guard let device = device else {
                return
            }
            
            if let addedInfo = propertyInfo(with: device) {
                self.ifAdded = true
                self.contentLabel.attributedText = addedInfo
            } else {
                self.ifAdded = false
                self.contentLabel.attributedText = nil
            }
                        
            self.deleteLabel.isHidden = !ifAdded
            
                self.titleLabel.textColor = AppUIConfiguration.NeutralColor.title
                if ifAdded {
                    self.addLabel.text = "\u{e6df}"
                    self.addLabel.textColor = AppUIConfiguration.NeutralColor.disable
                } else {
                    self.addLabel.text = "\u{e715}"
                    self.addLabel.textColor = AppUIConfiguration.MainColor.C0
                }
            
            
            self.layoutSubviews()
        }
    }
    
    
    func propertyInfo(with device: MXDeviceInfo) -> NSMutableAttributedString? {
        var valueString = NSMutableAttributedString()
        self.device?.properties?.forEach({ (item:MXPropertyInfo) in
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
        
        if valueString.string.count ==  0 {
            return nil
        } else {
            return valueString
        }
    }
    
    
    var _indexPath = IndexPath(row: 0, section: 0)
    var indexPath: IndexPath? {
        didSet {
            if let indexPath = indexPath {
                _indexPath = indexPath
            }
        }
    }
    
    var sceneType = ""
    
    @objc func addGestureAction(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.add(at: _indexPath)
    }
    
    @objc func removeGestureAction(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.remove(at: _indexPath)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(deleteLabel)
        self.contentView.addSubview(addLabel)
        
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        contentLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H6)
        contentLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        deleteLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        deleteLabel.textColor = AppUIConfiguration.MXAssistColor.red
        deleteLabel.textAlignment = .center
        addLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        addLabel.textColor = AppUIConfiguration.MainColor.C0
        addLabel.textAlignment = .center
        
        let addGesture = UITapGestureRecognizer(target: self, action: #selector(addGestureAction(sender:)))
        let removeGesture = UITapGestureRecognizer(target: self, action: #selector(removeGestureAction(sender:)))
        addLabel.isUserInteractionEnabled = true
        addLabel.addGestureRecognizer(addGesture)
        deleteLabel.isUserInteractionEnabled = true
        deleteLabel.addGestureRecognizer(removeGesture)
        
        deleteLabel.text = "\u{e714}"
        addLabel.text = "\u{e715}"
        
        self.round(with: .both, rect: CGRect(x: 0, y: 10, width: screenWidth - 10*2, height: 80), radius: 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
            if self.ifAdded {
                self.deleteLabel.pin.left(16).width(40).height(40).vCenter(5)
                imgView.pin.right(of: deleteLabel, aligned: .center).marginLeft(10).width(40).height(40)
                titleLabel.pin.right(of: imgView, aligned: .top).marginLeft(16).right(60).height(20)
                contentLabel.pin.below(of: titleLabel, aligned: .left).marginTop(4).right(60).height(16)
            } else {
                self.addLabel.pin.right(16).width(40).height(40).vCenter(5)
                imgView.pin.left(26).width(40).height(40).vCenter(5)
                titleLabel.pin.right(of: imgView, aligned: .center).marginLeft(16).right(60).height(20)
            }
        
    }
    
    let imgView = UIImageView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let contentLabel = UILabel(frame: .zero)
    let deleteLabel = UILabel(frame: .zero)
    let addLabel = UILabel(frame: .zero)

    var delegate: MXSceneDeviceEditCellDelegate?
    
}
