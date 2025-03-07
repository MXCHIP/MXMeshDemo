
import Foundation
import UIKit

class MXRoomWallpaperPreviewPage: MXBaseViewController {
    
    var color: String = AppUIConfiguration.MainColor.C0.toHexString
    
    @objc func setWallpaper(sender: UIButton) -> Void {
        NotificationCenter.default.post(name: NSNotification.Name.init("ROOM_SET_WALLPAPER"), object: nil, userInfo: ["color": self.color])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavView()
        initSubviews()
        
        gradientLayer.colors = [UIColor(hex: self.color).cgColor, UIColor(hex: self.color).withAlphaComponent(0.0).cgColor]
    }
    
    func initNavView() -> Void {
        self.title = localized(key: "房间壁纸")
    }
    
    func initSubviews() -> Void {
        self.hideMXNavigationBar = true
        self.contentView.backgroundColor = UIColor.clear
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.pin.all()
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        gradientLayer.cornerRadius = 8
        gradientLayer.masksToBounds = true
        
        contentView.addSubview(confirmButton)
        confirmButton.layer.cornerRadius = 25
        confirmButton.layer.masksToBounds = true
        confirmButton.backgroundColor = AppUIConfiguration.MainColor.C0
        let att = NSAttributedString(string: localized(key: "将壁纸应用于此房间"),
                                     attributes: [NSAttributedString.Key.foregroundColor: AppUIConfiguration.MXColor.white,
                                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)])
        confirmButton.setAttributedTitle(att, for: .normal)
        confirmButton.addTarget(self, action: #selector(setWallpaper(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.pin.all()
        confirmButton.pin.left(16).right(16).bottom(10 + self.view.pin.safeArea.bottom).height(50)
    }
    
    let gradientLayer = CAGradientLayer()
        
    let confirmButton = UIButton(frame: .zero)
        
}

extension MXRoomWallpaperPreviewPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        
        let vc = MXRoomWallpaperPreviewPage()
        if let color = params["color"] as? String {
            vc.color = color
        }
        return vc
    }
    
}
