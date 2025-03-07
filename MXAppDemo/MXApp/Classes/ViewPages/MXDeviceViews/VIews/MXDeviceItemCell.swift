
import Foundation
import UIKit
import SDWebImage
import MeshSDK
import PinLayout

class MXDeviceItemCell: UICollectionViewCell {
    
    public typealias MoreDeviceActionCallback = (_ item: MXDeviceInfo, _ testUrl: String? ) -> ()
    public var moreActionCallback : MoreDeviceActionCallback?
    var deviceInfo : MXDeviceInfo!
    
    var inAnimating = false
    var isOpen : Bool = false
    
    public var isEdit = false {
        didSet {
            
            self.moreBtn.isHidden = self.isEdit
            self.selectBtn.isHidden = !self.isEdit
        }
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
    
    func showSelectedAnimation() -> Void {
        inAnimating = true
        
        UIView.animate(withDuration: 0.2) {
            self.deviceNameLab.textColor = AppUIConfiguration.MXColor.white
            self.roomNamelabel.textColor = AppUIConfiguration.MXColor.white
            self.moreBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
            self.bgView.backgroundColor = AppUIConfiguration.MXAssistColor.green
            self.bgView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { status in
            if !self.inAnimating {
                return
            }
            UIView.animate(withDuration: 0.1) {
                self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
            } completion: { status in
                if !self.inAnimating {
                    return
                }
                UIView.animate(withDuration: 0.2) {
                    self.deviceNameLab.textColor = AppUIConfiguration.NeutralColor.title
                    self.roomNamelabel.attributedText = self.createStatusShowString()
                    self.moreBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
                    self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
                }
            }
        }
        
    }
    
    func removeAllAnimation() -> Void {
        inAnimating = false
        self.bgView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.deviceNameLab.textColor = AppUIConfiguration.NeutralColor.title
        self.moreBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        allSubViews(view: self)
    }
    
    func allSubViews(view: UIView) -> Void {
        view.layer.removeAllAnimations()
        
        view.subviews.forEach { (sv: UIView) in
            allSubViews(view: sv)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPressGes.minimumPressDuration = 5
        longPressGes.numberOfTouchesRequired = 1
        longPressGes.allowableMovement = 15
        self.addGestureRecognizer(longPressGes)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let alert = MXAlertView(title: "", placeholder: "请输入测试地址", text: nil, leftButtonTitle: localized(key: "Room_取消"), rightButtonTitle: localized(key: "Room_确定")) { textField in
                self.moreActionCallback?(self.deviceInfo, nil)
            } rightButtonCallBack: { textField in
                self.moreActionCallback?(self.deviceInfo, textField.text)
            }
            alert.show()
            return
        }
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.layer.cornerRadius = 20
        self.bgView.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        self.bgView.layer.shadowOffset = CGSize.zero
        self.bgView.layer.shadowOpacity = 1;
        self.bgView.layer.shadowRadius = 8.0;
        
        self.bgView.addSubview(self.deviceImageView)
        self.deviceImageView.pin.left(15).top(10).width(48).height(48)
        
        self.bgView.addSubview(self.deviceNameLab)
        self.deviceNameLab.pin.below(of: self.deviceImageView, aligned: .left).marginTop(8).right(15).height(18)
        
        self.bgView.addSubview(self.roomNamelabel)
        self.roomNamelabel.pin.below(of: self.deviceNameLab, aligned: .left).marginTop(4).right(15).height(16)
        
        self.bgView.addSubview(self.moreBtn)
        self.moreBtn.pin.right(5).top(5).width(50).height(52)
        self.moreBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        
        self.bgView.addSubview(self.bleStatusLabel)
        self.bleStatusLabel.pin.width(24).height(24).right().bottom()
        self.bleStatusLabel.isHidden = true
        
        self.bgView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(20).top(20).width(24).height(24)
        self.selectBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        
        if self.mxSelected {
            self.selectBtn.setTitle("\u{e6f3}", for: .normal)
            self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        } else {
            self.selectBtn.setTitle("\u{e6fb}", for: .normal)
            self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        }
        
        self.moreBtn.isHidden = self.isEdit
        self.selectBtn.isHidden = !self.isEdit
        
        self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moreAction() {
        if self.mxSelected {
            self.mxSelected = false
        } else {
            self.mxSelected = true
        }
        self.moreActionCallback?(self.deviceInfo, nil)
    }
    
    public func refreshView(info: MXDeviceInfo) {
        self.deviceImageView.image = nil
        self.deviceNameLab.text = nil
        self.roomNamelabel.text = nil
        
        self.deviceInfo = info
        self.deviceNameLab.text = info.showName
        
        self.roomNamelabel.attributedText = self.createStatusShowString()
        self.roomNamelabel.lineBreakMode = .byTruncatingMiddle
        
        if let productImage = info.image {
            self.deviceImageView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage))
        } else if let productImage = info.productInfo?.image {
            self.deviceImageView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage))
        }
        
        self.bleStatusLabel.isHidden = true
    }
    
    func createStatusShowString() -> NSAttributedString {
        if self.isEdit {
            let str = NSMutableAttributedString()
            if let roomName = self.deviceInfo.roomName, roomName.count > 0 {
                let nameStr = NSAttributedString(string: roomName, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                str.append(nameStr)
            }
            return str
        } else {
            let str = NSMutableAttributedString()
            if let roomName = self.deviceInfo.roomName, roomName.count > 0 {
                let nameStr = NSAttributedString(string: roomName, attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                str.append(nameStr)
            }
            if MeshSDK.sharedInstance.isConnected() { 
                if let uuidStr = self.deviceInfo.meshInfo?.uuid, uuidStr.count > 0,
                   let resultParams = MeshSDK.sharedInstance.getDeviceCacheProperties(uuid: uuidStr) {  
                    
                    if let params = self.deviceInfo.properties,
                       let pInfo = params.first(where: {($0.identifier ?? "").contains("Switch")}),
                       let pName = pInfo.identifier,
                       let value = resultParams[pName] as? Int  {
                        
                        var statusStr = NSAttributedString()
                        if value == 1 {
                            statusStr = NSAttributedString(string: localized(key: "已开启"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.MXAssistColor.green])
                        } else {
                            statusStr = NSAttributedString(string: localized(key: "已关闭"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        }
                        
                        if let roomName = self.deviceInfo.roomName, roomName.count > 0 {
                            let separatorStr = NSAttributedString(string: " | ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                            str.append(separatorStr)
                        }
                        
                        str.append(statusStr)
                    }
                }
            }
            return str
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.deviceImageView.pin.left(15).top(10).width(48).height(48)
        self.deviceNameLab.pin.below(of: self.deviceImageView, aligned: .left).marginTop(8).right(15).height(18)
        self.roomNamelabel.pin.below(of: self.deviceNameLab, aligned: .left).marginTop(4).right(15).height(16)
        self.bleStatusLabel.pin.width(24).height(24).right().bottom()
        self.moreBtn.pin.right(5).top(5).width(50).height(52)
        self.selectBtn.pin.right(20).top(20).width(24).height(24)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var deviceImageView : UIImageView = {
        let _deviceImageView = UIImageView()
        _deviceImageView.backgroundColor = UIColor.clear
        return _deviceImageView
    }()
    
    lazy var deviceNameLab : UILabel = {
        let _deviceNameLab = UILabel(frame: .zero)
        _deviceNameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H5);
        _deviceNameLab.textColor = AppUIConfiguration.NeutralColor.title;
        return _deviceNameLab
    }()
    
    lazy var roomNamelabel : UILabel = {
        let _roomNamelabel = UILabel(frame: .zero)
        _roomNamelabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6);
        _roomNamelabel.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        return _roomNamelabel
    }()
    
    lazy var moreBtn : UIButton = {
        let _moreBtn = UIButton(type: .custom)
        _moreBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        _moreBtn.setTitle("\u{e6e0}", for: .normal)
        _moreBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        return _moreBtn
    }()
    
    lazy var bleStatusLabel : UILabel = {
        let _bleStatusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        _bleStatusLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H7);
        _bleStatusLabel.textColor = AppUIConfiguration.MXAssistColor.green
        _bleStatusLabel.textAlignment = .center
        _bleStatusLabel.backgroundColor = UIColor(hex: AppUIConfiguration.MXAssistColor.green.toHexString, alpha: 0.25);
        _bleStatusLabel.text = "\u{e76a}"
        _bleStatusLabel.corner(byRoundingCorners: [.topLeft], radii: 8.0)
        return _bleStatusLabel
    }()
    
    lazy public var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        return _selectBtn
    }()
}
