
import Foundation
import SDWebImage
import UIKit

class MXHomeSceneCell: UICollectionViewCell {
    
    var sceneInfo : MXSceneInfo!
    
    public var isEdit = false {
        didSet {
            self.selectBtn.isHidden = !self.isEdit

            if self.isEdit {
                self.statusView.isHidden = true
            } else {
                if let sceneInfo = sceneInfo,
                   sceneInfo.isInvalid {
                    self.statusView.isHidden = false
                } else {
                    self.statusView.isHidden = true
                }
            }
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
    
    public typealias MoreDeviceActionCallback = (_ item: MXSceneInfo) -> ()
    public var moreActionCallback : MoreDeviceActionCallback!
    @objc func moreAction() {
        if self.mxSelected {
            self.mxSelected = false
        } else {
            self.mxSelected = true
        }
        self.moreActionCallback?(self.sceneInfo)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.setupViews()
    }
    
    public func setupViews() {
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.layer.cornerRadius = 16
        
        self.animationView.isHidden = true
        self.bgView.addSubview(self.animationView)
        self.animationView.pin.all()
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.width(20).height(20).left(16).vCenter()
        
        self.bgView.addSubview(self.selectBtn)
        self.selectBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
        
        self.selectBtn.isHidden = !self.isEdit
        
        self.contentView.addSubview(self.sceneNameLab)
        self.sceneNameLab.pin.right(of: self.iconView).marginLeft(12).height(20).right(16).vCenter()
        
        self.contentView.addSubview(self.statusView)
        self.statusView.layer.cornerRadius = 8
        self.statusView.layer.masksToBounds = true
        self.statusView.image = UIImage(named: "mx_scene_invalid")
        self.statusView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshView(info: MXSceneInfo) {
        self.iconView.image = nil
        self.sceneNameLab.text = nil
        
        self.sceneInfo = info
        
        if let nickName = info.name {
            self.sceneNameLab.text = nickName
        }
        
        if let colorHex = info.iconColor {
            self.animationView.backgroundColor = UIColor(hex: colorHex, alpha:0.12)
        }
        
        if let imageUrl = info.iconImage {
            if imageUrl.hasPrefix("http") {
                self.iconView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: imageUrl)?.mx_imageByTintColor(color: UIColor(hex: self.sceneInfo.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))) { [weak self] (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                    if let img = image {
                        self?.iconView.image = img.mx_imageByTintColor(color: UIColor(hex: self?.sceneInfo.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))
                    }
                }
            } else {
                self.iconView.image = UIImage(named: imageUrl)?.mx_imageByTintColor(color: UIColor(hex: self.sceneInfo.iconColor ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))
            }
        }
        
        if info.isInvalid {
            self.statusView.isHidden = false
            self.iconView.alpha = 0.5
            self.sceneNameLab.alpha = 0.5
        } else {
            self.statusView.isHidden = true
            self.iconView.alpha = 1
            self.sceneNameLab.alpha = 1
        }
        
    }
    
    public func didActionAnimation() {
        self.animationView.isHidden = false
        self.animationView.frame = CGRect(x: 0, y: 0, width: 0, height: 60)
        UIView.animate(withDuration: 0.3) {
            self.animationView.frame = CGRect(x: 0, y: 0, width: 164, height: 60)
        } completion: { status in
            self.animationView.isHidden = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.bgView.layer.cornerRadius = 16
        self.animationView.pin.all()
        self.iconView.pin.width(20).height(20).left(16).vCenter()
        self.sceneNameLab.pin.right(of: self.iconView).marginLeft(12).height(20).right(32).vCenter()
        self.selectBtn.pin.right(20).top(20).width(24).height(24)
        self.statusView.pin.right(16).width(16).height(16).vCenter()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: 164, height: 60))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        _bgView.layer.cornerRadius = 16
        _bgView.layer.masksToBounds = true
        return _bgView
    }()
    
    lazy var animationView : UIView = {
        let _animationView = UIView(frame: CGRect.init(x: 0, y: 0, width: 164, height: 60))
        return _animationView
    }()
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        _iconView.backgroundColor = .clear
        return _iconView
    }()
    
    lazy var sceneNameLab : UILabel = {
        let _sceneNameLab = UILabel(frame: .zero)
        _sceneNameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H5);
        _sceneNameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _sceneNameLab.textAlignment = .left
        return _sceneNameLab
    }()
        
    lazy var statusView : UIImageView = {
        let _statusView = UIImageView(frame: .zero)
        return _statusView
    }()
    
    lazy public var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        return _selectBtn
    }()
    
}
