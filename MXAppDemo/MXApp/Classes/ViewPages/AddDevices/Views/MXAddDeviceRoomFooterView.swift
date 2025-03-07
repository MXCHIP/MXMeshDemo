
import Foundation

public typealias MXDeviceInfoChangeCallback = (_ info: MXDeviceInfo) -> ()

class MXAddDeviceRoomFooterView: UICollectionReusableView {
    
    var infoChangeCallback : MXDeviceInfoChangeCallback?
    
    var info : MXDeviceInfo?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupViews() {
        self.backgroundColor = .clear
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.nameLab)
        self.nameLab.pin.left(20).right(70).height(20).vCenter(-4)
        
        self.bgView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(20).width(44).height(26).vCenter(-4)
        
        self.actionBtn.addTarget(self, action: #selector(didAction), for: .valueChanged)
    }
    
    public func refreshView(info: MXDeviceInfo) {
        self.info = info
        self.actionBtn.isOn = info.isFavorite
    }
    
    @objc func didAction() {
        self.info?.isFavorite = self.actionBtn.isOn
        if let newInfo = self.info {
            self.infoChangeCallback?(newInfo)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        self.nameLab.pin.left(20).right(70).height(20).vCenter(-4)
        self.actionBtn.pin.right(20).width(44).height(26).vCenter(-4)
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect.init(x: 10, y: 0, width: self.frame.size.width - 20, height: self.frame.size.height-10))
        _bgView.backgroundColor = .clear;
        _bgView.clipsToBounds = true;
        return _bgView
    }()
    
    lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        _nameLab.text = localized(key:"设为常用设备")
        return _nameLab
    }()
    
    lazy var actionBtn : UISwitch = {
        let _actionBtn = UISwitch(frame: CGRect(x: 0, y: 0, width: 44, height: 26))
        _actionBtn.onTintColor = AppUIConfiguration.MainColor.C0
        _actionBtn.tintColor = AppUIConfiguration.NeutralColor.disable
        _actionBtn.isOn = true
        return _actionBtn
    }()
}
