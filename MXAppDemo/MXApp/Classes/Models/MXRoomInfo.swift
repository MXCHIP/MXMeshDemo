
import Foundation

public class MXRoomInfo: NSObject, Codable {
    
    public var roomId: Int = 0
    public var name: String?
    public var isDefault: Bool = false 
    public var devices: [MXDeviceInfo] = [MXDeviceInfo]()
    public var bg_color: String?
    
    public var isSelected: Bool = false
    
    
    private enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case name
        case isDefault
        case devices
        case bg_color
    }
    
    public override init() {
        super.init()
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXRoomInfo else {
            return false
        }
        return (self.roomId == obj.roomId &&
                self.name == obj.name &&
                self.isDefault == obj.isDefault &&
                self.bg_color == obj.bg_color &&
                self.devices == obj.devices)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roomId = (try? container.decode(Int.self, forKey: .roomId)) ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.isDefault = (try? container.decode(Bool.self, forKey: .isDefault)) ?? false
        self.devices = (try? container.decode([MXDeviceInfo].self, forKey: .devices)) ?? [MXDeviceInfo]()
        self.bg_color = try container.decodeIfPresent(String.self, forKey: .bg_color)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(roomId, forKey: .roomId)
        try container.encodeIfPresent(name, forKey: .name)
        try? container.encode(isDefault, forKey: .isDefault)
        try? container.encode(devices, forKey: .devices)
        try container.encodeIfPresent(bg_color, forKey: .bg_color)
    }
}
