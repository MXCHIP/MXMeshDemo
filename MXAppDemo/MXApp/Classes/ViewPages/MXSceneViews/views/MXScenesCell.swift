
import Foundation
import SDWebImage

class MXScenesCell: UITableViewCell {
    
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
        self.bgView.pin.left(10).right(10).top().bottom(10)
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(70).height(21).top(29)
        
        self.bgView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(70).height(18)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(20).width(42).height(42).vCenter()
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        
    }
    
    @objc func didAction() {
        self.didActionCallback?(self.itemInfo)
        
    }
    
    func showAnimation() -> Void {
        if let _ = animationLayer {
            return
        }
        
        actionBtn.setImage(nil, for: .normal)
        
        animationLayer = CAShapeLayer()
        let path = UIBezierPath(arcCenter: CGPoint(x: 22, y: 22), radius: 20, startAngle: -Double.pi / 2, endAngle: Double.pi * 2 + Double.pi / 2, clockwise: true)
        animationLayer!.path = path.cgPath
        animationLayer!.strokeColor = AppUIConfiguration.MainColor.C0.cgColor
        animationLayer!.fillColor = UIColor.clear.cgColor
        animationLayer!.lineWidth = 3
        animationLayer!.lineCap = .round
        self.actionBtn.layer.addSublayer(animationLayer!)
        animationLayer!.pin.all()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.repeatCount = 1
        animation.duration = 1
        animation.delegate = self
        animationLayer!.add(animation, forKey: "strokeEnd")
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
        self.bgView.pin.left(10).right(10).top().bottom(10)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(70).height(21).top(29)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(70).height(18)
        self.actionBtn.pin.right(20).width(44).height(44).vCenter()
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
    
    lazy var actionBtn : UIButton = {
        let _actionBtn = UIButton(type: .custom)
        _actionBtn.setImage(UIImage(named: "mx_scene_action_unselected"), for: .normal)
        return _actionBtn
    }()
    
    var animationLayer: CAShapeLayer?
    var animationSucceedLayer: CALayer?
    
}

extension MXScenesCell: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if let strokeEnd = anim.value(forKey: "keyPath") as? String,
           strokeEnd == "strokeEnd" {
            finished()
        }
        
        if let position = anim.value(forKey: "keyPath") as? String,
           position == "position" {
            ended()
        }
    }
    
    func finished() -> Void {
        actionBtn.setImage(UIImage(named: "mx_scene_action_finished"), for: .normal)
        
        let width = actionBtn.bounds.size.width
        let height = actionBtn.bounds.size.height
        
        animationSucceedLayer = CALayer()
        animationSucceedLayer!.bounds = CGRect(x: 0, y: 0, width: width / 2, height: height / 2)
        if #available(iOS 13.0, *) {
            animationSucceedLayer!.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF.resolvedColor(with: self.traitCollection).cgColor
        } else {
            animationSucceedLayer!.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF.cgColor
        }
        animationSucceedLayer!.position = CGPoint(x: width, y: height / 2)
        actionBtn.layer.addSublayer(animationSucceedLayer!)
        
        let animationPosition = CABasicAnimation(keyPath: "position")
        animationPosition.fromValue = CGPoint(x: width / 2, y: height / 2)
        animationPosition.toValue = CGPoint(x: width * 3 / 4, y: height / 2)
        animationPosition.repeatCount = 1
        animationPosition.duration = 0.5
        animationPosition.delegate = self
        animationPosition.fillMode = .forwards
        animationPosition.isRemovedOnCompletion = false
        animationSucceedLayer!.add(animationPosition, forKey: "position")
        
        let animationBounds = CABasicAnimation(keyPath: "bounds")
        animationBounds.fromValue = CGRect(x: 0, y: 0, width: width / 2, height: height / 2)
        animationBounds.toValue = CGRect(x: 0, y: 0, width: 0, height: height / 2)
        animationBounds.repeatCount = 1
        animationBounds.duration = 0.5
        animationBounds.delegate = self
        animationBounds.fillMode = .forwards
        animationBounds.isRemovedOnCompletion = false
        animationSucceedLayer!.add(animationBounds, forKey: "bounds")
    }
    
    func ended() -> Void {
        
        if let animationLayer = animationLayer,
        let animationSucceedLayer = animationSucceedLayer {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
                animationLayer.removeFromSuperlayer()
                animationSucceedLayer.removeFromSuperlayer()
                self.animationLayer = nil
                self.animationSucceedLayer = nil
                self.actionBtn.setImage(UIImage(named: "mx_scene_action_unselected"), for: .normal)
                self.recovery()
            }
        }

    }
    
    func recovery() -> Void {
        
        let animationOpacity = CABasicAnimation(keyPath: "opacity")
        animationOpacity.fromValue = 0
        animationOpacity.toValue = 1
        animationOpacity.repeatCount = 1
        animationOpacity.duration = 0.3
        animationOpacity.delegate = self
        actionBtn.layer.add(animationOpacity, forKey: "opacity")
        
    }
    
    
}
