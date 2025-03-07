
import Foundation

class MXWifiPasswordHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.left(24).right(24).top(24).height(24)
        
        self.addSubview(self.desLB)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(8).right(24).height(20)
    }
    
    override func layoutSubviews() {
        self.nameLB.pin.left(24).right(24).top(24).height(24)
        self.desLB.pin.below(of: self.nameLB, aligned: .left).marginTop(8).right(24).height(20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H0);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        _nameLB.text = localized(key:"连接Wi-Fi")
        return _nameLB
    }()
    
    lazy var desLB : UILabel = {
        let _desLB = UILabel(frame: .zero)
        _desLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _desLB.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _desLB.textAlignment = .left
        
        let valueStr = NSMutableAttributedString()
        let iconStr = NSAttributedString(string: "\u{e70c}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
        valueStr.append(iconStr)
        let desStr = NSAttributedString(string: localized(key:"只支持2.4G Wi-Fi网络"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
        valueStr.append(desStr)
        _desLB.attributedText = valueStr
        return _desLB
    }()
    
}
