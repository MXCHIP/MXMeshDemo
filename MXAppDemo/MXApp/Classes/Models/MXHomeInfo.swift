
import Foundation

public class MXHomeInfo: NSObject, Codable {
    
    public var homeId: Int = 0
    public var name: String?
    
    public var role: Int = 0 
    public var isCurrent: Bool = false 
    
    public var rooms: [MXRoomInfo] = [MXRoomInfo]()
    public var scenes: [MXSceneInfo] = [MXSceneInfo]()  
    public var autoScenes: [MXSceneInfo] = [MXSceneInfo]() 
    
    public var networkKey: String?
    public var appKey: String?
    public var meshAddress: UInt16?
    public var seqNumber: Int?
    
    public var deviceCount: Int {
        get {
            var count = 0
            self.rooms.forEach { (room:MXRoomInfo) in
                count += room.devices.count
            }
            return count
        }
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case homeId
        case name
        case rooms
        case scenes
        case autoScenes
        case networkKey
        case appKey
        case meshAddress
        case seqNumber
        case isCurrent
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.homeId = (try? container.decode(Int.self, forKey: .homeId)) ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.networkKey = try container.decodeIfPresent(String.self, forKey: .networkKey)
        self.appKey = try container.decodeIfPresent(String.self, forKey: .appKey)
        self.rooms = (try? container.decode([MXRoomInfo].self, forKey: .rooms)) ?? [MXRoomInfo]()
        self.scenes = (try? container.decode([MXSceneInfo].self, forKey: .scenes)) ?? [MXSceneInfo]()
        self.autoScenes = (try? container.decode([MXSceneInfo].self, forKey: .autoScenes)) ?? [MXSceneInfo]()
        self.meshAddress = try container.decodeIfPresent(UInt16.self, forKey: .meshAddress)
        self.seqNumber = try container.decodeIfPresent(Int.self, forKey: .seqNumber)
        self.isCurrent = (try? container.decode(Bool.self, forKey: .isCurrent)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(homeId, forKey: .homeId)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(networkKey, forKey: .networkKey)
        try container.encodeIfPresent(appKey, forKey: .appKey)
        try? container.encode(rooms, forKey: .rooms)
        try? container.encode(scenes, forKey: .scenes)
        try? container.encode(autoScenes, forKey: .autoScenes)
        try container.encodeIfPresent(meshAddress, forKey: .meshAddress)
        try container.encodeIfPresent(seqNumber, forKey: .seqNumber)
        try? container.encode(isCurrent, forKey: .isCurrent)
    }
}
