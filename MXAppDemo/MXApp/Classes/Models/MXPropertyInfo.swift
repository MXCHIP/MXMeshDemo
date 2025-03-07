
import Foundation
import UIKit

public class MXPropertyInfo: NSObject, Codable {
    
    public var identifier: String?
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
    public var compare_type : String = "=="
    public var value: AnyObject?
    public var dataType: MXPropertyDataType?
    
    public var isSupportQuickControl: Bool = false  
    public var isSupportCloudAutoCondition: Bool = false  
    public var isSupportCloudAutoAction: Bool = false  
    public var isSupportLocalAutoCondition: Bool = false  
    public var isSupportLocalAutoAction: Bool = false  
    
    convenience init(info:MXPropertyInfo) {
        self.init()
        self.identifier = info.identifier
        self.nameLocalizable = info.nameLocalizable
        self.name = info.name
        self.compare_type = info.compare_type
        self.value = info.value
        self.dataType = info.dataType
        self.isSupportQuickControl = info.isSupportQuickControl
        self.isSupportLocalAutoCondition = info.isSupportLocalAutoCondition
        self.isSupportLocalAutoAction = info.isSupportCloudAutoAction
        self.isSupportCloudAutoAction = info.isSupportCloudAutoAction
        self.isSupportCloudAutoCondition = info.isSupportCloudAutoCondition
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MXPropertyInfo else {
            return false
        }
        
        var valueCompare : Bool = false
        if self.dataType?.type == "struct" {
            if let newValue = self.value as? [String : Int], let newObjValue = obj.value as? [String: Int] {
                valueCompare = (newValue == newObjValue)
            } else if self.value == nil, obj.value == nil {
                valueCompare = true
            }
        } else {
            if let newValue = self.value as? Double, let newObjValue = obj.value as? Double {
                valueCompare = (newValue == newObjValue)
            } else if let newValue = self.value as? Int, let newObjValue = obj.value as? Int {
                valueCompare = (newValue == newObjValue)
            } else if self.value == nil, obj.value == nil {
                valueCompare = true
            }
        }
        
        return (self.identifier == obj.identifier &&
                self.name == obj.name &&
                self.compare_type == obj.compare_type &&
                valueCompare)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case identifier
        case nameLocalizable
        case name
        case value
        case dataType
        case compare_type
        case isSupportQuickControl
        case isSupportCloudAutoCondition
        case isSupportCloudAutoAction
        case isSupportLocalAutoCondition
        case isSupportLocalAutoAction
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        self.nameLocalizable = try container.decodeIfPresent([String: String].self, forKey: .nameLocalizable)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.dataType = try? container.decodeIfPresent(MXPropertyDataType.self, forKey: .dataType)
        self.compare_type = (try? container.decode(String.self, forKey: .compare_type)) ?? "=="
        if self.dataType?.type == "struct" {
            self.value = try container.decodeIfPresent([String : Int].self, forKey: .value) as AnyObject?
        } else if self.dataType?.type == "bool" || self.dataType?.type == "enum" {
            self.value = try container.decodeIfPresent(Int.self, forKey: .value) as AnyObject?
        } else if self.dataType?.type == "string" {
            self.value = try container.decodeIfPresent(String.self, forKey: .value) as AnyObject?
        } else {
            if let newValue = try? container.decode(Double.self, forKey: .value) {
                if self.dataType?.type == "double" || self.identifier == "ColorTemperature" {
                    self.value = newValue as AnyObject
                } else if dataType?.type == "float" {
                    self.value = Float(newValue) as AnyObject
                } else {
                    self.value = Int(newValue) as AnyObject
                }
            } else if let newValue = try? container.decode(Float.self, forKey: .value) {
                if dataType?.type == "float" {
                    self.value = Float(newValue) as AnyObject
                } else {
                    self.value = Int(newValue) as AnyObject
                }
            } else if let newValue = try? container.decode(Int.self, forKey: .value) {
                self.value = newValue as AnyObject
            }
        }
        
        self.isSupportQuickControl = (try? container.decode(Bool.self, forKey: .isSupportQuickControl)) ?? false
        self.isSupportCloudAutoCondition = (try? container.decode(Bool.self, forKey: .isSupportCloudAutoCondition)) ?? false
        self.isSupportCloudAutoAction = (try? container.decode(Bool.self, forKey: .isSupportCloudAutoAction)) ?? false
        self.isSupportLocalAutoCondition = (try? container.decode(Bool.self, forKey: .isSupportLocalAutoCondition)) ?? false
        self.isSupportLocalAutoAction = (try? container.decode(Bool.self, forKey: .isSupportLocalAutoAction)) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(nameLocalizable, forKey: .nameLocalizable)
        try container.encodeIfPresent(name, forKey: .name)
        if dataType?.type == "struct", let newValue = self.value as? [String : Int] {
            try container.encodeIfPresent(newValue, forKey: .value)
        } else if (dataType?.type == "bool" || dataType?.type == "enum"), let newValue = self.value as? Int {
            try container.encodeIfPresent(newValue, forKey: .value)
        } else if dataType?.type == "string", let newValue = self.value as? String {
            try container.encodeIfPresent(newValue, forKey: .value)
        } else {
            if (dataType?.type == "double" || identifier == "ColorTemperature"), let newValue = self.value as? Double {
                try container.encodeIfPresent(newValue, forKey: .value)
            } else if dataType?.type == "float", let newValue = self.value as? Float {
                try container.encodeIfPresent(newValue, forKey: .value)
            } else if let newValue = self.value as? Int {
                try container.encodeIfPresent(newValue, forKey: .value)
            }
        }
        try? container.encodeIfPresent(dataType, forKey: .dataType)
        try container.encodeIfPresent(compare_type, forKey: .compare_type)
        
        try? container.encode(isSupportQuickControl, forKey: .isSupportQuickControl)
        try? container.encode(isSupportCloudAutoCondition, forKey: .isSupportCloudAutoCondition)
        try? container.encode(isSupportCloudAutoAction, forKey: .isSupportCloudAutoAction)
        try? container.encode(isSupportLocalAutoCondition, forKey: .isSupportLocalAutoCondition)
        try? container.encode(isSupportLocalAutoAction, forKey: .isSupportLocalAutoAction)
    }
}

extension MXPropertyInfo {
    
    func valueAttributedString() -> NSAttributedString? {
        if let type = self.dataType?.type {
            if (type == "bool" || type == "enum") {
                if let dataValue = self.value as? Int, let specsParams = self.dataType?.specs as? [String: String] {
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + "-" + (specsParams[String(dataValue)] ?? "") + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                    return valueStr
                }
            } else if type == "struct" {
                if let dataValue = self.value as? [String: Int] {
                    if let p_identifier = self.identifier, p_identifier == "HSVColor",let hValue = dataValue["Hue"], let sValue = dataValue["Saturation"], let vValue = dataValue["Value"] {
                        let str = NSMutableAttributedString()
                        let nameStr = NSAttributedString(string: (self.name ?? "") + " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                        str.append(nameStr)
                        let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0),.baselineOffset:-4])
                        str.append(valueStr)
                        return str
                    }
                }
            } else {
                if let p_identifier = self.identifier, p_identifier == "HSVColorHex", let dataValue = self.value as? Int32 {
                    let str = NSMutableAttributedString()
                    let nameStr = NSAttributedString(string: (self.name ?? "") + " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                    str.append(nameStr)
                    let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:MXHSVColorHandle.colorFromHSVColor(value: Int32(dataValue)),.baselineOffset:-4])
                    str.append(valueStr)
                    return str
                } else if let dataValue = self.value as? Int {
                    var compareType = self.compare_type
                    if compareType == "==" {
                        compareType = "-"
                    }
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + compareType + String(dataValue) + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                    return valueStr
                } else if let dataValue = self.value as? Double {
                    var compareType = self.compare_type
                    if compareType == "==" {
                        compareType = "-"
                    }
                    var floatNum = 0
                    if let stepStr = self.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                        if step < 0.1 {
                            floatNum = 2
                        } else if step < 1 {
                            floatNum = 1
                        }
                    }
                    let valueStr = NSAttributedString(string: ((self.name ?? "") + compareType + String(format: "%.\(floatNum)f", dataValue) + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                    return valueStr
                }
            }
        }
        return nil
    }
    
}

public class MXPropertyDataType: NSObject, Codable {
    
    public var type: String?
    public var specsLocalizable: [String:[String: String]]?
    public var _specs: AnyObject?
    public var specs: AnyObject? {
        get {
            if let language = (MXAccountManager.shared.language ?? Locale.preferredLanguages.first),
               language.contains("zh-Hans"),
               let localizable = self.specsLocalizable,
               let new = localizable["zh-Hans"]  {
                return new as AnyObject
            }
            return _specs
        }
        set {
            _specs = newValue
        }
    }  
    
    
    enum CodingKeys: String, CodingKey {
        case type
        case specsLocalizable
        case specs
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.specsLocalizable = try container.decodeIfPresent([String : [String: String]].self, forKey: .specsLocalizable)
        if self.type == "struct" {
            self.specs = try container.decodeIfPresent([MXPropertyInfo].self, forKey: .specs) as AnyObject?
        } else {
            self.specs = try container.decodeIfPresent([String : String].self, forKey: .specs) as AnyObject?
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(specsLocalizable, forKey: .specsLocalizable)
        if let newSpecs = self.specs as? [MXPropertyInfo] {
            try container.encodeIfPresent(newSpecs, forKey: .specs)
        } else if let newSpecs = self.specs as? [String : String] {
            try container.encodeIfPresent(newSpecs, forKey: .specs)
        }
    }
}
