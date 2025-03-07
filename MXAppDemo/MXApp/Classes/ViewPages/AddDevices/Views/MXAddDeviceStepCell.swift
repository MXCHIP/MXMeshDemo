
import Foundation


class MXAddDeviceStepCell: UITableViewCell {
    
    public var nameLeftOffSet: CGFloat = 72
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func updateSubViews(info:MXProvisionStepInfo) {
        self.nameLB.text = info.name
        self.statusLB.textColor = AppUIConfiguration.MXAssistColor.main
        self.statusLB.text = nil
        switch info.status {
        case 0:
            self.nameLB.textColor = AppUIConfiguration.NeutralColor.disable
            
            break
        case 1:
            self.nameLB.textColor = AppUIConfiguration.MXAssistColor.main
            
            break
        case 2:
            self.nameLB.textColor = AppUIConfiguration.MXAssistColor.main
            
            break
        case 3:
            self.nameLB.textColor = AppUIConfiguration.MXAssistColor.red
            self.statusLB.textColor = AppUIConfiguration.MXAssistColor.red
            
            break
        default:
            self.nameLB.textColor = AppUIConfiguration.NeutralColor.disable
            self.statusLB.text = nil
            break
        }
        
        self.layoutSubviews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.left(self.nameLeftOffSet).top().right(self.nameLeftOffSet).height(18)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.nameLB.pin.left(self.nameLeftOffSet).top().right(self.nameLeftOffSet).height(18)
        
        
    }
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.backgroundColor = .clear
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.disable;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
    
    lazy var statusLB : UILabel = {
        let _statusLB = UILabel(frame: .zero)
        _statusLB.backgroundColor = .clear
        _statusLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H5)
        _statusLB.textColor = AppUIConfiguration.MainColor.C0;
        _statusLB.textAlignment = .center
        return _statusLB
    }()
}
