
import Foundation
import UIKit

class MXEmptyBackgroundView: UIView {
    
    convenience init(title: String, image: String) {
        self.init(frame: .zero)
        self.title = title
        self.image = image
        
        self.initSubviews()
    }
    
    func initSubviews() -> Void {
        self.addSubview(contentView)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(titleLabel)
        
        imageView.image = UIImage(named: self.image)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.text = self.title
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.all()
        imageView.pin.width(68).height(68)
        titleLabel.pin.below(of: imageView, aligned: .center).marginTop(24).width(120).height(20)
        contentView.pin.wrapContent().center()
    }
    
    
    let imageView = UIImageView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let contentView = UIView(frame: .zero)
    
    var title = ""
    var image = ""
    
}
