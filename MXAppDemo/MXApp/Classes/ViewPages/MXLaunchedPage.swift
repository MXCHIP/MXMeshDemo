
import Foundation
import UIKit

class MXLaunchedPage: UIViewController {

    @objc func signInButtonAction(sender: UIButton) -> Void {
        if self.agreeLabel.text == "\u{e6fb}" {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            animation.duration = 0.6
            animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
            self.protocolsView.layer.add(animation, forKey: "shake")
            MXToastHUD.showInfo(status: localized(key: "Account_请阅读并同意服务协议和隐私政策"))
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MXNotificationUserSignedIn"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showProtocols()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        initSubviews()
        self.view.backgroundColor = UIColor(hex: "010101")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initSubviews() -> Void {
        
        self.view.addSubview(bgImageView)
        bgImageView.pin.width(self.view.frame.size.width*2).height(self.view.frame.size.width*2).hCenter().vCenter(-60)
        bgImageView.contentMode = .scaleToFill
        bgImageView.clipsToBounds = true
        bgImageView.isUserInteractionEnabled = true
        
        self.view.addSubview(signInBtn)
        signInBtn.backgroundColor = AppUIConfiguration.MXColor.white
        let normalAtt = NSAttributedString(string: localized(key: "Account_账号登录"),
                                           attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: "262626"),
                                                        NSAttributedString.Key.font : UIFont(name: "PingFang-SC-Medium", size: AppUIConfiguration.TypographySize.H3) ?? UIFont()])
        signInBtn.setAttributedTitle(normalAtt, for: UIControl.State.normal)
        signInBtn.layer.cornerRadius = 25
        signInBtn.addTarget(self, action: #selector(signInButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        
        
        logoImageView.contentMode = .scaleAspectFill
        self.bgImageView.addSubview(logoImageView)
        self.logoImageView.pin.width(100).height(100).center()
        
        self.bgImageView.addSubview(nameLabel)
        nameLabel.text = localized(key: "Account_智家精灵")
        nameLabel.textColor = AppUIConfiguration.MXColor.white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographyUndefinedSize.H0)
        self.nameLabel.pin.left(20).right(20).below(of: self.logoImageView).marginTop(12).height(36)
        
        self.view.addSubview(protocolsView)

        self.protocolsView.addSubview(protocolsLabel)
        protocolsLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(protocolsLabelTapGestureAction(gesture:)))
        protocolsLabel.addGestureRecognizer(tap)
        protocolsLabel.numberOfLines = 0
        let pro1 = localized(key: "Account_《服务协议》")
        let pro2 = localized(key: "Account_《隐私政策》")
        let pro = localized(key: "Account_我已阅读并同意") + pro1 + localized(key: "Account_和") + pro2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        
        let font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        let attributedString = NSMutableAttributedString(string: pro, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor(hex: "FFFFFF", alpha: 0.85), NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        if let range1 = pro.nsRange(of: pro1) {
            attributedString.setAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor(hex: "FFFFFF", alpha: 1.0)], range: range1)
        }
        if let range2 = pro.nsRange(of: pro2) {
            attributedString.setAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor(hex: "FFFFFF", alpha: 1.0)], range: range2)
        }
        protocolsLabel.attributedText = attributedString
        
        self.protocolsView.addSubview(agreeLabel)
        agreeLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        agreeLabel.text = "\u{e6fb}"
        agreeLabel.textColor = .white
        agreeLabel.isUserInteractionEnabled = true
        let tapAgreeLabel = UITapGestureRecognizer(target: self, action: #selector(ifAgreeProtocols(sender:)))
        agreeLabel.addGestureRecognizer(tapAgreeLabel)
        agreeLabel.textAlignment = .center
        
        if let language = (MXAccountManager.shared.language ?? Locale.preferredLanguages.first),
            language.split(separator: "-").first == "en" {
            self.tagImageView.isHidden = true
        } else {
            self.tagImageView.isHidden = false
        }
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgImageView.pin.width(self.view.frame.size.width*2).height(self.view.frame.size.width*2).hCenter().vCenter(-60)
        signInBtn.pin.bottom(176 + self.view.pin.safeArea.bottom).hCenter().width(295).height(50)
        
        self.logoImageView.pin.width(100).height(100).center()
        self.nameLabel.pin.left(20).right(20).below(of: self.logoImageView).marginTop(12).height(36)
        
        tagImageView.pin.right(of: self.nameLabel).marginLeft(-4).above(of: self.nameLabel).marginBottom(-3).width(46).height(20)
        protocolsView.pin.below(of: signInBtn).marginTop(12).height(16 + 18 * 2).width(screenWidth - 60).hCenter()
        protocolsLabel.pin.maxWidth(270).sizeToFit(.width).vCenter().hCenter(28)
        agreeLabel.pin.left(of: protocolsLabel, aligned: .top).marginRight(4).marginTop(-4).width(24).height(24)
    }
    
    let signInBtn = UIButton()
    let nameLabel = UILabel()
    let logoImageView = UIImageView(image: UIImage(named: "Logo80"))
    let tagImageView = UIImageView(image: UIImage(named: "lite-Tag"))
    let bgImageView = UIImageView(image: UIImage(named: "login_bg"))
    let protocolsLabel = UILabel()
    let agreeLabel = UILabel()
    let protocolsView = UIView()
    
    
    var webAlertView: MXWebAlertView!
    func showProtocols() -> Void {
        if MXAccountManager.shared.ifAgreeProtocols {
            return
        }
        let language = MXAccountManager.shared.language ?? Locale.preferredLanguages[0]
        let themeColor = "FF33D1FF"
        var userInterfaceStyleString = "light"
        if #available(iOS 13, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                userInterfaceStyleString = "dark"
            }
        }
        if MXAccountManager.shared.darkMode == 1 {
            userInterfaceStyleString = "light"
        } else if MXAccountManager.shared.darkMode == 2 {
            userInterfaceStyleString = "dark"
        }
        
        MXResourcesManager.loadLocalAgreementUrl() { rootUrl in
            if let rootPath = rootUrl {
                let agreementUrl = "file://\(rootPath)/agreement.html" + "?navbarShow=true&themecolor=\(themeColor)&lang=\(language)&theme=\(userInterfaceStyleString)"
                print("本地的URL：\(agreementUrl)")
                self.webAlertView = MXWebAlertView(url: agreementUrl,
                                              leftButtonTitle: localized(key: "Account_不同意退出"),
                                              rightButtonTitle: localized(key: "Account_同意")) {
                    exit(0)
                } rightButtonCallBack: {
                    MXAccountManager.shared.ifAgreeProtocols = true
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.SDKInitialization()
                    }
                }
                
                self.webAlertView.show()
            }
        }
        
    }
    
    
    
    @objc func ifAgreeProtocols(sender: UITapGestureRecognizer) -> Void {
        if self.agreeLabel.text == "\u{e6fb}" {
            agreeLabel.text = "\u{e6f3}"
        } else {
            agreeLabel.text = "\u{e6fb}"
        }
    }
    
    
    @objc func protocolsLabelTapGestureAction(gesture: UITapGestureRecognizer) -> Void {
        let pro1 = localized(key: "Account_《服务协议》")
        let pro2 = localized(key: "Account_《隐私政策》")
        let pro = localized(key: "Account_我已阅读并同意") + pro1 + localized(key: "Account_和") + pro2
                
        if let range1 = pro.nsRange(of: pro1) {
            let tapped = gesture.didTapAttributedTextInLabel(label: protocolsLabel, inRange: range1)
            if tapped {
                MXResourcesManager.loadLocalAgreementUrl() { rootUrl in
                    if let rootPath = rootUrl {
                        let jumpUrl = "file://\(rootPath)/ServiceAgreement.html"
                        let params = ["url": jumpUrl, "title": localized(key: "服务协议")]
                        let url = "com.mxchip.bta/page/web"
                        MXURLRouter.open(url: url, params: params)
                    }
                }
            }
        }
        if let range2 = pro.nsRange(of: pro2) {
            let tapped = gesture.didTapAttributedTextInLabel(label: protocolsLabel, inRange: range2)
            if tapped {
                MXResourcesManager.loadLocalAgreementUrl() { rootUrl in
                    if let rootPath = rootUrl {
                        let jumpUrl = "file://\(rootPath)/PrivacyStatement.html"
                        let params = ["url": jumpUrl, "title": localized(key: localized(key: "隐私政策"))]
                        let url = "com.mxchip.bta/page/web"
                        MXURLRouter.open(url: url, params: params)
                    }
                }
            }
        }

    }

    
}

