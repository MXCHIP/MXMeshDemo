
import Foundation

class MXMenuViewController: UIViewController {
    
    func showMenu() -> Void {
        menu.show()
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageChange), name: Notification.Name("MXNotificationAppLanguageChange"), object: nil)
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.view.addSubview(menu)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    @objc func appLanguageChange() {
        
        if self.menu.superview != nil {
            self.menu.removeFromSuperview()
        }
        self.menu = MXMenuView()
        self.view.addSubview(menu)
        self.showMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    var menu = MXMenuView()
    
}
