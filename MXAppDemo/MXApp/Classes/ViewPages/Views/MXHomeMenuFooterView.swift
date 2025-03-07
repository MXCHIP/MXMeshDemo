
import Foundation
import PinLayout


class MXHomeMenuFooterView: UIView {
    
    public typealias DidActionCallback = (_ index: Int) -> ()
    public var didActionCallback : DidActionCallback!
    
    public var leftBtn: MXLabelButton!
    public var rightBtn : MXLabelButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        leftBtn = MXLabelButton(type: .custom)
        leftBtn.titleLabel?.font = UIFont.iconFont(size: 18)
        leftBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        let attrStr = NSMutableAttributedString()
        let str1 = NSAttributedString(string: "\u{e710}  ", attributes: [.font: UIFont.iconFont(size:18),.foregroundColor:AppUIConfiguration.MainColor.C0])
        attrStr.append(str1)
        let str2 = NSAttributedString(string: localized(key:"新建家庭"), attributes: [.font: UIFont.systemFont(ofSize: 18),.foregroundColor:AppUIConfiguration.MainColor.C0])
        attrStr.append(str2)
        leftBtn.mxTitleLB.attributedText = attrStr
        leftBtn.tag = 1001
        leftBtn.addTarget(self, action: #selector(didClickAction(button:)), for: .touchUpInside)
        self.addSubview(leftBtn)
        leftBtn.pin.left().top().bottom().width(50%)
        
        rightBtn = MXLabelButton(type: .custom)
        rightBtn.titleLabel?.font = UIFont.iconFont(size: 18)
        rightBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        let right_attrStr = NSMutableAttributedString()
        let right_str1 = NSAttributedString(string: "\u{e707}  ", attributes: [.font: UIFont.iconFont(size:18),.foregroundColor:AppUIConfiguration.MainColor.C0])
        right_attrStr.append(right_str1)
        let right_str2 = NSAttributedString(string: localized(key:"家庭管理"), attributes: [.font: UIFont.systemFont(ofSize: 18),.foregroundColor:AppUIConfiguration.MainColor.C0])
        right_attrStr.append(right_str2)
        rightBtn.mxTitleLB.attributedText = right_attrStr
        rightBtn.tag = 1002
        rightBtn.addTarget(self, action: #selector(didClickAction(button:)), for: .touchUpInside)
        self.addSubview(rightBtn)
        rightBtn.pin.right(of: leftBtn, aligned: VerticalAlign.top).marginLeft(0).bottom().width(50%)

        self.isUserInteractionEnabled = true

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftBtn.pin.left().top().bottom().width(50%)
        rightBtn.pin.right(of: leftBtn, aligned: VerticalAlign.top).marginLeft(0).bottom().width(50%)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didClickAction(button: UIButton) {
        let index = button.tag - 1000 as Int
        self.didActionCallback?(index)
    }
}

class MXLabelButton: UIButton {
    public var mxTitleLB: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mxTitleLB = UILabel(frame: self.bounds)
        self.mxTitleLB.backgroundColor = UIColor.clear
        self.mxTitleLB.textAlignment = .center
        self.addSubview(self.mxTitleLB)
        self.mxTitleLB.pin.all()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mxTitleLB.pin.all()
    }
}
