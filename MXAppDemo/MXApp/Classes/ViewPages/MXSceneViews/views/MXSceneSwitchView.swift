
import Foundation
import UIKit
import PinLayout

class MXSceneSwitchView: UIView {
    
    public typealias DidValueChangeCallback = (_ value: Int) -> ()
    public var didValueChangeCallback : DidValueChangeCallback?
    
    @objc func switchOn(tap: UITapGestureRecognizer) -> Void {
        status = 1
    }
    
    @objc func switchOff(tap: UITapGestureRecognizer) -> Void {
        status = 0
    }
    
    
    var status: Int = -1 {
        didSet {
            var onIcon = ""
            var onIconColor = UIColor()
            var offIcon = ""
            var offIconColor = UIColor()
            if status == -1 {
                onIcon = "\u{e79b}"
                offIcon = "\u{e79b}"
                onIconColor = AppUIConfiguration.NeutralColor.border
                offIconColor = AppUIConfiguration.NeutralColor.border
            } else if status == 0 {
                onIcon = "\u{e79b}"
                offIcon = "\u{e79c}"
                onIconColor = AppUIConfiguration.NeutralColor.border
                offIconColor = AppUIConfiguration.MainColor.C0
            } else if status == 1 {
                onIcon = "\u{e79c}"
                offIcon = "\u{e79b}"
                onIconColor = AppUIConfiguration.MainColor.C0
                offIconColor = AppUIConfiguration.NeutralColor.border
            }
            self.onIconLabel.text = onIcon
            self.offIconLabel.text = offIcon
            self.onIconLabel.textColor = onIconColor
            self.offIconLabel.textColor = offIconColor
            self.didValueChangeCallback?(self.status)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.addSubview(onView)
        self.addSubview(offView)
        onView.addSubview(onTitleLabel)
        onView.addSubview(onIconLabel)
        offView.addSubview(offTitleLabel)
        offView.addSubview(offIconLabel)
        
        onTitleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        onIconLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        offTitleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        offIconLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        
        onTitleLabel.textColor = AppUIConfiguration.NeutralColor.title
        offTitleLabel.textColor = AppUIConfiguration.NeutralColor.title
        onTitleLabel.text = localized(key: "开启")
        offTitleLabel.text = localized(key: "关闭")
        
        let switchOnTap = UITapGestureRecognizer(target: self, action: #selector(switchOn(tap:)))
        onIconLabel.addGestureRecognizer(switchOnTap)
        let switchOffTap = UITapGestureRecognizer(target: self, action: #selector(switchOff(tap:)))
        offIconLabel.addGestureRecognizer(switchOffTap)
        
        onIconLabel.isUserInteractionEnabled = true
        offIconLabel.isUserInteractionEnabled = true
        
        self.status = -1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        onView.pin.left().right().top().height(50%)
        offView.pin.below(of: onView).left().right().bottom().height(50%)
        onTitleLabel.pin.left(20).vCenter().sizeToFit()
        offTitleLabel.pin.left(20).vCenter().sizeToFit()
        onIconLabel.pin.right(20).vCenter().width(20).height(20)
        offIconLabel.pin.right(20).vCenter().width(20).height(20)
    }
    
    let onView = UIView(frame: .zero)
    let offView = UIView(frame: .zero)
    let onTitleLabel = UILabel(frame: .zero)
    let offTitleLabel = UILabel(frame: .zero)
    let onIconLabel = UILabel(frame: .zero)
    let offIconLabel = UILabel(frame: .zero)
    
}
