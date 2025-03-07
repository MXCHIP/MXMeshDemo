
import Foundation

class MXRouterManager: NSObject {
    
    static func registerRouter() {
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/search", module: MXAddDeviceViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/search/search", module: MXAddDeviceSearchViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/provision", module: MXAddDeviceStepViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/wifiPassword", module: MXInputWifiPasswordViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/autoSearch", module: MXAutoSearchViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/deviceInit", module: MXAddDeviceInitViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/settingRoom", module: MXAddDeviceSelectRoomViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/addHelp", module: MXAddDeviceHelpPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/provisionStep", module: MXDeviceProvisionStepPage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/list", module: MXDeviceListPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/detail", module: MXDeviceDetailViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/selectRoom", module: MXDeviceSelectRoomViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/editList", module: MXDeviceEditListPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/plan", module: MXBridgeWebViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/linkage/selectScene", module: MXLinkageSelectedScenePage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/selectSceneType", module: MXSceneSelectedTypePage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/sceneDetail", module: MXSceneDetailPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/selectDevice", module: MXSceneSelectDevicePage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/selectConditionDevice", module: MXSceneSelectConditionDevicePage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/settingProperty", module: MXSceneSettingPropertyPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/editList", module: MXSceneEditListViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/selectedAction", module: MXSceneSelectedActionsPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/oneClickDevicesSwitch", module: MXSceneDevicesSwitchPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/lightScene", module: MXSceneLightScenePage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/lightSceneStencil", module: MXSceneLightSceneStencilPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/scene/exception", module: MXSceneExceptionListPage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/web", module: MXWebViewPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/mine/about", module: MXAboutPage.self)
        
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/list", module: MXHomeListViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/detail", module: MXHomeDetailViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/rooms", module: MXRoomsPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/room/create", module: MXRoomCreatePage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/roomDetails", module: MXRoomDetailsPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/room/wallpaper", module: MXRoomWallpaperPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/room/wallpapers", module: MXWallpapersPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/room/wallpaperPreview", module: MXRoomWallpaperPreviewPage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/bleConnectGuide", module: MXBleMeshConnectGuidePage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/writeRuleFailPage", module: MXWriteRuleFailPage.self)
        
        MXURLRouterService.register(key: "com.mxchip.bta/page/group/selectDevice", module: MXGroupDevicesPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/group_info", module: MXGroupDetailViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/group/selectCategory", module: MXGroupSelectCategoryPage.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/home/groupSetting", module: MXGroupSettingPage.self)
    }
    
}
