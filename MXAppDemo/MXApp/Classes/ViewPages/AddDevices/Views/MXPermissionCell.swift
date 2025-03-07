
import Foundation


class MXPermissionCell: UITableViewCell {
    
    var deviceInfo : [String : Any]!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        
        self.bgView.layer.cornerRadius = 16
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.left(20).width(20).height(20).vCenter()
        
        self.bgView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(20).height(20).right(60).vCenter()
        
        self.bgView.addSubview(self.actionView)
        self.actionView.pin.right(20).width(20).height(20).vCenter()
        
        self.bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshView(info: [String : Any]) {
        self.iconView.text = nil
        self.nameLB.text = nil
        
        self.deviceInfo = info
        
        if let icon = deviceInfo["icon"] as? String {
            self.iconView.text = icon
        }
        
        if let name = deviceInfo["name"] as? String {
            self.nameLB.text = name
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.left(10).right(10).top().bottom(0)
        self.iconView.pin.left(20).width(20).height(20).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(20).height(20).right(60).vCenter()
        self.actionView.pin.right(20).width(20).height(20).vCenter()
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        _bgView.backgroundColor = UIColor.white;
        _bgView.layer.cornerRadius = 8.0;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var iconView : UILabel = {
        let _iconView = UILabel(frame: .zero)
        _iconView.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        _iconView.textColor = AppUIConfiguration.NeutralColor.title;
        _iconView.textAlignment = .center
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        return _nameLB
    }()
    
    lazy var actionView : UILabel = {
        let _actionView = UILabel(frame: .zero)
        _actionView.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1);
        _actionView.textColor = AppUIConfiguration.NeutralColor.disable;
        _actionView.textAlignment = .center
        _actionView.text = "\u{e6df}"
        return _actionView
    }()
}
