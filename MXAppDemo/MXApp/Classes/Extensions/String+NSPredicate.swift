
import Foundation

extension String {
    
    func isEmpty() -> Bool {
        return self.count == 0
    }
    
    func isSpace() -> Bool {
        let regEx = "  *"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        
        return pred.evaluate(with: self)
    }
    
    
    
    func isValidPhoneNumber() -> Bool {
        
        let emailRegEx = "[0-9]{5,11}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }

    
    func isValidChinaMainlandPhoneNumber() -> Bool {
        
        let emailRegEx = "1[3-9][0-9]{9}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]{6,16}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func isValidGatewayPassword() -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]{6,32}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func isValidName() -> Bool {
        var length = 15
        if let language = (MXAccountManager.shared.language ?? Locale.preferredLanguages.first),
            language.split(separator: "-").first == "en" {
            length = 100
        }
        let regEx = "[\u{4e00}-\u{9fa5}A-Z0-9a-z._%+-/(/)]{1,\(length)}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func isValidNickName() -> Bool {
        var length = 15
        if let language = (MXAccountManager.shared.language ?? Locale.preferredLanguages.first),
            language.split(separator: "-").first == "en" {
            length = 100
        }
        let regEx = "[\u{4e00}-\u{9fa5}A-Z0-9a-z._%+-/(/)]{1,\(length)}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func isValidDeviceName() -> Bool {
        var length = 15
        if let language = (MXAccountManager.shared.language ?? Locale.preferredLanguages.first),
            language.split(separator: "-").first == "en" {
            length = 100
        }
        let regEx = "[\u{4e00}-\u{9fa5}A-Z0-9a-z._%+-/(/)]{1,\(length)}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
}


extension String {
    
    func toastMessageIfIsInValidUserName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = localized(key: "输入不能为空")
        } else {
            if !self.isValidNickName() {
                string = localized(key: "用户名校验")
            }
        }
        
        return string
    }
    
    func toastMessageIfIsInValidHomeName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = localized(key: "输入不能为空")
        } else {
            if !self.isValidNickName() {
                string = localized(key: "用户名校验")
            }
        }
        
        return string
    }
    
    func toastMessageIfIsInValidRoomName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = localized(key: "输入不能为空")
        } else {
            if !self.isValidNickName() {
                string = localized(key: "用户名校验")
            }
        }
        
        return string
    }
    
    func toastMessageIfIsValidAccount() -> String? {
        
        var string: String?

        if self.isEmpty || self.isSpace() {
            string = localized(key: "输入不能为空")
        } else {
            if !self.isValidEmail() {
                if !self.isValidChinaMainlandPhoneNumber() {
                    string = localized(key: "帐号格式错误")
                }
            }
        }
        
        return string
    }
    
    func toastMessageIfIsInValidPassword() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = localized(key: "输入不能为空")
        } else {
            if !self.isValidPassword() {
                string = localized(key: "密码校验")
            } else {
                
                var status = ["upper": false, "lower": false]
                
                for char in self {
                    if char.isUppercase {
                        status["upper"] = true
                    }
                    if char.isLowercase {
                        status["lower"] = true
                    }
                }
                
                if let upper = status["upper"],
                   let lower = status["lower"] {
                    if !upper && !lower {
                        string = localized(key: "密码校验")
                    }
                }
            }
            
        }
        
        return string
    }
    
    func toastMessageIfIsInValidDeviceName() -> String? {
        
        var string: String?
        
        if self.isEmpty || self.isSpace() {
            string = localized(key: "输入不能为空")
        } else {
            if !self.isValidDeviceName() {
                string = localized(key: "用户名校验")
            }
        }
        
        return string
    }
    
}

extension String {
    
    func accountType() -> String? {
        var type: String?
        
        if self.isValidEmail() {
            type = localized(key: "邮箱")
        } else if self.isValidChinaMainlandPhoneNumber() {
            type = localized(key: "手机号")
        }
        
        return type
    }
    
}
