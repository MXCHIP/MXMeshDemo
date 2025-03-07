
import Foundation

class MXGroupSettingRoomCell: UICollectionViewCell {
    
    var info: MXRoomInfo? {
        
        didSet {
            
            guard let info = info else {
                return
            }
            
            self.titleLabel.text = info.name
            
            if info.isSelected  {
                self.titleLabel.backgroundColor = AppUIConfiguration.MainColor.C0
                self.titleLabel.textColor = AppUIConfiguration.MXColor.white
            } else {
                self.titleLabel.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
                self.titleLabel.textColor = AppUIConfiguration.NeutralColor.title
            }
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubviews() -> Void {
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.pin.all()
    }
    
    
    let titleLabel = UILabel(frame: .zero)
    
}
