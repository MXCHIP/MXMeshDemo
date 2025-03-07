
import Foundation
import UIKit

let statusBarHight = UIApplication.shared.statusBarFrame.height
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

func localized(key: String) -> String {
    if let currentLang = MXAccountManager.shared.language,
        let langPath = Bundle.main.path(forResource: currentLang, ofType: "lproj"),
        let langBundle = Bundle.init(path: langPath)  {
        return langBundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }
    return NSLocalizedString(key, comment: "")
}

let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"

var MXResourceUrl = "https://light-lite-resource.oss.mxchip.com/AppResources.zip"

class AppUIConfiguration: NSObject {
    public static let statusBarH : CGFloat = UIApplication.shared.statusBarFrame.size.height
    public static let navBarH : CGFloat = 44.0
    
    public static var appType = 0
    
    static public func feedbackGenerator() {
        let gen = UIImpactFeedbackGenerator.init(style: .medium);//light震动效果的强弱
        gen.prepare();//反馈延迟最小化
        gen.impactOccurred()//触发效果
    }
    
}

extension AppUIConfiguration {
    
    struct NeutralColor {
        
        static var title: UIColor  {
            return UIColor(with: "262626",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.85)
        }
        
        static var primaryText: UIColor  {
            return UIColor(with: "595959",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.65)
        }
        
        static var secondaryText: UIColor  {
            return UIColor(with: "8C8C8C",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.45)
        }
        
        static var disable: UIColor  {
            return UIColor(with: "BFBFBF",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.25)
        }
        
        static var border: UIColor  {
            return UIColor(with: "EEEEEE",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.15)
        }
        
        
        static var whiteBorder: UIColor  {
            return UIColor(with: "FFFFFF",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.2)
        }
        
        
        static var dividers: UIColor  {
            return UIColor(with: "EEEEEE",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.15)
        }
        
        static var background: UIColor  {
            return UIColor(with: "F2F2F7",
                           lightModeAlpha: 1,
                           darkModeHex: "000000",
                           darkModeAlpha: 1)
        }
        
        
        static var statusBackground: UIColor  {
            return UIColor(with: "E5E5E5",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.15)
        }
        
        
        static var border1: UIColor  {
            return UIColor(with: "CCCCCC",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.2)
        }
    }
    
    
    
    
    struct backgroundColor {
        
        struct level1 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "000000",
                               darkModeAlpha: 1)
            }
            
            static var F2F2F7: UIColor  {
                return UIColor(with: "F2F2F7",
                               lightModeAlpha: 1,
                               darkModeHex: "000000",
                               darkModeAlpha: 1)
            }
        }
        
        struct level2 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "121212",
                               darkModeAlpha: 1)
            }
            
            static var FBFBFD: UIColor  {
                return UIColor(with: "FBFBFD",
                               lightModeAlpha: 1,
                               darkModeHex: "121212",
                               darkModeAlpha: 1)
            }
        }
        
        struct level3 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "1A1A1A",
                               darkModeAlpha: 1)
            }
        }
        
        struct level4 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "303030",
                               darkModeAlpha: 1)
            }
            
            static var F5F5F5: UIColor  {
                return UIColor(with: "F5F5F5",
                               lightModeAlpha: 1,
                               darkModeHex: "303030",
                               darkModeAlpha: 1)
            }
            
            static var FF4D4F: UIColor  {
                return UIColor(with: "FF4D4F",
                               lightModeAlpha: 1,
                               darkModeHex: "FF4D4F",
                               darkModeAlpha: 1)
            }
            
            static var F2F2F7: UIColor  {
                return UIColor(with: "F2F2F7",
                               lightModeAlpha: 1,
                               darkModeHex: "000000",
                               darkModeAlpha: 1)
            }
        }
        
        struct level5 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "000000",
                               darkModeAlpha: 1)
            }
        }
        
        struct level6 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "000000",
                               darkModeAlpha: 1)
            }
        }
        
        struct level7 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "000000",
                               darkModeAlpha: 1)
            }
        }
        
    }
    
    struct floatViewColor {
        
        struct level1 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "303030",
                               darkModeAlpha: 1)
            }
        }
        
        struct level2 {
            
            static var FFFFFF: UIColor  {
                return UIColor(with: "FFFFFF",
                               lightModeAlpha: 1,
                               darkModeHex: "404040",
                               darkModeAlpha: 1)
            }
            
            static var F5F5F5: UIColor  {
                return UIColor(with: "F5F5F5",
                               lightModeAlpha: 1,
                               darkModeHex: "404040",
                               darkModeAlpha: 1)
            }
            
            static var F8F8F7: UIColor  {
                return UIColor(with: "F8F8F7",
                               lightModeAlpha: 1,
                               darkModeHex: "404040",
                               darkModeAlpha: 1)
            }
            
            
            static var DADADA: UIColor  {
                return UIColor(with: "DADADA",
                               lightModeAlpha: 1,
                               darkModeHex: "1A1A1A",
                               darkModeAlpha: 1)
            }
        }
        
    }
    
    struct lineColor {
        
        struct vertical {
            
            static var XX000000: UIColor  {
                return UIColor(with: "000000",
                               lightModeAlpha: 0.08,
                               darkModeHex: "FFFFFF",
                               darkModeAlpha: 0.08)
            }
        }
        
        
        
        static var XX0AEEEEEE: UIColor  {
            return UIColor(with: "EEEEEE",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.10)
        }
        
        
        
        static var XX0FEEEEEE: UIColor  {
            return UIColor(with: "EEEEEE",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.15)
        }
    }
    
    struct MXBackgroundColor {
        
        static var bg0: UIColor  {
            return UIColor(with: "FFFFFF",
                           lightModeAlpha: 1,
                           darkModeHex: "000000",
                           darkModeAlpha: 1)
        }
        
        static var bg1: UIColor  { return UIColor(hex: "AEF0FE")}
        
        static var bg2: UIColor  { return UIColor(hex: "ACD9D2")}
        
        static var bg3: UIColor  { return UIColor(hex: "C5F0DD")}
        
        static var bg4: UIColor  { return UIColor(hex: "F8E2C3")}
        
        static var bg5: UIColor  { return UIColor(hex: "F0C8B1")}
        
        static var bg6: UIColor  { return UIColor(hex: "E8DBC8")}
        
        static var bg7: UIColor  { return UIColor(hex: "DFE7F2")}
        
        static var bg8: UIColor  { return UIColor(hex: "D2CFFE")}

        
        static var bg9: UIColor  {
            return UIColor(with: "F5F6FA",
                           lightModeAlpha: 1,
                           darkModeHex: "1A1A1A",
                           darkModeAlpha: 1)
        }

        
        static var bgA: UIColor  {
            return UIColor(with: "F9F9F9",
                           lightModeAlpha: 1,
                           darkModeHex: "1A1A1A",
                           darkModeAlpha: 1)
        }

    }
    
    struct ButtonColor {
        
        static var weak: UIColor  {
            return UIColor(with: "F5F5F5",
                           lightModeAlpha: 1,
                           darkModeHex: "404040",
                           darkModeAlpha: 1)
        }
        
        static var F5F5F5: UIColor  {
            return UIColor(with: "F5F5F5",
                           lightModeAlpha: 1,
                           darkModeHex: "FFFFFF",
                           darkModeAlpha: 0.15)
        }
    }
    
    struct UndefinedColor {
        static var FEC60C: UIColor  { return UIColor(hex: "FEC60C")}
        static var F9F9F9: UIColor  { return UIColor(hex: "F9F9F9")}
        static var F5F5F5: UIColor  { return UIColor(hex: "F5F5F5")}
        static var XX00CBDE: UIColor  { return UIColor(hex: "00CBDE")}
        static var FFC33A: UIColor  { return UIColor(hex: "FFC33A")}
        static var XX00CBA7: UIColor  { return UIColor(hex: "00CBA7")}
        static var F2F2F2: UIColor  {
            return UIColor(with: "F2F2F2",
                           lightModeAlpha: 1,
                           darkModeHex: "505050",
                           darkModeAlpha: 1)
        }
        static var XX976FFB: UIColor  { return UIColor(hex: "976FFB")}
        static var FFF9EB: UIColor  { return UIColor(hex: "FFF9EB")}
        static var EBFFFB: UIColor  { return UIColor(hex: "EBFFFB")}
        static var F0EBFF: UIColor  { return UIColor(hex: "F0EBFF")}
        static var FFF8EB: UIColor  { return UIColor(hex: "FFF8EB")}
        static var E5F3F9: UIColor  { return UIColor(hex: "E5F3F9")}
        static var FE6974: UIColor  { return UIColor(hex: "FE6974")}
    }
    
    struct MainColor {
        static var C0: UIColor  { return UIColor(hex: "13B7F9")}
        static var C1: UIColor  { return UIColor(hex: "14B7F9")}
        static var C2: UIColor  { return UIColor(hex: "13B7F9",alpha: 0.5)}
        static var C3: UIColor  { return UIColor(hex: "29A3FF")}
        static var C4: UIColor  { return UIColor(hex: "E6FCFF")}
    }
    
    
    struct TypographySize {
        
        static var H0: CGFloat  { return 24}
        
        static var H1: CGFloat  { return 20}
        
        static var H2: CGFloat  { return 18}
        
        static var H3: CGFloat  { return 17}
        
        static var H4: CGFloat  { return 16}
        
        static var H5: CGFloat  { return 14}
        
        static var H6: CGFloat  { return 12}
        
        static var H7: CGFloat  { return 10}
    }
    
    struct TypographyUndefinedSize {
        
        static var H0: CGFloat  { return 32}
        
        static var H1: CGFloat  { return 31}
        
        static var H2: CGFloat  { return 30}
        
        static var H3: CGFloat  { return 29}
        
        static var H4: CGFloat  { return 28}
        
        static var H5: CGFloat  { return 27}
        
        static var H6: CGFloat  { return 26}
        
        static var H7: CGFloat  { return 25}
        
        static var H8: CGFloat  { return 23}
        
        static var H9: CGFloat  { return 22}
        
        static var HA: CGFloat  { return 21}
        
        static var HB: CGFloat  { return 19}
        
        static var HC: CGFloat  { return 15}
        
        static var HD: CGFloat  { return 13}
        
        static var HE: CGFloat  { return 11}
        
        static var G0: CGFloat  { return 40}
    }
    
    struct MXAssistColor {
        static var main: UIColor  { return UIColor(hex: "13B7F9")}
        static var mask: UIColor  { return UIColor(hex: "000000")}
        static var yellow: UIColor  { return UIColor(hex: "FFD627")}
        static var gold: UIColor  { return UIColor(hex: "FAAD14")}
        static var blue: UIColor  { return UIColor(hex: "1890FF")}
        static var green: UIColor  { return UIColor(hex: "52C41A")}
        static var red: UIColor  { return UIColor(hex: "FF4D4F")}
        static var shadow: UIColor  { return UIColor(hex: "003961", alpha: 0.08)}
        static var purple: UIColor  { return UIColor(hex: "976FFB")}
        static var orange: UIColor  { return UIColor(hex: "FF8062")}
    }
    
    struct MXColor {
        static var white: UIColor  { return UIColor(hex: "FFFFFF")}
        static var black: UIColor  { return UIColor(hex: "000000")}
    }
    
    struct Font {
        static var PingFang_Light: String { return "PingFang-SC-Light" }
        static var PingFang_Regular: String { return "PingFang-SC-Regular" }
        static var PingFang_Medium: String { return "PingFang-SC-Medium" }
        static var PingFang_Bold: String { return "PingFang-SC-Bold" }
        static var PingFang_Semibold: String { return "PingFang-SC-Semibold" }
        static var iconfont: String { return "iconfont" }
    }
    
    
    struct MXLightSceneColor {
        static var red: [UIColor]  { return [UIColor(hex: "96242E"), UIColor(hex: "FFE4E6")]}
        static var orange: [UIColor]  { return [UIColor(hex: "844E30"), UIColor(hex: "FFEDE3")]}
        static var yellow: [UIColor]  { return [UIColor(hex: "815900"), UIColor(hex: "FAEAD4")]}
        static var green: [UIColor]  { return [UIColor(hex: "32966A"), UIColor(hex: "CEFFE9")]}
        static var cyan: [UIColor]  { return [UIColor(hex: "127A73"), UIColor(hex: "D4FFFC")]}
        static var blue: [UIColor]  { return [UIColor(hex: "135564"), UIColor(hex: "D9F8FF")]}
        static var purple: [UIColor]  { return [UIColor(hex: "381B7E"), UIColor(hex: "EBE2FF")]}
    }
}
