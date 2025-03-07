
import Foundation
import SDWebImage

class MXProductCell: UICollectionViewCell {
    
    var info : MXProductInfo!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(self.iconView)
        self.iconView.pin.top(12).width(60).height(60).hCenter()
        
        self.addSubview(self.nameLB)
        self.nameLB.pin.below(of: self.iconView).marginTop(8).left(4).right(4).bottom(12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshView(info: MXProductInfo) {
        self.iconView.image = nil
        self.nameLB.text = nil
        
        self.info = info
        if let nickName = info.name {
            self.nameLB.text = nickName
        }
        if let productImage = info.image {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.top(12).width(60).height(60).hCenter()
        self.nameLB.pin.below(of: self.iconView).marginTop(8).left(4).right(4).bottom(12)
    }
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView()
        _iconView.backgroundColor = UIColor.clear
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H7);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .center
        _nameLB.numberOfLines = 2
        return _nameLB
    }()
}
