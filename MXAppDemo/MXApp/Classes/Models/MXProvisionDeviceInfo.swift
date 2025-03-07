
import Foundation
import CoreBluetooth

public class MXProvisionDeviceInfo: MXDeviceInfo {
    
    public var bleName: String?
    public var uuid: String?
    
    public var device: UnprovisionedDevice?
    public var peripheral: CBPeripheral?
    
    public var provisionStatus : Int = 0 
    public var provisionStepList = Array<MXProvisionStepInfo>()
    public var isOpen: Bool = false 
    
    public var timeStamp : TimeInterval = Date().timeIntervalSince1970
    var provisionError: String?
    
    public override init() {
        super.init()
    }
    
    convenience init(params:[String: Any]) {
        self.init()
        self.bleName = params["name"] as? String
        self.device = params["device"] as? UnprovisionedDevice
        self.uuid = params["uuid"] as? String
        self.peripheral = params["peripheral"] as? CBPeripheral
        self.mac = params["mac"] as? String
        self.deviceName = params["deviceName"] as? String
        if let pId = params["productId"] as? String, let pInfo = MXProductManager.shard.getProductInfo(pid: pId) {
            self.productKey = pInfo.product_key
        } else if let pk = params["productKey"] as? String {
            self.productKey = pk
        }
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

public class MXProvisionStepInfo: NSObject, Codable {
    
    public var name: String?
    public var status: Int = 0  
    
    
    private enum CodingKeys: String, CodingKey {
        case name
        case status
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.status = (try? container.decode(Int.self, forKey: .status)) ?? 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try? container.encode(status, forKey: .status)
    }
}
