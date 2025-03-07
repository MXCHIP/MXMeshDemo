
import Foundation
import UIKit

class MXNavigationController : UINavigationController {
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if self.viewControllers.count > 1 {
            self.topViewController?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.last?.classForCoder == viewController.classForCoder {
            return
        }
        super.pushViewController(viewController, animated: animated)
    }
}
