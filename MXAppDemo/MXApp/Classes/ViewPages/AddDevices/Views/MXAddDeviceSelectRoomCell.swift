
import Foundation
import UIKit

class MXAddDeviceSelectRoomCell: UICollectionViewCell {
    
    public var mxSelected: Bool = false {
        didSet {
            if self.mxSelected {
                self.bgView.layer.borderColor = AppUIConfiguration.MainColor.C0.cgColor
                self.nameLB.textColor = AppUIConfiguration.MainColor.C0
            } else {
                self.bgView.layer.borderColor = AppUIConfiguration.NeutralColor.dividers.cgColor
                self.nameLB.textColor = AppUIConfiguration.NeutralColor.primaryText
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.all()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.nameLB.pin.all()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.zero)
        _bgView.backgroundColor = .clear
        _bgView.layer.cornerRadius = 4.0
        _bgView.clipsToBounds = true
        _bgView.layer.borderWidth = 1.0
        _bgView.layer.borderColor = AppUIConfiguration.NeutralColor.dividers.cgColor
        return _bgView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.primaryText;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
}
