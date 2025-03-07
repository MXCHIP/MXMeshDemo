
import Foundation
import SDWebImage
import UIKit
import MeshSDK

class MXAddDeviceRoomHeaderView: UICollectionReusableView {
    
    var info : MXDeviceInfo?
    var infoChangeCallback : MXDeviceInfoChangeCallback?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        
        self.addSubview(self.bgView)
        self.bgView.pin.left().right().top(10).bottom()
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(16).top(24).width(48).height(48)
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(8).right(50).height(20).top(38).sizeToFit()
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(of: self.nameLB).marginLeft(0).top(30).width(32).height(36)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
    }
    
    @objc func didAction() {
        let alertView = MXAlertView(title: localized(key:"设备名称"), placeholder: localized(key:"请输入名称"), text:self.info?.name, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textField: UITextField) in
            
        } rightButtonCallBack: { [weak self] (textField: UITextField) in
            if let name = textField.text {
                let nameStr = name.trimmingCharacters(in: .whitespaces)
                if !nameStr.isValidName() {
                    MXToastHUD.showInfo(status: localized(key:"名称长度限制"))
                    return
                }
                self?.info?.name = nameStr
                self?.nameLB.text = nameStr
                if let newInfo = self?.info {
                    self?.infoChangeCallback?(newInfo)
                }
            }
        }
        alertView.show()
    }
    
    public func refreshView(info: MXDeviceInfo) {
        self.info = info
        if let nickName = info.name, nickName.count > 0 {
            self.nameLB.text = nickName
        }
        
        self.nameLB.pin.right(of: self.iconView).marginLeft(8).right(50).height(20).top(38).sizeToFit()
        self.actionBtn.pin.right(of: self.nameLB).marginLeft(0).top(30).width(32).height(36)
        
        if let imageStr = info.image, imageStr.count > 0 {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left().right().top(10).bottom()
        self.iconView.pin.left(16).top(24).width(48).height(48)
        self.nameLB.pin.right(of: self.iconView).marginLeft(8).right(50).height(20).top(38).sizeToFit()
        self.actionBtn.pin.right(of: self.nameLB).marginLeft(0).top(30).width(32).height(36)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = .clear
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 48, height: 48))
        _iconView.backgroundColor = UIColor.clear
        _iconView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(iconTapAction))
        _iconView.addGestureRecognizer(tap)
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        _actionBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        _actionBtn.setTitle("\u{e71e}", for: .normal)
        return _actionBtn
    }()
    
    @objc func iconTapAction() {
        if let uuidStr = info?.meshInfo?.uuid, uuidStr.count > 0 {  
            MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: "000102", callback: nil)
        }
    }
}
