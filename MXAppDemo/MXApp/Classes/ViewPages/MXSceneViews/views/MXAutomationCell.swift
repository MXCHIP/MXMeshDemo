
import Foundation
import SDWebImage

class MXAutomationCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ item: MXSceneInfo, _ isOn:Bool) -> ()
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
        self.bgView.pin.left(10).right(10).top().bottom(10)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(70).height(21).top(29)
        
        self.bgView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(70).height(18)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(20).width(44).height(26).vCenter()
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .valueChanged)
    }
    
    @objc func didAction() {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            self.actionBtn.isOn = self.itemInfo.enable
            return
        }
        self.didActionCallback?(self.itemInfo, self.actionBtn.isOn)
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
                if let itemDesc = MXSceneManager.createSceneActionDesc(item: item) {
                    desStr.append(itemDesc)
                }
            })
        }
        self.valueLab.attributedText = desStr
        
        self.actionBtn.isOn = info.enable
        if let imageUrl = info.iconImage {
            var holderImg = UIImage(named: imageUrl)
            if let icon_color = self.itemInfo.iconColor, icon_color.count > 0 {
                holderImg = holderImg?.mx_imageByTintColor(color: UIColor(hex: icon_color))
            }
            self.iconView.sd_setImage(with: URL(string: imageUrl), placeholderImage: holderImg) { [weak self] (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                if let img = image {
                    if let icon_color = self?.itemInfo.iconColor, icon_color.count > 0 {
                        self?.iconView.image = img.mx_imageByTintColor(color: UIColor(hex: icon_color))
                    } else {
                        self?.iconView.image = img
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top().bottom(10)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(70).height(21).top(29)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(70).height(18)
        self.actionBtn.pin.right(20).width(44).height(26).vCenter()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height))
        _bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
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
    
    lazy var actionBtn : UISwitch = {
        let _actionBtn = UISwitch(frame: CGRect(x: 0, y: 0, width: 44, height: 26))
        _actionBtn.onTintColor = AppUIConfiguration.MainColor.C0
        _actionBtn.tintColor = AppUIConfiguration.NeutralColor.disable
        return _actionBtn
    }()
}
