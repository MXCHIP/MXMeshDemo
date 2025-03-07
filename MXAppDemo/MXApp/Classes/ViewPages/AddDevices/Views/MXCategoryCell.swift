
import Foundation

class MXCategoryCell: UITableViewCell {
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.bgView.backgroundColor = AppUIConfiguration.MainColor.C0
                self.nameLB.textColor = UIColor.white
            } else {
                self.bgView.backgroundColor = UIColor.clear
                self.nameLB.textColor = AppUIConfiguration.NeutralColor.primaryText
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.pin.left(12).right(12).top(13).height(34)
        self.bgView.layer.cornerRadius = 17
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.all()
        
        if self.mxSelected {
            self.bgView.backgroundColor = AppUIConfiguration.MainColor.C0
            self.nameLB.textColor = UIColor.white
        } else {
            self.bgView.backgroundColor = UIColor.clear
            self.nameLB.textColor = AppUIConfiguration.NeutralColor.primaryText
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(12).right(12).top(13).height(34)
        self.nameLB.pin.all()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = UIColor.clear;
        _bgView.layer.cornerRadius = 17.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.primaryText;
        _nameLB.textAlignment = .center
        return _nameLB
    }()
}
