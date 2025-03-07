
import Foundation
import UIKit

class MXCollectionHeaderView: UICollectionReusableView {
    
    public typealias DidMoreCallback = () -> ()
    public var didMoreCallback : DidMoreCallback!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLB)
        self.titleLB.pin.left(20).right(60).top().bottom()
        self.addSubview(self.moreBtn)
        self.moreBtn.addTarget(self, action: #selector(gotoManager), for: .touchUpInside)
        self.moreBtn.pin.right(0).top().bottom().width(50)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.left(20).right(60).top().bottom()
        self.moreBtn.pin.right(0).top().bottom().width(50)
    }
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.init(x: 20, y: 0, width: self.frame.size.width-40, height: self.frame.size.height))
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.textAlignment = .left
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
        return _titleLB
    }()
    
    lazy public var moreBtn : UIButton = {
        let _moreBtn = UIButton.init(type: .custom)
        _moreBtn.backgroundColor = UIColor.clear
        _moreBtn.frame = CGRect.init(x: self.frame.size.width - 50, y: 0, width: 50, height: self.frame.size.height)
        _moreBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _moreBtn.setTitle("\u{e6fa}", for: .normal)
        _moreBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        return _moreBtn
    }()
    
    @objc func gotoManager() {
        self.didMoreCallback?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
