
import Foundation

public class MXCategoryInfo: NSObject, Codable {
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
    public var category_id: Int = 0
    public var categorys : Array<MXCategoryInfo>?
    public var products : Array<MXProductInfo>?
    
    
    private enum CodingKeys: String, CodingKey {
        case nameLocalizable
        case name
        case category_id
        case categorys
        case products
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nameLocalizable = try container.decodeIfPresent([String: String].self, forKey: .nameLocalizable)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.category_id = (try? container.decode(Int.self, forKey: .category_id)) ?? 0
        self.categorys = try container.decodeIfPresent([MXCategoryInfo].self, forKey: .categorys)
        self.products = try container.decodeIfPresent([MXProductInfo].self, forKey: .products)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(nameLocalizable, forKey: .nameLocalizable)
        try container.encodeIfPresent(name, forKey: .name)
        try? container.encode(category_id, forKey: .category_id)
        try container.encodeIfPresent(categorys, forKey: .categorys)
        try container.encodeIfPresent(products, forKey: .products)
    }
}
