
import Foundation

class MXProductManager: NSObject {
    public static var shard = MXProductManager()
    public var categoryList = Array<MXCategoryInfo>()
    
    override init() {
        super.init()
//        self.loadMXProductData()
//        if self.categoryList.count <= 0  {
            self.loadProductFromResource()
//        }
    }
    
    
    public func loadProductFromResource() {
        MXResourcesManager.loadLocalConfigFileUrl(name: "MXProductList") { (filePath:String?) in
            if let path = filePath {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url),
                   let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]] {
                    self.updateMXProductData(params: json)
                    if let list = MXCategoryInfo.mx_Decode(json) {
                        self.categoryList = list
                    }
                }
            }
        }
    }
    
    public func loadGroupProductList() -> [MXProductInfo] {
        var list = [MXProductInfo]()
        for category1 in self.categoryList {
            if let list1 = category1.categorys  {
                for category2 in list1 {
                    if let list2 = category2.products {
                        for info in list2 {
                            if info.category_id > 100100, info.category_id < 100107 { 
                                if info.product_key == "0b3fbc2e" || info.product_key == "022c4d88" || info.product_key == "a71093dc" {
                                    if list.first(where: {$0.category_id == info.category_id}) == nil {
                                        list.append(info)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return list
    }
    
    public func getProductSuperCategoryId(pk: String?) -> Int {
        guard let productKey = pk else {
            return 0
        }
        for category1 in self.categoryList {
            if let list1 = category1.categorys  {
                for category2 in list1 {
                    if let list2 = category2.products {
                        for info in list2 {
                            if info.product_key == productKey {
                                return category2.category_id
                            }
                        }
                    }
                }
            }
        }
        return 0
    }
    
    public func getProductInfo(pk: String?) -> MXProductInfo? {
        guard let productKey = pk else {
            return nil
        }
        for category1 in self.categoryList {
            if let list1 = category1.categorys  {
                for category2 in list1 {
                    if let list2 = category2.products {
                        for info in list2 {
                            if info.product_key == productKey {
                                return info
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    public func getProductInfo(pid: String?) -> MXProductInfo? {
        guard let productId = pid else {
            return nil
        }
        var newList = [MXProductInfo]()
        for category1 in self.categoryList {
            if let list1 = category1.categorys  {
                for category2 in list1 {
                    if let list2 = category2.products {
                        for info in list2 {
                            if let productIdStr = info.product_id,
                                productIdStr.count > 0,
                                Int(productIdStr) == Int(productId, radix: 16) {
                                if info.cloud_platform == 2 { 
                                    return info
                                } else {
                                    newList.append(info)
                                }
                            } else if info.cloud_platform == 2,
                                        info.product_key?.lowercased() == productId.lowercased() {
                                return info
                            }
                        }
                    }
                }
            }
        }
        return newList.first
    }
    
    
    func loadMXProductData() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXProductData.plist")
        if let data = try? Data(contentsOf: url) {
            if let params = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String : Any]],
                let list = MXCategoryInfo.mx_Decode(params) {
                self.categoryList = list
            }
        }
    }
    
    public func updateMXProductData(params: [[String : Any]]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXProductData.plist")
        let list: NSArray = params as NSArray
        list.write(to: url, atomically: true)
    }
    
}
