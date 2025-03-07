
import Foundation
import UIKit

protocol MXGroupSettingHeaderViewDelegate {
    
    func updated(name: String) -> Void
        
}

class MXGroupSettingHeaderView: UICollectionReusableView {
    
    var group: MXDeviceInfo? {
        
        didSet {
            guard let group = group else {
                return
            }
            
            if let name = group.name {
                self.nameTextField.placeholder = name
                self.delegate?.updated(name: name)
            }
            if let image = group.image {
                self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
            }
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func initSubViews() -> Void {
        self.backgroundColor = UIColor.clear
        self.addSubview(imgView)
        self.addSubview(nameTextField)
        self.addSubview(roomLabel)
        nameTextField.textAlignment = .center
        nameTextField.delegate = self
        nameTextField.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        nameTextField.layer.cornerRadius = 30
        nameTextField.returnKeyType = .done
        roomLabel.text = localized(key: "选择房间（方便管理群组位置）")
        roomLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        roomLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.pin.top(32).width(60).height(60).hCenter()
        nameTextField.pin.below(of: imgView).marginTop(32).left(10).right(10).height(60)
        roomLabel.pin.below(of: nameTextField, aligned: .left).marginLeft(10).marginTop(24).sizeToFit()
    }
    
    let imgView = UIImageView(frame: .zero)
    let nameTextField = UITextField(frame: .zero)
    let roomLabel = UILabel(frame: .zero)

    var delegate: MXGroupSettingHeaderViewDelegate?
}

extension MXGroupSettingHeaderView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if let name = textField.text?.trimmingCharacters(in: .whitespaces) {
            if name.count > 0 {
                if !name.isValidName() {
                    MXToastHUD.showInfo(status: localized(key:"名称长度限制"))
                    textField.text = nil
                    return true
                }
                self.delegate?.updated(name: name)
            } else {
                if let placeholder = textField.placeholder {
                    self.delegate?.updated(name: placeholder)
                }
            }
        }
        return true
    }
    
}
