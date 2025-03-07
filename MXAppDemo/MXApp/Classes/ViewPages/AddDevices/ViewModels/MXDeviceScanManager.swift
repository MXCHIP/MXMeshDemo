//
//  MXDeviceScanManager.swift
//  MXApp
//
//  Created by mxchip on 2023/10/26.
//

import Foundation
import MeshSDK
import CoreBluetooth

public class MXDeviceScanManager: NSObject {
    public static let shared = MXDeviceScanManager()
    
    //发现设备的回调
    public typealias MXScanResultCallback = (_ devices:[[String: Any]], _ isStop: Bool ) -> ()
    var scanResultCallback: MXScanResultCallback!
    
    var centralManager: CBCentralManager!
    
    public var scanDevices = [[String: Any]]()
    var scanTimer : Timer!
    var scanTimerNum : Int = 0
    var scanTimeout : Int = 0
    
    var isStart: Bool = false
    
    public override init() {
        super.init()
        
        // 初始化 CentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /*
     搜索设备
     @param timeout 超时时间
     @callback  [MXProvisionDeviceInfo] 未配网设备列表
     */
    public func startScan(timeout:Int = 0, callback: @escaping MXScanResultCallback) {
        self.isStart = true
        scanResultCallback = callback
        self.scanTimeout = timeout
        self.setupScanTimer()
        centralManager.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    //停止扫描
    public func stopScan() {
        self.isStart = false
        self.scanTimerNum = 0
        self.scanTimeout = 0
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        centralManager.stopScan()
        self.scanDevices.removeAll()
    }
    
    func setupScanTimer() {
        if self.scanTimer != nil {
            self.scanTimer.fireDate = Date.distantFuture// 计时器暂停
            self.scanTimer.invalidate()
            self.scanTimer = nil
        }
        self.scanTimerNum = 0
        self.scanTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.scanTimerNum += 1
            self.scanDevices.removeAll { (info:[String: Any]) in
                if let time_stamp = info["timeStamp"] as? Double, Date().timeIntervalSince1970 - time_stamp > 60 {  //超过1分钟的设备，作为超时
                    return true
                }
                return false
            }
            if self.scanTimeout > 0, self.scanTimerNum >= self.scanTimeout {
                self.scanResultCallback?(self.scanDevices, true)
                self.stopScan()
                self.scanResultCallback = nil
            } else {
                self.scanResultCallback?(self.scanDevices, false)
            }
        })
    }
}

extension MXDeviceScanManager: CBCentralManagerDelegate {

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let unprovisionedDevice = UnprovisionedDevice(advertisementData: advertisementData) {  //Mesh设备
            
            let uuidString = unprovisionedDevice.uuid.uuidString
            let macStr = MeshSDK.sharedInstance.getDeviceMacAddress(uuid: uuidString).lowercased()
            let productId = MeshSDK.sharedInstance.getDeviceProductId(uuid: uuidString)
            
            var newItem  = ["device":unprovisionedDevice, "uuid": uuidString, "rssi": RSSI.intValue, "name": peripheral.name ?? "","peripheral":peripheral,"mac":macStr,"productId":productId.lowercased(), "timeStamp": Date().timeIntervalSince1970] as [String : Any]
            if var item = self.scanDevices.first(where: { $0["peripheral"] as? CBPeripheral == peripheral } ) {
                item["timeStamp"] = Date().timeIntervalSince1970
            } else {
                scanDevices.append(newItem)
                self.scanResultCallback?(self.scanDevices, false)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kMXDiscoverDevices"), object: nil)
            }

        } else { //蓝牙设备
            if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                let bytesArray = [UInt8](manufacturerData)
                if bytesArray.count >= 14 {
                    let cidStr = String(format: "%02X%02X", bytesArray[1],bytesArray[0])
                    //let maskStr = String(format: "%02X", bytesArray[3])
                    //let fmsk = (Int(maskStr, radix: 16) ?? 0) & 0b00000100
                    if cidStr.uppercased() == "01A8" {  //飞燕未配网
                        let pidStr = String(format: "%02x%02x%02x%02x", bytesArray[7],bytesArray[6],bytesArray[5],bytesArray[4]).lowercased()
                        let macStr = String(format: "%02x:%02x:%02x:%02x:%02x:%02x", bytesArray[13],bytesArray[12],bytesArray[11],bytesArray[10],bytesArray[9],bytesArray[8]).lowercased()
                        var newItem  = ["rssi": RSSI.intValue, "name": peripheral.name ?? "","peripheral":peripheral,"mac":macStr,"productId":pidStr, "timeStamp": Date().timeIntervalSince1970] as [String : Any]
                        if var item = self.scanDevices.first(where: { $0["peripheral"] as? CBPeripheral == peripheral } ) {
                            item["timeStamp"] = Date().timeIntervalSince1970
                        } else {
                            scanDevices.append(newItem)
                            self.scanResultCallback?(self.scanDevices, false)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kMXDiscoverDevices"), object: nil)
                        }
                    } else if cidStr.uppercased() == "0922" {  //mxchip自己的fog设备
                        let pkStr = String(format: "%02x%02x%02x%02x", bytesArray[6],bytesArray[7],bytesArray[8],bytesArray[9]).lowercased()
                        let dnStr = String(format: "%02x%02x%02x%02x", bytesArray[10],bytesArray[11],bytesArray[12],bytesArray[13]).lowercased()
                        var newItem  = ["rssi": RSSI.intValue, "name": peripheral.name ?? "","peripheral":peripheral,"deviceName":dnStr,"productKey":pkStr, "timeStamp": Date().timeIntervalSince1970] as [String : Any]
                        if var item = self.scanDevices.first(where: { $0["peripheral"] as? CBPeripheral == peripheral } ) {
                            item["timeStamp"] = Date().timeIntervalSince1970
                        } else {
                            scanDevices.append(newItem)
                            self.scanResultCallback?(self.scanDevices, false)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kMXDiscoverDevices"), object: nil)
                        }
                    }
                }
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if self.isStart {
                centralManager.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }
        } else {
            
        }
    }
}
