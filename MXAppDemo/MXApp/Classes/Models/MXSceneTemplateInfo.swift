
import Foundation

public class MXSceneTemplateInfo: NSObject, Codable {
    
    public var id: Int = 0
    public var name: String?
    public var propertys : [MXPropertyInfo]?
    
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case propertys
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(Int.self, forKey: .id))  ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.propertys = try container.decodeIfPresent([MXPropertyInfo].self, forKey: .propertys)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(propertys, forKey: .propertys)
    }
    
    static func loadLightProperies() -> [MXPropertyInfo] {
        if let path = MXResourcesManager.getConfigFileUrl(name: "PropertiesList") {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url),
               let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]] {
                if let params = json.first(where: { (dict:[String : Any]) in
                    if let categoryId = dict["category_id"] as? Int, categoryId == 100104 {
                        return true
                    }
                    return false
                }), let pParams = params["properties"] as? [[String: Any]],
                   let pList = MXPropertyInfo.mx_Decode(pParams) {
                    return pList
                }
            }
        }
        return [MXPropertyInfo]()
    }
    
    static public func checkPropertyIsUpdate(list1:[MXPropertyInfo], list2:[MXPropertyInfo]) -> Bool {
        for item in list1 {
            if let item2 = list2.first(where: {$0.identifier == item.identifier}) {
                if (item2.value == nil && item.value != nil) || (item2.value != nil && item.value == nil) {
                    return true
                }
            } else {
                return true
            }
        }
        for item in list2 {
            if let item1 = list1.first(where: {$0.identifier == item.identifier}) {
                if (item1.value == nil && item.value != nil) || (item1.value != nil && item.value == nil) {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }
}
