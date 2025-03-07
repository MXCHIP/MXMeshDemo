
import Foundation
import UIKit

open class EmptyView: UIView {
    
    public var firstReloadHidden = false
}

open class MXActionEmptyView: EmptyView {
    
    public typealias DidClickActionCallback = () -> ()
    public var didClickActionCallback : DidClickActionCallback!
    
    public var imageView : UIImageView!
    public var actionBtn : UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.imageView = UIImageView(image: UIImage(named: "mx_view_no_device"))
        self.imageView.backgroundColor = UIColor.clear
        self.addSubview(self.imageView)
        self.imageView.pin.width(164).height(160).vCenter(-40).hCenter()
        
        self.actionBtn = UIButton.init(type: .custom)
        self.actionBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        self.actionBtn.titleLabel?.font =  UIFont.systemFont(ofSize:AppUIConfiguration.TypographySize.H3)
        self.actionBtn.setTitle(localized(key:"添加设备"), for: .normal)
        self.actionBtn.setTitleColor(UIColor.white, for: .normal)
        self.actionBtn.layer.cornerRadius = 24.0
        self.actionBtn.layer.masksToBounds = true
        self.addSubview(self.actionBtn)
        self.actionBtn.pin.below(of: self.imageView, aligned: .center).marginTop(32).width(116).height(48)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .touchUpInside)
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.actionBtn.isHidden {
            self.imageView.pin.width(164).height(160).center()
        } else {
            self.imageView.pin.width(164).height(160).vCenter(-40).hCenter()
        }
        self.actionBtn.pin.below(of: self.imageView, aligned: .center).marginTop(32).width(116).height(48)
    }
    
    @objc func didAction() {
        self.didClickActionCallback?()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class MXTitleEmptyView: EmptyView {
    
    public var imageView : UIImageView!
    public var titleLB : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.imageView = UIImageView(image: UIImage(named: "emptyBG"))
        self.imageView.backgroundColor = UIColor.clear
        self.addSubview(self.imageView)
        self.imageView.pin.width(68).height(68).vCenter(-22).hCenter()
        
        self.titleLB = UILabel(frame: CGRect(x: 40, y: 0, width: self.frame.size.width-80, height: 20))
        self.titleLB.backgroundColor = .clear
        self.titleLB.numberOfLines = 0
        self.titleLB.font =  UIFont.systemFont(ofSize:AppUIConfiguration.TypographySize.H4)
        self.titleLB.textAlignment = .center
        self.titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        self.titleLB.text = localized(key:"暂无内容")
        self.addSubview(self.titleLB)
        self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).height(20)
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if self.titleLB.isHidden {
            self.imageView.pin.width(68).height(68).center()
        } else {
            self.imageView.pin.width(68).height(68).vCenter(-22).hCenter()
        }
        self.titleLB.pin.below(of: self.imageView).marginTop(24).left(40).right(40).height(20)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
