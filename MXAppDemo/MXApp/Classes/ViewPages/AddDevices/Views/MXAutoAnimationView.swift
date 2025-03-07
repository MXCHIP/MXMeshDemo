
import Foundation

class MXAutoAnimationView: UIView {
    private let radarAnimation = "radarAnimation"
    private var animationLayer: CALayer?
    private var animationGroup: CAAnimationGroup?
    private var imageview : UIImageView!    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        imageview = UIImageView(frame: CGRect.zero)
        self.addSubview(imageview) 
        imageview.pin.width(60).height(60).bottom(-30).hCenter()
        let imagev = makeRadarAnimation(showRect: imageview.frame)
        self.layer.insertSublayer(imagev, below: imageview.layer) 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func makeRadarAnimation(showRect: CGRect) -> CALayer {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = showRect
        
        shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: showRect.width, height: showRect.height)).cgPath
        shapeLayer.fillColor = UIColor(hex: AppUIConfiguration.MainColor.C0.toHexString, alpha: 0.2).cgColor    
        shapeLayer.opacity = 0.0    
        animationLayer = shapeLayer     
        
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = NSNumber(floatLiteral: 1.0)  
        opacityAnimation.toValue = NSNumber(floatLiteral: 0)      
        
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.fromValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0))      
        scaleAnimation.toValue = NSValue.init(caTransform3D: CATransform3DScale(CATransform3DIdentity, 12.0, 12.0, 0))      
        
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [opacityAnimation, scaleAnimation]  
        animationGroup.duration = 5.0       
        animationGroup.repeatCount = HUGE   
        animationGroup.autoreverses = false
        
        self.animationGroup = animationGroup    
        shapeLayer.add(animationGroup, forKey: radarAnimation)  
        
        
        let replicator = CAReplicatorLayer()
        replicator.frame = shapeLayer.bounds
        replicator.instanceCount = 6
        replicator.instanceDelay = 1.0
        replicator.addSublayer(shapeLayer)
        
        return replicator
    }
}
