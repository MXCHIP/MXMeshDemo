
import Foundation

class MXFooterMenuCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(self.iconLB)
        self.iconLB.pin.width(40).height(40).top().hCenter()
        
        self.contentView.addSubview(self.nameLab)
        self.nameLab.pin.left(0).below(of: self.iconLB).marginTop(4).right(0).height(16)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconLB.pin.width(40).height(40).top().hCenter()
        self.nameLab.pin.left(0).below(of: self.iconLB).marginTop(4).right(0).height(16)
    }
    
    lazy public var iconLB : UILabel = {
        let _iconLB = UILabel(frame: CGRect(x: 0, y: 10, width: 40, height: 40))
        _iconLB.backgroundColor = AppUIConfiguration.MainColor.C0
        _iconLB.clipsToBounds = true
        _iconLB.layer.cornerRadius = 20
        _iconLB.textAlignment = .center
        _iconLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        _iconLB.textColor = UIColor.white
        return _iconLB
    }()
    
    lazy public var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _nameLab.textAlignment = .center
        return _nameLab
    }()
}
