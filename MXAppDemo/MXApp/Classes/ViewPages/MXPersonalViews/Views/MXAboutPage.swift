
import Foundation
import UIKit
import SwiftUI

class MXAboutPage: MXBaseViewController {
    
    
    @objc func serviceAgreement(gesture: UITapGestureRecognizer) -> Void {
        viewModel.serviceAgreement()
    }
    
    
    @objc func privacyPolicy(gesture: UITapGestureRecognizer) -> Void {
        viewModel.privacyPolicy()
    }
    
    
    @objc func goToAppStore(gesture: UITapGestureRecognizer) -> Void {
        viewModel.goToAppStore()
    }
    
    let viewModel = MXAboutPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavviews()
        initSubviews()
        viewModel.observe { [weak self] model in
            self?.updateSubviews(with: model)
        }
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
        viewModel.syncData()
    }
    
    func updateSubviews(with model: MXAboutPageModel) -> Void {
        self.versionLabel.text = model.currentVersion
        if let newVersion = model.newVersion {
            self.versionCheckView.updateSubviews(with: ["title": localized(key: "检查新版本"),
                                                        "newVersion": newVersion])
        }
    }
    
    func initNavviews() -> Void {
        self.title = localized(key: "关于我们")
    }
    
    func initSubviews() -> Void {
        self.contentView.addSubview(iconImageView)
        iconImageView.image = UIImage(named: "Logo68")
        iconImageView.layer.cornerRadius = 8
        iconImageView.layer.masksToBounds = true
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        longPressGes.minimumPressDuration = 5
        longPressGes.numberOfTouchesRequired = 1
        longPressGes.allowableMovement = 15
        self.iconImageView.isUserInteractionEnabled = true
        self.iconImageView.addGestureRecognizer(longPressGes)
        
        self.contentView.addSubview(versionLabel)
        versionLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        versionLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        versionLabel.textAlignment = .center
        
        self.contentView.addSubview(bgView)
        bgView.layer.cornerRadius = 16
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.bgView.addSubview(serviceProtocolView)
        self.bgView.addSubview(privacyPolicyView)
        self.bgView.addSubview(versionCheckView)
        
        serviceProtocolView.updateSubviews(with: ["title": localized(key: "服务协议")])
        privacyPolicyView.updateSubviews(with: ["title": localized(key: "隐私政策")])
        versionCheckView.updateSubviews(with: ["title": localized(key: "检查新版本")])
        
        serviceProtocolView.addTapGesture(with: self, action: #selector(serviceAgreement(gesture: )))
        privacyPolicyView.addTapGesture(with: self, action: #selector(privacyPolicy(gesture: )))
        versionCheckView.addTapGesture(with: self, action: #selector(goToAppStore(gesture: )))
        
        self.contentView.addSubview(icpLabel)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        iconImageView.pin.top(32).hCenter().width(68).height(68)
        versionLabel.pin.below(of: iconImageView).marginTop(16).left().right().height(18)
        bgView.pin.below(of: versionLabel).marginTop(32).left(16).right(16).height(196)
        serviceProtocolView.pin.top(8).left().right().height(60)
        privacyPolicyView.pin.below(of: serviceProtocolView).left().right().height(60)
        versionCheckView.pin.below(of: privacyPolicyView).left().right().height(60)
        
        icpLabel.pin.bottom(self.view.pin.safeArea.bottom + 8).left(20).right(20).height(20)
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            MXURLRouter.open(url: "https://com.mxchip.bta/page/mine/tools", params: nil)
        }
    }
    
    let iconImageView = UIImageView(frame: .zero)
    let versionLabel = UILabel(frame: .zero)
    let bgView = UIView(frame: .zero)
    let serviceProtocolView = MXAboutItemView(frame: .zero)
    let privacyPolicyView = MXAboutItemView(frame: .zero)
    let versionCheckView = MXAboutItemView(frame: .zero)
    
    private lazy var icpLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(with: "8C8C8C", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 0.45)
        label.text = "沪ICP备05042130号-19A"
        label.backgroundColor = .clear
        label.textAlignment = .center
        return label
    }()
}


extension MXAboutPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXAboutPage()
        return vc
    }
    
}


class MXAboutItemView: UIView {
    
    func addTapGesture(with target: Any?, action: Selector?) -> Void {
        let tap = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tap)
    }
    
    func updateSubviews(with data: [String: Any]) -> Void {
        if let title = data["title"] as? String {
            self.titleLabel.text = title
        }
        
        if let newVersion = data["newVersion"] as? String {
            let str = NSMutableAttributedString()
            let str1 = NSAttributedString(string: newVersion,
                                          attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4),
                                                       .foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
            str.append(str1)
            let str2 = NSAttributedString(string: "\u{e72e}",
                                          attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4),
                                                       .foregroundColor:UIColor.red])
            str.append(str2)
            contentLabel.attributedText = str
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.addSubview(titleLabel)
        self.addSubview(contentLabel)
        self.addSubview(arrowLabel)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular,
                                 size: AppUIConfiguration.TypographySize.H4)
        
        contentLabel.textAlignment = .right
        
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        arrowLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont,
                                 size: AppUIConfiguration.TypographySize.H1)
        arrowLabel.text = "\u{e6df}"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.pin.left(16).vCenter().width(200).height(20)
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
        contentLabel.pin.before(of: arrowLabel, aligned: .center).marginRight(4).width(200).height(20)
    }
    
    let titleLabel = UILabel(frame: .zero)
    let contentLabel = UILabel(frame: .zero)
    let arrowLabel = UILabel(frame: .zero)
    
}
