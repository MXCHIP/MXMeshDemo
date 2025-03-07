
import Foundation
import PinLayout
import UIKit
import Lottie

class MXToastHUD: NSObject {
    static public func show() {
        MXProgressHUD.shard.show()
    }
    
    static public func dismiss() {
        MXProgressHUD.shard.dismiss()
    }
    
    static public func showInfo(status: String?) {
        MXProgressHUD.shard.showInfo(status: status)
    }
    
    static public func showError(status: String?) {
        MXProgressHUD.shard.showInfo(status: status)
    }
}

class MXProgressHUD: UIView {
    public static var shard = MXProgressHUD(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
    public var mxAnimation : LottieAnimationView?
    let hudView: UIView = UIView(frame:.zero)
    let statusLabel: UILabel = UILabel(frame: .zero)
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.updateAnimation()
        self.mxAnimation?.isHidden = true
        
        self.hudView.backgroundColor = UIColor(with: "000000", lightModeAlpha: 1, darkModeHex: "FFFFFF", darkModeAlpha: 1)
        self.hudView.layer.masksToBounds = true
        self.hudView.layer.cornerRadius = 12
        self.addSubview(self.hudView)
        self.hudView.pin.width(224).height(324).center()
        
        self.statusLabel.font = UIFont.systemFont(ofSize: 12)
        self.statusLabel.textColor = UIColor(with: "FFFFFF", lightModeAlpha: 1, darkModeHex: "8C8C8C", darkModeAlpha: 1)
        self.statusLabel.backgroundColor = .clear
        self.statusLabel.textAlignment = .center;
        self.statusLabel.numberOfLines = 0;
        self.hudView.addSubview(self.statusLabel)
        self.statusLabel.pin.width(200).height(300).center()
        self.hudView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    public func updateAnimation() {
        let is_hide = self.mxAnimation?.isHidden ?? true
        self.mxAnimation?.stop()
        self.mxAnimation?.removeFromSuperview()
        var newName = "loading_Light"
        if #available(iOS 13, *), UITraitCollection.current.userInterfaceStyle == .dark {
            newName = "loading_Dark"
        }
        if MXAccountManager.shared.darkMode == 1 {
            newName = "loading_Light"
        } else if MXAccountManager.shared.darkMode == 2 {
            newName = "loading_Dark"
        }
        self.mxAnimation = LottieAnimationView(name: newName)
        self.mxAnimation?.contentMode = .scaleAspectFit
        self.mxAnimation?.isUserInteractionEnabled = false
        self.mxAnimation?.loopMode = .loop
        self.addSubview(self.mxAnimation!)
        self.mxAnimation?.pin.width(240).height(240).center()
        self.mxAnimation?.isHidden = is_hide
    }
    
    func show() {
        self.timer?.invalidate()
        self.hudView.isHidden = true
        self.mxAnimation?.isHidden = false
        self.mxAnimation?.play()
        if self.superview == nil {
            UIApplication.shared.delegate?.window??.addSubview(self)
        }
    }
    
    func dismiss() {
        self.mxAnimation?.stop()
        self.mxAnimation?.isHidden = true
        self.hudView.isHidden = true
        self.timer?.invalidate()
        self.removeFromSuperview()
    }
    
    func showInfo(status: String?) {
        guard let msg = status, msg.count > 0 else {
            self.dismiss()
            return
        }
        self.mxAnimation?.stop()
        self.mxAnimation?.isHidden = true
        self.hudView.isHidden = false
        self.statusLabel.text = msg
        self.statusLabel.pin.width(200).sizeToFit(.width)
        self.hudView.pin.wrapContent(padding: 12).center()
        if self.superview == nil {
            UIApplication.shared.delegate?.window??.addSubview(self)
        }
        self.delayDissmiss()
        
    }
    
    func delayDissmiss() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] (mxTimer:Timer) in
            self?.dismiss()
        })
        RunLoop.main.add(self.timer!, forMode: .common)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateAnimation()
    }
}
