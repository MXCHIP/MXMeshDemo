
import Foundation
import SDWebImage
import MeshSDK

class MXSelectCategoryCell: UITableViewCell {
    
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
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshView(info: MXProductInfo) {
        self.iconView.image = nil
        self.nameLB.text = nil
        
        self.nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        if let nickName = info.name {
            self.nameLB.text = nickName
        }
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
        
        if let imageStr = info.image {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(16).vCenter()
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconView.backgroundColor = UIColor.clear
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
}
