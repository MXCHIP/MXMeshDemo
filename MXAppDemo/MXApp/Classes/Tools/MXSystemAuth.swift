
import Photos
import MediaPlayer
import Photos
import UserNotifications
import Contacts
import Intents
import Speech
import EventKit
import LocalAuthentication
import HealthKit
import HomeKit
import CoreMotion
import CoreBluetooth

private let cmPedometer = CMPedometer()

typealias AuthClouser = ((Bool)->())


public class MXSystemAuth: NSObject {
    
    static let shard = MXSystemAuth()
    var cbManager:CBCentralManager!
    var cbStatus : Int  = 0 
    var cbPermissCallback : AuthClouser?
    var locationAuthManager = CLLocationManager()
    
    public override init() {
        super.init()
        self.cbManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    class func authMediaPlayerService(clouser :@escaping AuthClouser) {
        let authStatus = MPMediaLibrary.authorizationStatus()
        switch authStatus {
        
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { (status) in
                if status == .authorized{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        
        case .denied:
            clouser(false)
        
        case .restricted:
            clouser(false)
        
        case .authorized:
            clouser(true)
        
        default:
            clouser(false)
        }
    }
    
    
    class func authCamera(clouser: @escaping AuthClouser) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (result) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .denied:
            clouser(false)
        case .restricted:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authPhotoLib(clouser: @escaping AuthClouser) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .denied:
            clouser(false)
        case .restricted:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authMicrophone(clouser: @escaping AuthClouser) {
        let authStatus = AVAudioSession.sharedInstance().recordPermission
        switch authStatus {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (result) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .denied:
            clouser(false)
        case .granted:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authLocation(clouser: @escaping ((Bool,Bool,Bool)->())) {
        var authStatus = CLLocationManager.authorizationStatus()
        if #available(iOS 14.0, *) {
            authStatus = MXSystemAuth.shard.locationAuthManager.authorizationStatus
        }
        switch authStatus {
        case .notDetermined:
            
            MXSystemAuth.shard.locationAuthManager.requestAlwaysAuthorization()
            MXSystemAuth.shard.locationAuthManager.requestWhenInUseAuthorization()
            var status = CLLocationManager.authorizationStatus()
            if #available(iOS 14.0, *) {
                status = MXSystemAuth.shard.locationAuthManager.authorizationStatus
            }
            if  status == .authorizedAlways || status == .authorizedWhenInUse {
                DispatchQueue.main.async {
                    if #available(iOS 14.0, *) {
                        if MXSystemAuth.shard.locationAuthManager.accuracyAuthorization == .fullAccuracy {
                            clouser(true && CLLocationManager.locationServicesEnabled(), false, true)
                        } else {
                            
                            MXSystemAuth.shard.locationAuthManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "WantsToGetWiFiSSID") { (error:Error?) in
                                clouser(true && CLLocationManager.locationServicesEnabled(), false, error == nil)
                            }
                        }
                    } else {
                        clouser(true && CLLocationManager.locationServicesEnabled(), false, true)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    clouser(false, true, false)
                }
            }
        case .restricted:
            clouser(false, false, false)
        case .denied:
            clouser(false, false, false)
        case .authorizedAlways:
            if #available(iOS 14.0, *) {
                if MXSystemAuth.shard.locationAuthManager.accuracyAuthorization == .fullAccuracy {
                    clouser(true && CLLocationManager.locationServicesEnabled(), false, true)
                } else {
                    
                    MXSystemAuth.shard.locationAuthManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "WantsToGetWiFiSSID") { (error:Error?) in
                        clouser(true && CLLocationManager.locationServicesEnabled(), false, error == nil)
                    }
                }
            } else {
                clouser(true && CLLocationManager.locationServicesEnabled(), false, true)
            }
        case .authorizedWhenInUse:
            if #available(iOS 14.0, *) {
                if MXSystemAuth.shard.locationAuthManager.accuracyAuthorization == .fullAccuracy {
                    clouser(true && CLLocationManager.locationServicesEnabled(), false, true)
                } else {
                    
                    MXSystemAuth.shard.locationAuthManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "WantsToGetWiFiSSID") { (error:Error?) in
                        clouser(true && CLLocationManager.locationServicesEnabled(), false, error == nil)
                    }
                }
            } else {
                clouser(true && CLLocationManager.locationServicesEnabled(), false, true)
            }
        default:
            clouser(false, false, false)
        }
    }
    
    
    class func authBluetooth(clouser: @escaping ((Bool)->())) {
        MXSystemAuth.shard.cbPermissCallback = nil
        let authStatus = CBPeripheralManager.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            MXSystemAuth.shard.cbManager.scanForPeripherals(withServices: nil, options: nil)
            MXSystemAuth.shard.cbManager.stopScan()
            if #available(iOS 13.0, *) {
                self.authBluetooth(clouser: clouser)
            } else {
                if MXSystemAuth.shard.cbStatus == 0 {
                    MXSystemAuth.shard.cbPermissCallback = clouser
                } else {
                    clouser(true && MXSystemAuth.shard.cbStatus == 1)
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            if MXSystemAuth.shard.cbStatus == 0 {
                MXSystemAuth.shard.cbPermissCallback = clouser
            } else {
                clouser(true && MXSystemAuth.shard.cbStatus == 1)
            }
        default:
            clouser(false)
        }
    }
    
    
    class func authNotification(clouser: @escaping AuthClouser){
        UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
            switch setttings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { (result, error) in
                    if result{
                        DispatchQueue.main.async {
                            clouser(true)
                        }
                    }else{
                        DispatchQueue.main.async {
                            clouser(false)
                        }
                    }
                }
            case .denied:
                clouser(false)
            case .authorized:
                clouser(true)
            case .provisional:
                clouser(true)
            default:
                clouser(false)
            }
        }
    }
    
    
    class func authCMPedometer(clouser: @escaping AuthClouser){
        cmPedometer.queryPedometerData(from: Date(), to: Date()) { (pedometerData, error) in
            if pedometerData?.numberOfSteps != nil{
                DispatchQueue.main.async {
                    clouser(true)
                }
            }else{
                DispatchQueue.main.async {
                    clouser(false)
                }
            }
        }
    }
    
    
    class func authContacts(clouser: @escaping AuthClouser){
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authStatus {
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { (result, error) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authSiri(clouser: @escaping AuthClouser){
        let authStatus = INPreferences.siriAuthorizationStatus()
        switch authStatus {
        case .notDetermined:
            INPreferences.requestSiriAuthorization { (status) in
                if status == .authorized{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authSpeechRecognition(clouser: @escaping AuthClouser){
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { (status) in
                if status == .authorized{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authRreminder(clouser: @escaping AuthClouser){
        let authStatus = EKEventStore.authorizationStatus(for: .reminder)
        switch authStatus {
        case .notDetermined:
            EKEventStore().requestAccess(to: .reminder) { (result, error) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authEvent(clouser: @escaping AuthClouser){
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        switch authStatus {
        case .notDetermined:
            EKEventStore().requestAccess(to: .event) { (result, error) in
                if result{
                    DispatchQueue.main.async {
                        clouser(true)
                    }
                }else{
                    DispatchQueue.main.async {
                        clouser(false)
                    }
                }
            }
        case .restricted:
            clouser(false)
        case .denied:
            clouser(false)
        case .authorized:
            clouser(true)
        default:
            clouser(false)
        }
    }
    
    
    class func authFaceOrTouchID(clouser: @escaping ((Bool,Error)->())) {
        let context = LAContext()
        var error: NSError?
        let result = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        if result {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "认证") { (success, authError) in
                if success{
                    print("成功")
                }else{
                    print("失败")
                }
            }
        }else{
            
            print("不可以使用")
        }
    }
    
    
    class func authHealth(clouser: @escaping AuthClouser){
        if HKHealthStore.isHealthDataAvailable(){
            let authStatus = HKHealthStore().authorizationStatus(for: .workoutType())
            switch authStatus {
            case .notDetermined:
                if #available(iOS 13.0, *) {
                    HKHealthStore().requestAuthorization(toShare: [.audiogramSampleType(), .workoutType()], read: [.activitySummaryType(), .workoutType(), .audiogramSampleType()]) { (result, error) in
                        if result{
                            DispatchQueue.main.async {
                                clouser(true)
                            }
                        }else{
                            DispatchQueue.main.async {
                                clouser(false)
                            }
                        }
                    }
                } else {
                    HKHealthStore().requestAuthorization(toShare: [.workoutType()], read: [.activitySummaryType(), .workoutType()]) { (result, error) in
                        if result{
                            DispatchQueue.main.async {
                                clouser(true)
                            }
                        }else{
                            DispatchQueue.main.async {
                                clouser(false)
                            }
                        }
                    }
                }
            case .sharingDenied:
                clouser(false)
            case .sharingAuthorized:
                clouser(true)
            default:
                clouser(false)
            }
        }else{
            clouser(false)
        }
    }
    
    
    class func authHomeKit(clouser: @escaping AuthClouser) {
        if #available(iOS 13.0, *) {
            switch HMHomeManager().authorizationStatus {
            case .authorized:
                clouser(true)
            case .determined:
                clouser(false)
            case .restricted:
                clouser(false)
            default:
                clouser(false)
            }
        } else {
            if (HMHomeManager().primaryHome != nil) {
                clouser(true)
            }else{
                clouser(false)
            }
        }
    }
    
    
    class func authSystemSetting(urlString :String?, clouser: @escaping AuthClouser) {
        var url: URL
        if (urlString != nil) && urlString?.count ?? 0 > 0 {
            url = URL(string: urlString!)!
        }else{
            url = URL(string: UIApplication.openSettingsURLString)!
        }
        
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (result) in
                if result{
                    clouser(true)
                }else{
                    clouser(false)
                }
            }
        }else{
            clouser(false)
        }
    }
}

extension MXSystemAuth: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.cbStatus = 1
        } else {
            self.cbStatus = 2
        }
        self.cbPermissCallback?(self.cbStatus == 1)
        self.cbPermissCallback = nil
    }
}
