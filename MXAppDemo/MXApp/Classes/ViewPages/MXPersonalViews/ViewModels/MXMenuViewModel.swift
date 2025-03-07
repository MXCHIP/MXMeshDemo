
import Foundation

class MXMenuViewModel: NSObject {
    
    
    func showHomeManage() -> Void {
        
        let url = "https://com.mxchip.bta/page/home/list"
        
        MXURLRouter.open(url: url, params: nil)
    }
    
    
    func showAbout() -> Void {
        let url = "com.mxchip.bta/page/mine/about"
        MXURLRouter.open(url: url, params: nil)
    }
    
    
    func showSetting() -> Void {
        
        let url = "https://com.mxchip.bta/page/mine/setting"
        
        MXURLRouter.open(url: url, params: nil)
    }
    
    
    func numberOfSections() -> Int {
        return self.model.dataSources.count
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        let datas = self.model.dataSources[section]
        return datas.count
    }
    
    func cellIdentifierForRowAt(indexPath: IndexPath) -> String {
        let datas = self.model.dataSources[indexPath.section]
        let model = datas[indexPath.row]
        return model.identifier
    }
    
    func modelAtIndexPath(indexPath: IndexPath) -> ImageTitleContentImageCellModel {
        let datas = self.model.dataSources[indexPath.section]
        let model = datas[indexPath.row]
        return model
    }
    
    func didSelectRowAt(indexPath: IndexPath) -> Void {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                showHomeManage()
                break
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                showAbout()
                break
            case 1:
                showSetting()
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    
    let model = MXMenuModel()
    
    var mxUpdatingViewClosure: ((_ model: MXMenuModel) -> Void)!
    
    func observe(handler:@escaping (_ model: MXMenuModel) -> Void) -> Void {
        self.mxUpdatingViewClosure = handler
    }
    
    
    func mxUpdateViews() -> Void {
        
        if let closure = mxUpdatingViewClosure {
            closure(model)
        }
    }
    
}


