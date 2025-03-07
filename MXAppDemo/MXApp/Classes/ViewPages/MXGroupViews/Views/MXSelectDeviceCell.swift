
import Foundation
import SDWebImage
import MeshSDK

class MXSelectDeviceCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    public typealias SelectDeviceActionCallback = (_ item: MXDeviceInfo) -> ()
    public var selectDeviceCallback : SelectDeviceActionCallback!
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.selectBtn.setTitle("\u{e6f3}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
            } else {
                self.selectBtn.setTitle("\u{e6fb}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
            }
        }
    }
    
    var info : MXDeviceInfo! {
        didSet {
            self.refreshView()
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
        
        self.contentView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(16).width(24).height(24).vCenter()
        self.selectBtn.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).left(of: self.selectBtn).marginRight(16).vCenter()
        
    }
    
    @objc func selectAction() {
        self.selectDeviceCallback?(self.info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshView() {
        
        self.selectBtn.isHidden = false
        if self.mxSelected {
            self.selectBtn.setTitle("\u{e6f3}", for: .normal)
            self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
        } else {
            self.selectBtn.setTitle("\u{e6fb}", for: .normal)
            self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        }
        
        self.nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        self.nameLB.text = self.info.showName
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
        
        if let imageStr = self.info.image {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        } else if let imageStr = self.info.productInfo?.image {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        self.selectBtn.pin.right(16).width(24).height(24).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).left(of: self.selectBtn).marginRight(16).vCenter()
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        return _iconView
    }()
    
    lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        return _selectBtn
    }()
}

class MXAddDeviceCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    public typealias SelectDeviceActionCallback = (_ item: MXDeviceInfo) -> ()
    public var selectDeviceCallback : SelectDeviceActionCallback!
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.selectBtn.isHidden = true
            } else {
                self.selectBtn.isHidden = false
            }
            self.layoutSubviews()
        }
    }
    
    var info : MXDeviceInfo! {
        didSet {
            self.refreshView()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.contentView.addSubview(self.selectBtn)
        self.selectBtn.pin.left(16).width(20).height(20).vCenter()
        self.selectBtn.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.right(of: self.selectBtn).marginLeft(16).width(40).height(40).vCenter()
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(70).vCenter()
        
    }
    
    @objc func selectAction() {
        self.selectDeviceCallback?(self.info)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshView() {
        
        self.nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        self.nameLB.text = self.info.showName
        
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
        
        if let imageStr = self.info.image {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        } else if let imageStr = self.info.productInfo?.image {
            self.iconView.sd_setImage(with: URL(string: imageStr), placeholderImage: UIImage(named: imageStr), completed: nil)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectBtn.pin.left(16).width(20).height(20).vCenter()
        if self.mxSelected {
            self.iconView.pin.left(16).width(40).height(40).vCenter()
        } else {
            self.iconView.pin.right(of: self.selectBtn).marginLeft(16).width(40).height(40).vCenter()
        }
        self.nameLB.pin.right(of: self.iconView).marginLeft(16).height(20).right(70).vCenter()
        
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
    
    lazy var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        _selectBtn.setTitle("\u{e6f5}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.MXAssistColor.main, for: .normal)
        return _selectBtn
    }()
}
