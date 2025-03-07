
import Foundation

extension String {
    
}

public class MXCron {
    
    public var cronString:String?
    
    public var minute:String?
    public var hour:String?
    public var day:String?
    public var month:String?
    public var weekday:String?
    
    
    public init?(cronString:String) {
        self.cronString = cronString
        do {
            try decompose(cronString: cronString)
        } catch {
            return nil
        }
    }
    
    public init?(startTime:String? = nil, endTime:String? = nil, repeatMode:Int = 0, weekday:[Int]? = nil) {
        
        if let startStr = startTime  {
            let startArray = startStr.components(separatedBy: ":")
            if startArray.count == 2 {
                self.minute = startArray[1]
                self.hour = startArray[0]
            }
        }
        
        if let endStr = endTime  {
            let endArray = endStr.components(separatedBy: ":")
            if endArray.count == 2 {
                if self.minute == nil {
                    self.minute = endArray[1]
                } else {
                    self.minute = self.minute! + "-" + endArray[1]
                }
                
                if self.hour == nil {
                    self.hour = endArray[0]
                } else {
                    self.hour = self.hour! + "-" + endArray[0]
                }
            }
        }
        
        if var weekdayList = weekday, weekdayList.count > 0 {
            var weekdayStr = ""
            weekdayList.sort()
            weekdayList.forEach { (week_day:Int) in
                if weekdayStr.count > 0 {
                    weekdayStr = weekdayStr + "," + String(week_day)
                } else {
                    weekdayStr = weekdayStr + String(week_day)
                }
            }
            self.weekday = weekdayStr
        }
        
        switch repeatMode {
        case 2:  
            self.weekday = "1,2,3,4,5"
            break
        case 3:  
            self.weekday = "0,6"
            break
        case 4:  
            break
        default:
            self.weekday = nil
            break
        }
        
        self.cronString = (self.minute ?? "*") + " " + (self.hour ?? "*") + " " + (self.day ?? "*") + " " + (self.month ?? "*") + " " + (self.weekday ?? "*")
    }
    
    public func sceneEffectiveTime() -> MXSceneEffectiveTimeModel {
        let model = MXSceneEffectiveTimeModel()
        if let minuteStr = self.minute, let hourStr = self.hour {
            let minuteArray = minuteStr.components(separatedBy: "-")
            let hourArray = hourStr.components(separatedBy: "-")
            if minuteArray.count == 2, hourArray.count == 2 {
                model.start = String(format: "%02d", (Int(hourArray[0]) ?? 0)) + ":" + String(format: "%02d", (Int(minuteArray[0]) ?? 0))
                model.end = String(format: "%02d", (Int(hourArray[1]) ?? 0)) + ":" + String(format: "%02d", (Int(minuteArray[1]) ?? 0))
            } 
        }
        
        if model.start == "00:00", model.end == "23:59" {
            model.wholeDay = true
        } else {
            model.wholeDay = false
        }
        
        if self.weekday == "1,2,3,4,5" {
            model.repeatMode = 2
        } else if self.weekday == "0,6" {
            model.repeatMode = 3
        } else if self.weekday == nil {
            model.repeatMode = 1
        } else {
            model.repeatMode = 4
            let weekList = self.weekday?.components(separatedBy: ",")
            model.weeks = [Int]()
            weekList?.forEach { (weekStr: String) in
                if let week_day = Int(weekStr) {
                    model.weeks.append(week_day%7)
                }
            }
        }
        
        return model
    }
    
    public func sceneConditionTime() -> String? {
        if let minuteStr = self.minute, let hourStr = self.hour {
            let minuteArray = minuteStr.components(separatedBy: "-")
            let hourArray = hourStr.components(separatedBy: "-")
            if minuteArray.count == 1, hourArray.count == 1 {
                let timeStr = hourArray[0] + ":" + minuteArray[0]
                return timeStr
            }
        }
        return nil
    }
    
    fileprivate func decompose(cronString:String) throws {
        let cronExpressionArray = cronString.components(separatedBy: " ")
        if cronExpressionArray.count == 5 {
            let minuteStr = cronExpressionArray[0]
            if minuteStr.count > 0, minuteStr != "*" {
                self.minute = minuteStr
            }
            
            let hourStr = cronExpressionArray[1]
            if hourStr.count > 0, hourStr != "*" {
                self.hour = hourStr
            }
            
            let dayStr = cronExpressionArray[2]
            if dayStr.count > 0, dayStr != "*" {
                self.day = dayStr
            }
            
            let monthStr = cronExpressionArray[3]
            if monthStr.count > 0, monthStr != "*" {
                self.month = monthStr
            }
            
            let weekdayStr = cronExpressionArray[4]
            if weekdayStr.count > 0, weekdayStr != "*" {
                self.weekday = weekdayStr
            }
        } else if cronExpressionArray.count == 7 {
            let minuteStr = cronExpressionArray[1]
            if minuteStr.count > 0, minuteStr != "*" {
                self.minute = minuteStr
            }
            
            let hourStr = cronExpressionArray[2]
            if hourStr.count > 0, hourStr != "*" {
                self.hour = hourStr
            }
            
            let dayStr = cronExpressionArray[3]
            if dayStr.count > 0, dayStr != "*" {
                self.day = dayStr
            }
            
            let monthStr = cronExpressionArray[4]
            if monthStr.count > 0, monthStr != "*" {
                self.month = monthStr
            }
            
            let weekdayStr = cronExpressionArray[5]
            if weekdayStr.count > 0, weekdayStr != "*" {
                self.weekday = weekdayStr
            }
        }
    }
}
