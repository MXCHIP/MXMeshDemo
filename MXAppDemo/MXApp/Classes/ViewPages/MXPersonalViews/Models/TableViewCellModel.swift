
import Foundation

class TableViewCellModel: NSObject {
    
    var icon = ""
    
    var title = ""
    
    var content = ""
    
    var identifier = ""
    
    init(title: String, content: String, identifier: String) {
        self.title = title
        self.content = content
        self.identifier = identifier
    }
    
}
