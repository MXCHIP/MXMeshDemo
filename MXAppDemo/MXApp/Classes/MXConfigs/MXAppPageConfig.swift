
import Foundation

class MXAppPageConfig: NSObject {
    public static var shard = MXAppPageConfig()
    
    var Provisioning_Batch_MaxDevices: Int = 30
    var Provisioning_Batch_ParallelNum: Int = 1
    
    var Provisioning_Need_Auth: Bool = false  //是否需要获取三元组
    var Provisioning_Need_Version: Bool = true  //是否需要获取固件版本号
    
}
