
import Foundation

public class MXHouseStatusInfo: NSObject, Codable {
    
    public var type: Int = 0  
    public var iotId: String?
    public var image: String?
    public var roomId: Int?
    public var roomName: String?
    
    public var alarm_id: Int?
    
    public var alterName: String?
    public var deviceName: String?
    public var online: Bool?  
    public var Switch: Int?  
    
    public var count: Int?  
    
    
    private enum CodingKeys: String, CodingKey {
        case type
        case iotId = "iotid"
        case image
        case roomId = "room_id"
        case roomName = "room_name"
        case alterName = "alter_name"
        case deviceName = "device_name"
        case online
        case Switch
        case count
        case alarm_id
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decode(Int.self, forKey: .type)) ?? 0
        self.iotId = try container.decodeIfPresent(String.self, forKey: .iotId)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.roomId = try container.decodeIfPresent(Int.self, forKey: .roomId)
        self.roomName = try container.decodeIfPresent(String.self, forKey: .roomName)
        self.alterName = try container.decodeIfPresent(String.self, forKey: .alterName)
        self.deviceName = try container.decodeIfPresent(String.self, forKey: .deviceName)
        self.online = try container.decodeIfPresent(Bool.self, forKey: .online)
        self.Switch = try container.decodeIfPresent(Int.self, forKey: .Switch)
        self.count = try container.decodeIfPresent(Int.self, forKey: .count)
        self.alarm_id = try container.decodeIfPresent(Int.self, forKey: .alarm_id)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(type, forKey: .type)
        try container.encodeIfPresent(iotId, forKey: .iotId)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(roomId, forKey: .roomId)
        try container.encodeIfPresent(roomName, forKey: .roomName)
        try container.encodeIfPresent(alterName, forKey: .alterName)
        try container.encodeIfPresent(deviceName, forKey: .deviceName)
        try container.encodeIfPresent(online, forKey: .online)
        try container.encodeIfPresent(Switch, forKey: .Switch)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(alarm_id, forKey: .alarm_id)
    }
}
