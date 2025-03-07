
import Foundation
import PinLayout
import UIKit

class MXTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSubviews(with data: [String: Any]) -> Void {
        
    }
    
}

class ImageTitleContentImageCellModel: NSObject {
    
    var leftImage: String?
    var title = ""
    var content = ""
    var rightImage: String?
    var identifier = ""
    var go = true
    
    init(leftImage: String?, title: String, content: String, rightImage: String?, identifier: String, go: Bool) {
        self.leftImage = leftImage
        self.title = title
        self.content = content
        self.rightImage = rightImage
        self.identifier = identifier
        self.go = go
    }
    
}

class ImageTitleContentImageCell: UITableViewCell {
    
    func updateSubviews(model: ImageTitleContentImageCellModel) -> Void {
        leftImageLabel.isHidden = (model.leftImage == nil)
        rightImageLabel.isHidden = !model.go

        leftImageLabel.text = model.leftImage
        titleLabel.text = model.title
        if model.content == "\u{e72e}" {
            let att = NSAttributedString(string: model.content,
                                         attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4),
                                                        .foregroundColor:UIColor.red])
            contentLabel.attributedText = att
        } else {
            contentLabel.text = model.content
        }
        rightImageView.isHidden = model.rightImage == nil
        if let image = model.rightImage {
            if image.hasPrefix("http") {
                rightImageView.sd_setImage(with: URL(string: image), completed: nil)
            } else {
                rightImageView.image = UIImage(named: image)
            }
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layer.masksToBounds = true
        self.contentView.layer.masksToBounds = true
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.selectionStyle = .none
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.contentView.addSubview(bgView)
        bgView.backgroundColor = .clear
        bgView.pin.all()
        bgView.layer.cornerRadius = 16
        bgView.layer.masksToBounds = true
        
        bgView.addSubview(leftSideView)
        bgView.addSubview(rightSideView)

        bgView.addSubview(leftImageLabel)
        leftImageLabel.backgroundColor = AppUIConfiguration.MXBackgroundColor.bgA
        leftImageLabel.layer.cornerRadius = 9
        leftImageLabel.layer.masksToBounds = true
        leftImageLabel.textAlignment = .center
        leftImageLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        
        bgView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        
        bgView.addSubview(contentLabel)
        contentLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        contentLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
        bgView.addSubview(rightImageLabel)
        rightImageLabel.textAlignment = .center
        rightImageLabel.font = UIFont.iconFont(size: 20)
        rightImageLabel.textColor = AppUIConfiguration.NeutralColor.disable
        rightImageLabel.text = "\u{e6df}"
        
        bgView.addSubview(rightImageView)
        rightImageView.layer.cornerRadius = 20
        rightImageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isShowBg {
            bgView.pin.all()
        } else {
            bgView.pin.left(16).right(16).top().bottom()
        }
        leftSideView.pin.left(4).width(0).height(0).vCenter()
        rightSideView.pin.right(4).width(0).height(0).vCenter()
        leftImageLabel.pin.left(20).width(36).height(36).vCenter()
        titleLabel.pin.after(of: visible([leftSideView, leftImageLabel])).marginLeft(16).vCenter().sizeToFit()
        rightImageLabel.pin.right(16).width(20).height(20).vCenter()
        rightImageView.pin.before(of: visible([rightImageLabel, rightSideView])).marginRight(4).vCenter().width(40).height(40)
        contentLabel.pin.before(of: visible([rightSideView, rightImageLabel, rightImageView])).marginRight(4).vCenter().sizeToFit()
        
        self.layer.masksToBounds = true
        self.contentView.layer.masksToBounds = true
    }
    
    var isShowBg: Bool = false
    let bgView = UIView()
    let leftSideView = UIView()
    let leftImageLabel = UILabel()
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let rightImageLabel = UILabel()
    let rightImageView = UIImageView()
    let rightSideView = UIView()

}

class MXCornerCell: UITableViewCell {
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.preView)
        self.preView.pin.right(16).width(32).height(32).vCenter()
        
        self.preView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var preView : UIImageView = {
        let _preView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        _preView.backgroundColor = UIColor.clear
        _preView.clipsToBounds = true
        return _preView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.preView.pin.right(16).width(32).height(32).vCenter()
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
}

class MXActionCell: UITableViewCell {
    
    public typealias DidActionCallback = (_ isOn: Bool) -> ()
    public var didActionCallback : DidActionCallback!
    
    public var cellCorner: UIRectCorner? {
        didSet {
            if let corner = self.cellCorner {
                self.corner(byRoundingCorners: corner, radii: 16)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.preView)
        self.preView.pin.right(16).width(32).height(32).vCenter()
        self.contentView.addSubview(self.actionBtn)
        self.actionBtn.pin.right(16).width(44).height(26).vCenter()
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.preView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.preView.pin.right(16).width(32).height(32).vCenter()
        self.actionBtn.pin.right(16).width(44).height(26).vCenter()
        if let corner = self.cellCorner {
            self.corner(byRoundingCorners: corner, radii: 16)
        }
    }
    
    public lazy var preView : UIImageView = {
        let _preView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        _preView.backgroundColor = UIColor.clear
        _preView.clipsToBounds = true
        return _preView
    }()
    
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
}

