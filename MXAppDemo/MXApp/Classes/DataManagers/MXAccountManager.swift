
import Foundation

class MXAccountManager: NSObject {
    public static var shared = MXAccountManager()
    
    override init() {
        super.init()
    }
    
    public var token: String? {
        get {
            return  UserDefaults.standard.string(forKey: "MXToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MXToken")
        }
    }
    
    
    var ifAgreeProtocols: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "USER_IF_AGREE_PROTOCOLS")
        }
        get {
            return UserDefaults.standard.bool(forKey: "USER_IF_AGREE_PROTOCOLS")
        }
    }
    
    var language : String? {
        get {
            return  UserDefaults.standard.string(forKey: "MXAppCurrentLanguage")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MXAppCurrentLanguage")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MXNotificationAppLanguageChange"), object: nil)
        }
    }
    
    
    
    
    
    var darkMode: Int {
        get {
            return  UserDefaults.standard.integer(forKey: "MXAppCurrentThemeMode")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MXAppCurrentThemeMode")
        }
    }
    
}
