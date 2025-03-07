
import Foundation
import FlexColorPicker
import MeshSDK
import UIKit

class MXHSVColorHandle: NSObject {
    
    public static func getHueromColorHex(value: Int32) -> Int {
        let hexValue = UInt32(bitPattern: value)
        let hex = String(format: "%08X", hexValue)
        let bytes = [UInt8](Data(hex: hex))
        guard bytes.count == 4 else {
            return 0
        }
        let hue = String(format: "%02X%02X", bytes[1],bytes[0])
        let hValue = Int(hue, radix: 16) ?? 0
        
        return hValue
    }
    
    public static func getHSVFromColorHex(value: Int32) -> [String:Int] {
        let hexValue = UInt32(bitPattern: value)
        let hex = String(format: "%08X", hexValue)
        let bytes = [UInt8](Data(hex: hex))
        guard bytes.count == 4 else {
            return [String:Int]()
        }
        var hsvParams = [String:Int]()
        let hue = String(format: "%02X%02X", bytes[1],bytes[0])
        let hValue = Int(hue, radix: 16) ?? 0
        hsvParams["Hue"] = hValue
        let sStr = String(format: "%02X", bytes[2])
        let sValue = Int(sStr, radix: 16) ?? 0
        hsvParams["Saturation"] = sValue
        let vStr = String(format: "%02X", bytes[3])
        let vValue = Int(vStr, radix: 16) ?? 0
        hsvParams["Value"] = vValue
        return hsvParams
    }
    
    public static func colorFromHSVColor(value: Int32) -> UIColor? {
        let hexValue = UInt32(bitPattern: value)
        let hex = String(format: "%08X", hexValue)
        let bytes = [UInt8](Data(hex: hex))
        guard bytes.count == 4 else {
            return UIColor(hex: "FFFFFF")
        }
        let hue = String(format: "%02X%02X", bytes[1],bytes[0])
        let hValue = Int(hue, radix: 16) ?? 0
        let sStr = String(format: "%02X", bytes[2])
        let sValue = Int(sStr, radix: 16) ?? 0
        let vStr = String(format: "%02X", bytes[3])
        let vValue = Int(vStr, radix: 16) ?? 0
        return UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0)
    }
    
    public static func colorFromHSVColor(hex: String) -> UIColor? {
        let bytes = [UInt8](Data(hex: hex))
        guard bytes.count == 4 else {
            return UIColor(hex: "FFFFFF")
        }
        let hue = String(format: "%02X%02X", bytes[1],bytes[0])
        let hValue = Int(hue, radix: 16) ?? 0
        let sStr = String(format: "%02X", bytes[2])
        let sValue = Int(sStr, radix: 16) ?? 0
        let vStr = String(format: "%02X", bytes[3])
        let vValue = Int(vStr, radix: 16) ?? 0
        return UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0)
        
    }
}
