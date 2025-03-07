
import Foundation


class MXSceneTypeCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        
        self.contentView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(20).height(20).top(29)
        
        self.contentView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(20).minHeight(18).maxHeight(60).sizeToFit(.width)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(20).width(32).height(32).vCenter()
        self.nameLab.pin.right(of: self.iconView).marginLeft(20).right(20).height(20).top(29)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).right(20).minHeight(18).maxHeight(60).sizeToFit(.width)
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    public lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 20, y: 34, width: 32, height: 32))
        _iconView.backgroundColor = UIColor.clear
        _iconView.clipsToBounds = true
        return _iconView
    }()
    
    public lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3, weight: .medium);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        return _nameLab
    }()
    
    public lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _valueLab.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _valueLab.textAlignment = .left
        _valueLab.numberOfLines = 0
        return _valueLab
    }()
}
