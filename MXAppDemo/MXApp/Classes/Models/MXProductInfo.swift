
import Foundation

public class MXProductInfo: NSObject, Codable {
    public var product_id: String?
    public var product_key : String?   
    public var nameLocalizable:[String: String]?
    public var _name: String?
    public var name: String? {
        get {
            if let language = (MXAccountManager.shared.language ?? Locale.preferredLanguages.first),
               language.contains("zh-Hans"),
               let names = self.nameLocalizable,
               let newName = names["zh-Hans"]  {
                return newName
            }
            return _name
        }
        set {
            _name = newValue
        }
    }
    public var image: String?   
    public var category_id: Int = 0
    
    public var link_type_id: Int = 0  
    public var share_type: Int = 0  
    public var sharing_mode: Int = 0  
    public var heartbeat_interval: Int = 120 
    
    public var cloud_platform: Int = 0  
    public var node_type_v2: String?  
    public var protocol_type_v2: String? 
    public var not_receive_message: Bool = false  
    public var secret: String?
    public var h5_plan_name: String?  
    public var plan_url: String?   
    public var isSupportTracing: Bool = false  
    
    public var properties : [MXPropertyInfo]? {
        get {
            if let path = MXResourcesManager.getConfigFileUrl(name: "PropertiesList") {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url),
                   let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]] {
                    if let params = json.first(where: { (dict:[String : Any]) in
                        if let categoryId = dict["category_id"] as? Int, categoryId == self.category_id {
                            return true
                        }
                        return false
                    }), let pParams = params["properties"] as? [[String: Any]],
                       let pList = MXPropertyInfo.mx_Decode(pParams) {
                        return pList
                    }
                }
            }
            return nil
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case product_id = "feiyan_product_id"
        case nameLocalizable
        case name
        case product_key
        case image
        case cloud_platform
        case category_id
        case link_type_id
        case share_type
        case sharing_mode
        case heartbeat_interval
        case node_type_v2
        case protocol_type_v2
        case not_receive_message
        case secret
        case h5_plan_name
        case plan_url
        case isSupportTracing
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.product_id = try container.decodeIfPresent(String.self, forKey: .product_id)
        self.nameLocalizable = try container.decodeIfPresent([String: String].self, forKey: .nameLocalizable)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.product_key = try container.decodeIfPresent(String.self, forKey: .product_key)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.cloud_platform = (try? container.decode(Int.self, forKey: .cloud_platform)) ?? 0
        self.category_id = (try? container.decode(Int.self, forKey: .category_id)) ?? 0
        self.link_type_id = (try? container.decode(Int.self, forKey: .link_type_id)) ?? 0
        self.share_type = (try? container.decode(Int.self, forKey: .share_type)) ?? 0
        self.sharing_mode = (try? container.decode(Int.self, forKey: .sharing_mode)) ?? 0
        self.heartbeat_interval = (try? container.decode(Int.self, forKey: .heartbeat_interval)) ?? 120
        self.node_type_v2 = try container.decodeIfPresent(String.self, forKey: .node_type_v2)
        self.protocol_type_v2 = try container.decodeIfPresent(String.self, forKey: .protocol_type_v2)
        self.not_receive_message = (try? container.decode(Bool.self, forKey: .not_receive_message)) ?? false
        self.secret = try container.decodeIfPresent(String.self, forKey: .secret)
        self.h5_plan_name = try container.decodeIfPresent(String.self, forKey: .h5_plan_name)
        self.plan_url = try container.decodeIfPresent(String.self, forKey: .plan_url)
        self.isSupportTracing = (try? container.decode(Bool.self, forKey: .isSupportTracing)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(product_id, forKey: .product_id)
        try container.encodeIfPresent(nameLocalizable, forKey: .nameLocalizable)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(product_key, forKey: .product_key)
        try container.encodeIfPresent(image, forKey: .image)
        try? container.encode(cloud_platform, forKey: .cloud_platform)
        try? container.encode(category_id, forKey: .category_id)
        try? container.encode(link_type_id, forKey: .link_type_id)
        try? container.encode(share_type, forKey: .share_type)
        try? container.encode(sharing_mode, forKey: .sharing_mode)
        try? container.encode(heartbeat_interval, forKey: .heartbeat_interval)
        try container.encodeIfPresent(node_type_v2, forKey: .node_type_v2)
        try container.encodeIfPresent(protocol_type_v2, forKey: .protocol_type_v2)
        try? container.encode(not_receive_message, forKey: .not_receive_message)
        try container.encodeIfPresent(secret, forKey: .secret)
        try container.encodeIfPresent(h5_plan_name, forKey: .h5_plan_name)
        try container.encodeIfPresent(plan_url, forKey: .plan_url)
        try? container.encode(isSupportTracing, forKey: .isSupportTracing)
    }
}
