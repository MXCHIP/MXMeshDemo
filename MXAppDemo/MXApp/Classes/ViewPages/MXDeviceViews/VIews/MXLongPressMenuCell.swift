
import Foundation

class MXLongPressMenuCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ isOn: Bool) -> ()
    public var didActionCallback : DidActionCallback!
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    public typealias CopyActionCallback = () -> ()
    public var copyActionCallback : CopyActionCallback!
    
    public var canShowMenu :Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        
        longPressGes.minimumPressDuration = 1
        
        
        
        longPressGes.numberOfTouchesRequired = 1
        
        longPressGes.allowableMovement = 15

        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(longPressGes)
        
        self.contentView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(16).width(44).height(26).vCenter()
        
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.contentView.backgroundColor = .clear
    }
    
    public lazy var actionBtn : UISwitch = {
        let _actionBtn = UISwitch(frame: CGRect(x: 0, y: 0, width: 44, height: 26))
        _actionBtn.onTintColor = AppUIConfiguration.MainColor.C0
        _actionBtn.tintColor = AppUIConfiguration.NeutralColor.disable
        _actionBtn.addTarget(self, action: #selector(didAction), for: .valueChanged)
        return _actionBtn
    }()
    
    @objc func didAction() {
        self.didActionCallback?(self.actionBtn.isOn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.actionBtn.pin.right(16).width(44).height(26).vCenter()
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if !self.canShowMenu {
            return
        }
        
        if sender.state == .began {
            self.copyActionCallback?()
        }
        
    }
    
    @objc func nameCopy() {
        self.copyActionCallback?()
        
        let menuController = UIMenuController.shared
        if #available(iOS 13.0, *) {
            menuController.isMenuVisible = true
        } else {
            menuController.setMenuVisible(false, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(nameCopy) {
            return true
        }
        return false
    }
}
