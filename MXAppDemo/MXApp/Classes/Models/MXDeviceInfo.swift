
import Foundation
import MeshSDK

public class MXDeviceInfo: NSObject, Codable {
    public var objType: Int = 0  
    public var objId: String?
    public var name: String?
    public var image: String?
    public var productKey: String?
    public var category_id : Int?
    public var createTime: Int = 0  
    
    public var roomId: Int?
    public var roomName: String?
    
    public var properties : [MXPropertyInfo]?
    
    public var meshInfo: MXMeshInfo?
    
    public var deviceName: String?  
    public var signType: Int?  
    public var sign: String?  
    
    public var firmware_version : String?  
    public var bindTime: Int = 0  
    public var isOnline: Bool = false  
    public var isShare : Bool = false  
    
    public var isFavorite: Bool = true
    
    public var subDevices : [MXDeviceInfo]? 
    public var isMaster: Int = 0  
    
    
    public var status: Int = 0 
    public var isValid: Bool = true 
    
    
    public var writtenStatus: Int = 0  
    public var isIntoGroup: Bool = true  
    public var isSelected: Bool = false
    
    public var productInfo: MXProductInfo? {
        get {
            return MXProductManager.shard.getProductInfo(pk: self.productKey)
        }
    }
    
    public var isSubDevice: Bool = false
    public var mac: String?
    //网关独有
    public var ip: String?  //网关IP地址
    public var hasPwd: String?  //has密码
    
    public var showName: String {
        get {
            if let nameStr = self.name {
                return nameStr
            } else if let nameStr = self.productInfo?.name {
                return nameStr
            }  else if let nameStr = self.mac {
                return nameStr.replacingOccurrences(of: ":", with: "").uppercased()
            }
            return ""
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case objType
        case objId
        case name
        case image
        case productKey = "product_key"
        case category_id
        case createTime = "create_time"
        case meshInfo
        case deviceName = "device_name"
        case signType = "sign_type"
        case sign
        case firmware_version
        case bindTime = "bind_time"
        case isOnline = "is_online"
        case isShare = "is_share"
        case subDevices
        case isMaster = "is_master"
        case status
        case isValid = "is_valid"
        case properties
        case roomId = "room_id"
        case roomName = "room_name"
        case isFavorite = "is_favorite"
        case mac
        case ip
        case hasPwd
    }
    
    
    public func isSameFrom(_ device:MXDeviceInfo?) -> Bool {
        guard let device = device else {
             return false
        }

        if self.objType == 0 {
            if let uuidStr = self.meshInfo?.uuid, let device_uuid = device.meshInfo?.uuid, (uuidStr == device_uuid || MeshSDK.sharedInstance.getDeviceMacAddress(uuid: uuidStr) == MeshSDK.sharedInstance.getDeviceMacAddress(uuid: device_uuid)) {
                return true
            } else if let dn = self.deviceName, dn == device.deviceName, self.productKey == device.productKey {
                return true
            }
        } else if self.objType == 1, self.meshInfo?.meshAddress == device.meshInfo?.meshAddress {
            return true
        }
        return false
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXDeviceInfo else {
            return false
        }
        return (self.objType == obj.objType &&
                self.objId == obj.objId &&
                self.name == obj.name &&
                self.image == obj.image &&
                self.deviceName == obj.deviceName &&
                self.productKey == obj.productKey &&
                self.category_id == obj.category_id &&
                self.isValid == obj.isValid &&
                self.status == obj.status &&
                self.properties == obj.properties)
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.objType = (try? container.decode(Int.self, forKey: .objType)) ?? 0
        self.objId = try container.decodeIfPresent(String.self, forKey: .objId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        let pk = try container.decodeIfPresent(String.self, forKey: .productKey)
        self.productKey = pk
        let cid = try container.decodeIfPresent(Int.self, forKey: .category_id)
        self.category_id = cid
        self.createTime = (try? container.decode(Int.self, forKey: .createTime)) ?? 0
        
        self.properties = try container.decodeIfPresent([MXPropertyInfo].self, forKey: .properties)
        self.meshInfo = try container.decodeIfPresent(MXMeshInfo.self, forKey: .meshInfo)
        
        self.deviceName = try container.decodeIfPresent(String.self, forKey: .deviceName)
        self.signType = try container.decodeIfPresent(Int.self, forKey: .signType)
        self.sign = try container.decodeIfPresent(String.self, forKey: .sign)
        
        self.firmware_version = try container.decodeIfPresent(String.self, forKey: .firmware_version)
        self.bindTime = (try? container.decode(Int.self, forKey: .bindTime)) ?? 0
        self.isShare = (try? container.decode(Bool.self, forKey: .isShare)) ?? false
        self.isOnline = (try? container.decode(Bool.self, forKey: .isOnline)) ?? false
        
        self.subDevices = try container.decodeIfPresent([MXDeviceInfo].self, forKey: .subDevices)
        self.isMaster = (try? container.decode(Int.self, forKey: .isMaster)) ?? 0
        
        self.status = (try? container.decode(Int.self, forKey: .status)) ?? 0
        self.isValid = (try? container.decode(Bool.self, forKey: .isValid)) ?? true
        
        self.roomId = try container.decodeIfPresent(Int.self, forKey: .roomId)
        self.roomName = try container.decodeIfPresent(String.self, forKey: .roomName)
        
        self.isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? true
        
        self.mac = try container.decodeIfPresent(String.self, forKey: .mac)
        self.ip = try container.decodeIfPresent(String.self, forKey: .ip)
        self.hasPwd = try container.decodeIfPresent(String.self, forKey: .hasPwd)
        
        var category_Id = cid ?? 0
        if let product_key = pk {
            let pInfo = MXProductManager.shard.getProductInfo(pk: product_key)
            category_Id = pInfo?.category_id ?? 0
        }
        
        if self.properties == nil {
            if let path = MXResourcesManager.getConfigFileUrl(name: "PropertiesList") {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url),
                   let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]] {
                    if let params = json.first(where: { (dict:[String : Any]) in
                        if let categoryId = dict["category_id"] as? Int, categoryId == category_Id {
                            return true
                        }
                        return false
                    }), let pParams = params["properties"] as? [[String: Any]],
                       let pList = MXPropertyInfo.mx_Decode(pParams) {
                        self.properties = pList
                    }
                }
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(objType, forKey: .objType)
        try container.encodeIfPresent(objId, forKey: .objId)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(productKey, forKey: .productKey)
        try container.encodeIfPresent(category_id, forKey: .category_id)
        try container.encodeIfPresent(createTime, forKey: .createTime)
        
        try container.encodeIfPresent(properties, forKey: .properties)
        try container.encodeIfPresent(meshInfo, forKey: .meshInfo)
        
        try container.encodeIfPresent(deviceName, forKey: .deviceName)
        try container.encodeIfPresent(signType, forKey: .signType)
        try container.encodeIfPresent(sign, forKey: .sign)
        
        try container.encodeIfPresent(firmware_version, forKey: .firmware_version)
        try container.encodeIfPresent(bindTime, forKey: .bindTime)
        try? container.encode(isShare, forKey: .isShare)
        try? container.encode(isOnline, forKey: .isOnline)
        
        try container.encodeIfPresent(subDevices, forKey: .subDevices)
        try? container.encode(isMaster, forKey: .isMaster)
        
        try container.encodeIfPresent(status, forKey: .status)
        try? container.encode(isValid, forKey: .isValid)
        
        try container.encodeIfPresent(roomId, forKey: .roomId)
        try container.encodeIfPresent(roomName, forKey: .roomName)
        
        try? container.encode(isFavorite, forKey: .isFavorite)
        
        try container.encodeIfPresent(mac, forKey: .mac)
        try container.encodeIfPresent(ip, forKey: .ip)
        try container.encodeIfPresent(hasPwd, forKey: .hasPwd)
    }
}

public class MXMeshInfo: NSObject, Codable {
    
    public var meshAddress: UInt16?
    public var deviceKey: String?
    public var uuid: String?
    
    
    enum CodingKeys: String, CodingKey {
        case meshAddress
        case deviceKey
        case uuid
    }
    
    public override init() {
        super.init()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXMeshInfo else {
            return false
        }
        return (self.meshAddress == obj.meshAddress &&
                self.deviceKey == obj.deviceKey &&
                self.uuid == obj.uuid)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.meshAddress = try container.decodeIfPresent(UInt16.self, forKey: .meshAddress)
        self.deviceKey = try container.decodeIfPresent(String.self, forKey: .deviceKey)
        self.uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(meshAddress, forKey: .meshAddress)
        try container.encodeIfPresent(deviceKey, forKey: .deviceKey)
        try container.encodeIfPresent(uuid, forKey: .uuid)
    }
}
