
import Foundation
import UIKit
import Lottie
import PinLayout

class MXCustomButton: UIButton {
    
    public var mxAnimationName: String?
    public var mxAnimation : LottieAnimationView?
    public var mxNormalImage: UIImage?
    public var mxAnimationOffSetX: CGFloat = 0
    public var mxAnimationOffSetY: CGFloat = 0
    
    lazy var titleLB: UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H7)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        _titleLB.textAlignment = .center
        return _titleLB
    }()
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.titleLB.textColor = AppUIConfiguration.NeutralColor.title
                self.mxAnimation?.play { (isFinished) in
                    
                }
            } else {
                self.titleLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
                self.mxAnimation?.stop()
            }
        }
    }
    
    public func updateAnimation() {
        if var newName = self.mxAnimationName {
            self.mxAnimation?.stop()
            self.mxAnimation?.removeFromSuperview()
            if #available(iOS 13, *), UITraitCollection.current.userInterfaceStyle == .dark {
                newName = newName + "-dark"
            }
            self.mxAnimation = LottieAnimationView(name: newName)
            self.mxAnimation?.contentMode = .scaleAspectFit
            self.mxAnimation?.isUserInteractionEnabled = false
            self.addSubview(self.mxAnimation!)
            self.mxAnimation?.pin.width(200/3.0).height(200/3.0).hCenter(self.mxAnimationOffSetX).vCenter(mxAnimationOffSetY)
            self.isSelected = self.isSelected
        }
    }
    
    init(frame: CGRect, animationName: String?) {
        super.init(frame: frame)
        if let name = animationName {
            self.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H7)
            self.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
            self.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .selected)
            
            self.addSubview(self.titleLB)
            self.titleLB.pin.left().right().height(14).bottom(4)
            
            self.mxAnimationName = name
            self.updateAnimation()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.left().right().height(14).bottom(4)
        self.mxAnimation?.pin.width(200/3.0).height(200/3.0).hCenter(self.mxAnimationOffSetX).vCenter(mxAnimationOffSetY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("init(coder:) 方法没有实现")
    }
    
    
    
    
    func setTabBarItem(tabBarItem: UITabBarItem) {
        self.mxNormalImage = tabBarItem.image
        self.titleLB.text = tabBarItem.title
    }
}

protocol MXCustomTabBarViewDelegate {

func mxCustomTabBarView(customTabBarView: MXTabbarView, _ didSelectedIndex: Int)

}

class MXTabbarView: UIView {
    
    var delegate:MXCustomTabBarViewDelegate? 
    var itemArray:[MXCustomButton] = [] 
   
    init(frame: CGRect,tabBarItems:[UITabBarItem], animations: [String]) {
        super.init(frame: frame)
        self.backgroundColor = AppUIConfiguration.backgroundColor.level2.FFFFFF
        let screenW = UIScreen.main.bounds.size.width
        let itemWidth = screenW / CGFloat(tabBarItems.count)
        for i in 0..<tabBarItems.count{
            var ani_name : String? = nil
            if animations.count > i {
                ani_name = animations[i]
            }
            let barItem = tabBarItems[i]
            let itemFrame = CGRect(x: itemWidth * CGFloat(i) , y: 0, width: itemWidth, height: frame.size.height)
            
            let itemView = MXCustomButton(frame: itemFrame, animationName: ani_name)
            itemView.setTabBarItem(tabBarItem: barItem)
            self.addSubview(itemView)
            self.itemArray.append(itemView)
            
            itemView.tag = i
            itemView.addTarget(self, action:#selector(self.didItemClick(item:))  , for: .touchUpInside)
            
            if i == 0 {
                itemView.mxAnimationOffSetY = -7
                self.didItemClick(item: itemView)
            } else if i == 1 {
                itemView.mxAnimationOffSetY = -7
            } else if i == 2 {
                itemView.mxAnimationOffSetY = -6
            }
        }
    }
    
    func updateItemAnimation() {
        self.itemArray.forEach { (view:MXCustomButton) in
            view.updateAnimation()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateItemAnimation()
    }
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    
    @objc func didItemClick(item:MXCustomButton){
        for i in 0..<itemArray.count{
            let tempItem = itemArray[i]
            if i == item.tag{
                tempItem.isSelected = true
            }else{
                tempItem.isSelected = false
            }
        }
        
        self.delegate?.mxCustomTabBarView(customTabBarView: self, item.tag)
    }
}
