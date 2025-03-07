
import Foundation
import UIKit

class MXRoomWallpaperPage: MXBaseViewController {
    
    var color: String = AppUIConfiguration.MainColor.C0.toHexString
    
    
    @objc func saveButtonAction(sender: UIButton) -> Void {
        NotificationCenter.default.post(name: NSNotification.Name.init("ROOM_SET_WALLPAPER"), object: nil, userInfo: ["color": self.color])
    }
    
    
    @objc func chooseColor(sender: UITapGestureRecognizer) -> Void {
        let url = "https://com.mxchip.bta/page/home/room/wallpapers"
        let params = ["color": self.color]
        MXURLRouter.open(url: url, params: params)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavView()
        initSubviews()
        
        gradientLayer.colors = [UIColor(hex: self.color).cgColor, UIColor(hex: self.color).withAlphaComponent(0.0).cgColor]
    }
    
    func initNavView() -> Void {
        self.title = localized(key: "房间壁纸")
        
        let rightButton = UIButton()
        let att = NSAttributedString(string: localized(key: "保存"),
                                     attributes: [NSAttributedString.Key.foregroundColor: AppUIConfiguration.NeutralColor.primaryText,
                                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)])
        rightButton.setAttributedTitle(att, for: UIControl.State.normal)
        
        rightButton.addTarget(self, action: #selector(saveButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightButton)
        rightButton.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        contentView.addSubview(bgView)
        bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        let bgViewColor = UIView()
        bgViewColor.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        bgView.addSubview(bgViewColor)
        bgViewColor.pin.top().left().height(60).width(screenWidth)
        
        let colorTitleLabel = UILabel()
        bgViewColor.addSubview(colorTitleLabel)
        colorTitleLabel.text = localized(key: "房间壁纸")
        colorTitleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        colorTitleLabel.textColor = AppUIConfiguration.NeutralColor.title
        colorTitleLabel.pin.left(16).height(20).width(70).vCenter()

        let colorArrowLabel = UILabel()
        bgViewColor.addSubview(colorArrowLabel)
        colorArrowLabel.text = "\u{e6df}"
        colorArrowLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        colorArrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        colorArrowLabel.pin.right(16).height(20).width(20).vCenter()
        
        let tapColorView = UITapGestureRecognizer(target: self, action: #selector(chooseColor(sender:)))
        bgViewColor.addGestureRecognizer(tapColorView)
        
        bgView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = CGRect.init(x: 12, y: 72, width: UIScreen.main.bounds.width - 16*2, height: screenHeight - statusBarHight - 44.0 - 12 - 60 - 10)
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        gradientLayer.cornerRadius = 16
        gradientLayer.masksToBounds = true
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bgView.pin.top(12).left().right().bottom()
    }
    
    let bgView = UIView()
    
    let gradientLayer = CAGradientLayer()
        
}


extension MXRoomWallpaperPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        
        let vc = MXRoomWallpaperPage()
        if let color = params["color"] as? String {
            vc.color = color
        }
        return vc
    }
    
}
