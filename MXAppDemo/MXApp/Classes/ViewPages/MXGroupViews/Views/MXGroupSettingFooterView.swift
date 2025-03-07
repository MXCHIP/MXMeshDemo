
import Foundation
import UIKit

protocol MXGroupSettingFooterViewDelegate {
    
    func setFavorite(status: Bool) -> Void
        
    func editDevices() -> Void
    
}

class MXGroupSettingFooterView: UICollectionReusableView {
    
    @objc func setFavorite(sender: UISwitch) -> Void {
        self.delegate?.setFavorite(status: sender.isOn)
    }
    
    @objc func editDevices(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.editDevices()
    }
    
    var group: MXDeviceInfo? {
        
        didSet {
            guard let group = group else {
                return
            }
            
            self.favoriteSwitch.isOn = group.isFavorite
            
            if let nodes = group.subDevices {
                self.amountLabel.text = "\(nodes.count)" + localized(key: "个")
                self.layoutSubviews()
            }
            
            self.delegate?.setFavorite(status: self.favoriteSwitch.isOn)
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubViews() -> Void {
        self.backgroundColor = UIColor.clear
        self.addSubview(favoriteView)
        favoriteView.addSubview(favoriteLabel)
        favoriteView.addSubview(favoriteSwitch)
        self.addSubview(amountView)
        amountView.addSubview(amountTitleLabel)
        amountView.addSubview(amountLabel)
        amountView.addSubview(arrowLabel)
        
        favoriteView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        amountView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF

        favoriteSwitch.onTintColor = AppUIConfiguration.MainColor.C0
        favoriteLabel.text = localized(key: "设为常用设备")
        favoriteLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        favoriteLabel.textColor = AppUIConfiguration.NeutralColor.title
        amountTitleLabel.text = localized(key: "设备数量")
        amountTitleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        amountTitleLabel.textColor = AppUIConfiguration.NeutralColor.title
        amountLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        amountLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        arrowLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        arrowLabel.text = "\u{e6df}"

        favoriteView.round(with: RoundType.top, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
        amountView.round(with: RoundType.bottom, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)

        favoriteSwitch.addTarget(self, action: #selector(setFavorite(sender:)), for: UIControl.Event.valueChanged)
        
        let selectedDevice = UITapGestureRecognizer(target: self, action: #selector(editDevices(sender:)))
        amountView.addGestureRecognizer(selectedDevice)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        favoriteView.pin.top().left(10).right(10).height(80)
        favoriteLabel.pin.left(20).vCenter().sizeToFit()
        favoriteSwitch.pin.right(20).width(44).height(26).vCenter()
        amountView.pin.below(of: favoriteView).left(10).right(10).height(80)
        amountTitleLabel.pin.left(20).vCenter().sizeToFit()
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
        amountLabel.pin.before(of: arrowLabel, aligned: .center).marginRight(4).vCenter().sizeToFit()
    }
    
    let favoriteView = UIView(frame: .zero)
    let favoriteLabel = UILabel(frame: .zero)
    let favoriteSwitch = UISwitch(frame: .zero)
    let amountView = UIView(frame: .zero)
    let amountTitleLabel = UILabel(frame: .zero)
    let amountLabel = UILabel(frame: .zero)
    let arrowLabel = UILabel(frame: .zero)
    
    var delegate: MXGroupSettingFooterViewDelegate?
    
}
