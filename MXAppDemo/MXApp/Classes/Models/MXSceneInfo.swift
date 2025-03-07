
import Foundation
import UIKit

public class MXSceneInfo: NSObject, Codable {
    
    public var sceneId: Int = 0
    public var vid: Int = 0
    public var name: String?
    public var des: String?
    public var iconImage: String?
    public var iconColor: String?
    
    public var type: String = "one_click"  
    public var conditions:MXSceneConditionItem = MXSceneConditionItem()  
    public var attachments:MXSceneConditionItem = MXSceneConditionItem()  
    public var actions:[MXSceneTACItem] = [MXSceneTACItem]()  
    
    public var isFavorite: Bool = false
    public var enable: Bool = false  
    public var isValid: Bool = true 
    
    public var isSelected: Bool = false

    var isInvalid: Bool {
        get {
            if let list = self.conditions.items {
                for actionInfo in list {
                    if let obj = actionInfo.params as? MXDeviceInfo, obj.objType == 0, !obj.isValid { 
                        return true
                    }
                }
            }
            for actionInfo in self.actions {
                if let obj = actionInfo.params as? MXDeviceInfo { 
                    if obj.objType == 0, obj.isValid {
                        return false
                    } else if obj.objType == 1, obj.isValid {
                        return false
                    }
                } else if let obj = actionInfo.params as? MXSceneInfo, obj.isValid { 
                    return false
                }
            }
            return true
        }
    }
    
    var isUnsync: Bool {
        get {
            for actionInfo in self.actions {
                if let obj = actionInfo.params as? MXDeviceInfo { 
                    if obj.objType == 0, !obj.isValid {
                        return true
                    } else if obj.objType == 1, let devices = obj.subDevices { 
                        for device in devices {
                            if !device.isValid {
                                return true
                            }
                        }
                    }
                } else if let obj = actionInfo.params as? MXSceneInfo, !obj.isValid { 
                    return true
                }
            }
            
            if self.type != "cloud_auto" { 
                for actionInfo in self.actions {
                    if let obj = actionInfo.params as? MXDeviceInfo { 
                        if obj.objType == 0 {  
                            if obj.status != 1 {
                                return true
                            }
                        } else if obj.objType == 1, let devices = obj.subDevices {
                            for device in devices {
                                if device.status != 1 {
                                    return true
                                }
                            }
                        }
                    }
                }
            }
            return false
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let scene = object as? MXSceneInfo else {
            return false
        }
        return (self.sceneId == scene.sceneId &&
                self.vid == scene.vid &&
                self.name == scene.name &&
                self.des == scene.des &&
                self.iconImage == scene.iconImage &&
                self.iconColor == scene.iconColor &&
                self.type == scene.type &&
                self.isFavorite == scene.isFavorite &&
                self.enable == scene.enable &&
                self.conditions == scene.conditions &&
                self.attachments == scene.attachments &&
                self.actions == scene.actions)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case sceneId = "id"
        case vid
        case name
        case des
        case iconImage = "icon_image"
        case iconColor = "icon_color"
        case type
        case conditions
        case attachments
        case actions
        case isFavorite = "is_favorite"
        case enable
        case isValid = "is_valid"
    }
    
    convenience init(type: String) {
        self.init()
        self.type = type
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sceneId = (try? container.decode(Int.self, forKey: .sceneId)) ?? 0
        self.vid = (try? container.decode(Int.self, forKey: .vid)) ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.des = try container.decodeIfPresent(String.self, forKey: .des)
        
        self.iconImage = try container.decodeIfPresent(String.self, forKey: .iconImage)
        self.iconColor = try container.decodeIfPresent(String.self, forKey: .iconColor)
        
        self.type = (try? container.decode(String.self, forKey: .type)) ?? "one_click"
        if let conditionInfo = try? container.decodeIfPresent(MXSceneConditionItem.self, forKey: .conditions) {
            self.conditions = conditionInfo
        }
        if let attachmentInfo = try? container.decodeIfPresent(MXSceneConditionItem.self, forKey: .attachments) {
            self.attachments = attachmentInfo
        }
        self.actions = (try? container.decodeIfPresent([MXSceneTACItem].self, forKey: .actions)) ?? [MXSceneTACItem]()
        
        self.isFavorite = (try? container.decode(Bool.self, forKey: .isFavorite)) ?? false
        self.enable = (try? container.decode(Bool.self, forKey: .enable)) ?? false
        self.isValid = (try? container.decode(Bool.self, forKey: .isValid)) ?? true
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(sceneId, forKey: .sceneId)
        try? container.encode(vid, forKey: .vid)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(des, forKey: .des)
        
        try container.encodeIfPresent(iconImage, forKey: .iconImage)
        try container.encodeIfPresent(iconColor, forKey: .iconColor)
        
        try? container.encode(type, forKey: .type)
        try? container.encodeIfPresent(conditions, forKey: .conditions)
        try? container.encodeIfPresent(attachments, forKey: .attachments)
        try? container.encodeIfPresent(actions, forKey: .actions)
        
        try? container.encode(isFavorite, forKey: .isFavorite)
        try? container.encode(enable, forKey: .enable)
        try? container.encode(isValid, forKey: .isValid)
    }
}

public class MXSceneConditionItem:NSObject, Codable {
    public var uri: String = "mx/logic/and"
    public var items: [MXSceneTACItem]?
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXSceneConditionItem else {
            return false
        }
        return (self.uri == obj.uri &&
                self.items == obj.items)
    }
    
    enum CodingKeys: String, CodingKey {
        case uri
        case items
    }
    
    override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uri = (try? container.decode(String.self, forKey: .uri)) ?? "mx/logic/and"
        self.items = try container.decodeIfPresent([MXSceneTACItem].self, forKey: .items)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(self.uri, forKey: .uri)
        try? container.encode(self.items, forKey: .items)
    }
}

public class MXSceneTACItem:NSObject, Codable {
    public var uri: String?
    public var params: AnyObject? 
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXSceneTACItem else {
            return false
        }
        var valueCompare : Bool = false
        if self.uri == "mx/condition/device/property" ||
            self.uri == "mx/action/device/property/set" ||
            self.uri == "mx/action/group/property/set" {
            if let newValue = self.params as? MXDeviceInfo, let newObjValue = obj.params as? MXDeviceInfo {
                valueCompare = (newValue == newObjValue)
            }
        } else if self.uri == "mx/action/oneclick/do" || self.uri == "mx/action/scene/switch" {
            if let newValue = self.params as? MXSceneInfo, let newObjValue = obj.params as? MXSceneInfo {
                valueCompare = (newValue == newObjValue)
            }
        } else if self.uri == "mx/condition/timer" || self.uri == "mx/attachment/time/range" {
            if let newValue = self.params as? MXSceneConditionTimerInfo, let newObjValue = obj.params as? MXSceneConditionTimerInfo {
                valueCompare = (newValue == newObjValue)
            }
        } else if self.uri == "mx/attachment/sequence/delay/exec" {
            if let newValue = self.params as? [String: Int], let newObjValue = obj.params as? [String: Int] {
                valueCompare = (newValue == newObjValue)
            }
        } else {
            if let newValue = self.params as? [String: String], let newObjValue = obj.params as? [String: String] {
                valueCompare = (newValue == newObjValue)
            }
        }
        return (self.uri == obj.uri && valueCompare)
    }
    
    enum CodingKeys: String, CodingKey {
        case uri
        case params
    }
    
    override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uri = try container.decodeIfPresent(String.self, forKey: .uri)
        if self.uri == "mx/condition/device/property" ||
            self.uri == "mx/action/device/property/set" ||
            self.uri == "mx/action/group/property/set" {
            self.params = try container.decodeIfPresent(MXDeviceInfo.self, forKey: .params)
        } else if self.uri == "mx/action/oneclick/do" || self.uri == "mx/action/scene/switch" {
            self.params = try container.decodeIfPresent(MXSceneInfo.self, forKey: .params)
        } else if self.uri == "mx/condition/timer" || self.uri == "mx/attachment/time/range" {
            self.params = try container.decodeIfPresent(MXSceneConditionTimerInfo.self, forKey: .params)
        } else if self.uri == "mx/attachment/sequence/delay/exec" {
            let newParams = try container.decodeIfPresent([String: Int].self, forKey: .params)
            self.params = newParams as AnyObject?
        } else {
            let newParams = try container.decodeIfPresent([String: String].self, forKey: .params)
            self.params = newParams as AnyObject?
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(self.uri, forKey: .uri)
        
        if let newParams = self.params as? MXDeviceInfo  {
            try? container.encode(newParams, forKey: .params)
        } else if let newParams = self.params as? MXSceneInfo {
            try? container.encode(newParams, forKey: .params)
        } else if let newParams = self.params as? MXSceneConditionTimerInfo {
            try? container.encode(newParams, forKey: .params)
        } else if let newParams = self.params as? [String: Int] {
            try? container.encode(newParams, forKey: .params)
        } else if let newParams = self.params as? [String: String] {
            try? container.encode(newParams, forKey: .params)
        }
    }
}
