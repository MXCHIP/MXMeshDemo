
import Foundation
import ZipArchive

class MXResourcesManager: NSObject {
    public static var shard = MXResourcesManager()
    
    override init() {
        super.init()
    }
    
    static func checkAppResources() {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let filePath = "\(path)/APPReources/\(appVersion)"
        let isExist = FileManager.default.fileExists(atPath: filePath)
        if !isExist {
            DispatchQueue.global(qos: .default).async {
                try? FileManager.default.removeItem(atPath:"\(path)/APPReources")
                let zip = ZipArchive()
                let zipPath = Bundle.main.path(forResource: "AppResources", ofType: "zip")
                if  zip.unzipOpenFile(zipPath, password: "mxchip123") {
                    let ret = zip.unzipFile(to: filePath, overWrite: true)
                    if !ret {
                        print("解压失败")
                    }
                    zip.unzipCloseFile()
                }
            }
        }
    }
    
    static func updateAppResources() {
        MXToastHUD.show()
        DispatchQueue.global(qos: .default).async {
            let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
            let path = pathes.first!
            let filePath = "\(path)/APPReources/\(appVersion)"
            let zipPath = "\(path)/AppResources.zip"
            try? FileManager.default.removeItem(atPath: zipPath)
            guard let url = URL(string: MXResourceUrl), let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    MXToastHUD.showInfo(status: localized(key: "更新失败"))
                }
                return
            }
            try? data.write(to: URL(fileURLWithPath: zipPath))
            let zip = ZipArchive()
            if  zip.unzipOpenFile(zipPath, password: "mxchip123") {
                let ret = zip.unzipFile(to: filePath, overWrite: true)
                if !ret {
                    print("解压缩失败")
                    DispatchQueue.main.async {
                        MXToastHUD.showInfo(status: localized(key: "更新失败"))
                    }
                }
                zip.unzipCloseFile()
                try? FileManager.default.removeItem(atPath: zipPath)
                DispatchQueue.main.async {
                    MXToastHUD.showInfo(status: localized(key: "更新成功"))
                    
                    MXProductManager.shard.loadProductFromResource()
                    
                    MXHomeManager.shard.loadMeshAttrTypeMap()
                }
            } else {
                DispatchQueue.main.async {
                    MXToastHUD.showInfo(status: localized(key: "更新失败"))
                }
            }
        }
    }
    
    static func loadLocalAgreementUrl(handler:@escaping (_ rootUrl: String?) -> Void) {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let filePath = "\(path)/APPAgreement/\(appVersion)"
        let agreementPath = "\(filePath)/MX_Agreement"
        let isFileExist = FileManager.default.fileExists(atPath: agreementPath)
        if isFileExist {
            handler(agreementPath)
        } else {
            DispatchQueue.global(qos: .default).async {
                try? FileManager.default.removeItem(atPath:"\(path)/APPAgreement")
                let zip = ZipArchive()
                let zipPath = Bundle.main.path(forResource: "MX_Agreement", ofType: "zip")
                if  zip.unzipOpenFile(zipPath) {
                    let ret = zip.unzipFile(to: filePath, overWrite: true)
                    if !ret {
                        print("解压失败")
                    }
                    zip.unzipCloseFile()
                    DispatchQueue.main.async {
                        handler( ret ? agreementPath : nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        handler(nil)
                    }
                }
            }
        }
    }
    
    static func loadLocalZipResourcesUrl(name: String, handler:@escaping (_ rootUrl: String?) -> Void) {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let filePath = "\(path)/APPReources/\(appVersion)/AppResources/PlanFiles/\(name)"
        let isFileExist = FileManager.default.fileExists(atPath: filePath)
        if isFileExist {
            handler(filePath)
        } else {
            DispatchQueue.global(qos: .default).async {
                try? FileManager.default.removeItem(atPath: "\(path)/APPReources")
                let zip = ZipArchive()
                let zipPath = Bundle.main.path(forResource: "AppResources", ofType: "zip")
                if  zip.unzipOpenFile(zipPath, password: "mxchip123") {
                    let ret = zip.unzipFile(to: "\(path)/APPReources/\(appVersion)", overWrite: true)
                    if !ret {
                        print("解压失败")
                    }
                    zip.unzipCloseFile()
                    DispatchQueue.main.async {
                        handler( ret ? filePath : nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        handler(nil)
                    }
                }
            }
        }
    }
    
    static func loadLocalConfigFileUrl(name: String, handler:@escaping (_ rootUrl: String?) -> Void) {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let finishPath = "\(path)/APPReources/\(appVersion)/AppResources/ConfigFiles/\(name).json"
        let isExist = FileManager.default.fileExists(atPath: finishPath)
        if isExist {
            handler(finishPath)
        } else {
            DispatchQueue.global(qos: .default).async {
                try? FileManager.default.removeItem(atPath:"\(path)/APPReources")
                let zip = ZipArchive()
                let zipPath = Bundle.main.path(forResource: "AppResources", ofType: "zip")
                if  zip.unzipOpenFile(zipPath, password: "mxchip123") {
                    let ret = zip.unzipFile(to: "\(path)/APPReources/\(appVersion)", overWrite: true)
                    if !ret {
                        print("解压失败")
                    }
                    zip.unzipCloseFile()
                    DispatchQueue.main.async {
                        handler( ret ? finishPath : nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        handler(nil)
                    }
                }
            }
        }
    }
    
    static func loadAgreementRootUrl() -> URL {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let finishPath = "\(path)/APPAgreement/\(appVersion)"
        let rootAppURL = URL(fileURLWithPath: finishPath, isDirectory: true)
        return rootAppURL
    }
    
    static func loadHtmlLocalRootUrl() -> URL {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let finishPath = "\(path)/APPReources/\(appVersion)/AppResources/PlanFiles"
        let rootAppURL = URL(fileURLWithPath: finishPath, isDirectory: true)
        return rootAppURL
    }
    
    static func getConfigFileUrl(name: String) -> String? {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let finishPath = "\(path)/APPReources/\(appVersion)/AppResources/ConfigFiles/\(name).json"
        let isExist = FileManager.default.fileExists(atPath: finishPath)
        if isExist {
            return finishPath
        } else {
            MXResourcesManager.checkAppResources()
        }
        return nil
    }
    
    static func cleanCache() {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let sourcePath = "\(path)/APPReources"
        try? FileManager.default.removeItem(atPath: sourcePath)
    }
    
}
