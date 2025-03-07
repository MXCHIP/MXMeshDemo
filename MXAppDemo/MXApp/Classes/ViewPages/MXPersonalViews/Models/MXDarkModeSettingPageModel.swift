
import Foundation

class MXDarkModeSettingPageModel: NSObject {
        
    
    
    
    
    
    var darkMode: Int {
        set {
            if darkModeFirstValue == nil {
                darkModeFirstValue = newValue
            }
            MXAccountManager.shared.darkMode = newValue
            ifUpdated = newValue != darkModeFirstValue
        }
        get {
            if darkModeFirstValue == nil {
                darkModeFirstValue = MXAccountManager.shared.darkMode
            }
            return MXAccountManager.shared.darkMode
        }
    }
    
    var darkModeFirstValue: Int!
    
    
    var ifUpdated = false
    
}
