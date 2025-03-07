
import Foundation

class MXMineSettingPageModel: NSObject {
    
    var darkMode: Int {
        get {
            return MXAccountManager.shared.darkMode
        }
    }
    
    var dataSources = [[ImageTitleContentImageCellModel]]()
    
    
    override init() {
        super.init()
    }
    
}
