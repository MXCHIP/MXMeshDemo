
import Foundation

public class MXSceneConditionTimerInfo:NSObject, Codable {
    
    public var cron: String?
    public var timezoneid: String?
    public var once: Bool = false
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXSceneConditionTimerInfo else {
            return false
        }
        return (self.cron == obj.cron &&
                self.timezoneid == obj.timezoneid &&
                self.once == obj.once)
    }
    
    enum CodingKeys: String, CodingKey {
        case cron
        case timezoneid
        case once
    }
    
    override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cron = try container.decodeIfPresent(String.self, forKey: .cron)
        self.timezoneid = try container.decodeIfPresent(String.self, forKey: .timezoneid)
        self.once = (try? container.decode(Bool.self, forKey: .once)) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try? container.encode(self.cron, forKey: .cron)
        try? container.encode(self.timezoneid, forKey: .timezoneid)
        try? container.encode(self.once, forKey: .once)
    }
}

public class MXSceneEffectiveTimeModel: NSObject, Codable {
    
    public var wholeDay: Bool = true
    public var start: String = "00:00"
    public var end: String = "23:59"
    public var repeatMode:Int = 0  
    public var weeks = [Int]()
    
    
    
    private enum CodingKeys: String, CodingKey {
        case wholeDay = "isWholeDay"
        case start
        case end
        case repeatMode
        case weeks = "customWeeks"
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wholeDay = (try? container.decode(Bool.self, forKey: .wholeDay)) ?? false
        self.start = (try? container.decode(String.self, forKey: .start)) ?? "00:00"
        self.end = (try? container.decode(String.self, forKey: .end)) ?? "23:59"
        self.repeatMode = (try? container.decode(Int.self, forKey: .repeatMode)) ?? 0
        self.weeks = (try? container.decode([Int].self, forKey: .weeks)) ?? [Int]()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(wholeDay, forKey: .wholeDay)
        try? container.encode(start, forKey: .start)
        try? container.encode(end, forKey: .end)
        try? container.encode(repeatMode, forKey: .repeatMode)
        try? container.encode(weeks, forKey: .weeks)
    }
}
