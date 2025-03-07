
import Foundation
import UIKit

extension UIFont {
    open class func iconFont(size: CGFloat) -> UIFont {
        return UIFont(name: "iconfont", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    open class func mxMediumFont(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    open class func mxBlodFont(size: CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
}
