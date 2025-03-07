
import Foundation

class MXMenuModel: NSObject {
    
    var darkMode: Int {
        set {
            MXAccountManager.shared.darkMode = newValue
        }
        get {
            return MXAccountManager.shared.darkMode
        }
    }
    
    var newOTA = false
    
    var dataSources = [[ImageTitleContentImageCellModel(leftImage: "\u{e707}",
                                                        title: localized(key: "家庭管理"),
                                                        content: localized(key: ""),
                                                        rightImage: nil,
                                                        identifier: "ImageTitleContentImageCell",
                                                        go: true)],
                       [
                       ImageTitleContentImageCellModel(leftImage: "\u{e70c}",
                                                        title: localized(key: "关于我们"),
                                                        content: localized(key: ""),
                                                        rightImage: nil,
                                                        identifier: "ImageTitleContentImageCell",
                                                        go: true)],
//                       ImageTitleContentImageCellModel(leftImage: "\u{e735}",
//                                                        title: localized(key: "Personal_设置"),
//                                                        content: localized(key: ""),
//                                                        rightImage: nil,
//                                                        identifier: "ImageTitleContentImageCell",
//                                                        go: true)],
    ]
    
}
