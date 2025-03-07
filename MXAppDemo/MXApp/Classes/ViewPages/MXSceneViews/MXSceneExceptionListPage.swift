
import Foundation
import UIKit

class MXSceneExceptionListPage: MXBaseViewController {
    
    var invalidList = [MXSceneInfo]() 
    var unsynchronizedList = [MXSceneInfo]() 
    var sceneList = [MXSceneInfo]()
    
    let tableView = MXBaseTableView(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"场景状态")
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无内容")
        self.tableView.emptyView = mxEmptyView
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.all()
    }
    
    func loadDataList() {
        self.sceneList.removeAll()
        if let list = MXHomeManager.shard.currentHome?.scenes.filter({$0.isValid}) {
            self.sceneList.append(contentsOf: list)
        } else if let list = MXHomeManager.shard.currentHome?.autoScenes.filter({$0.isValid}) {
            self.sceneList.append(contentsOf: list)
        }
        self.checkExceptionScenes()
    }
    
    func checkExceptionScenes() {
        self.invalidList.removeAll()
        self.unsynchronizedList.removeAll()
        self.sceneList.forEach { (scene:MXSceneInfo) in
            if MXSceneManager.checkSceneIsInvalid(scene: scene) {
                self.invalidList.append(scene)
            } else if MXSceneManager.checkSceneHasUnsynchronized(scene: scene) {
                self.unsynchronizedList.append(scene)
            }
        }
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.pin.all()
    }
}

extension MXSceneExceptionListPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.unsynchronizedList.count
        } else if section == 1 {
            return self.invalidList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScenesCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXSceneExceptionCell
        if cell == nil{
            cell = MXSceneExceptionCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        if indexPath.section == 1 {
            if self.invalidList.count > indexPath.row {
                let info = self.invalidList[indexPath.row]
                cell?.refreshView(info: info)
                cell?.actionBtn.backgroundColor = UIColor(hex: AppUIConfiguration.MXAssistColor.red.toHexString, alpha: 0.08)
                cell?.actionBtn.setTitleColor(AppUIConfiguration.MXAssistColor.red, for: .normal)
                cell?.actionBtn.setTitle(localized(key: "删除"), for: .normal)
                cell?.didActionCallback = { (itemInfo:MXSceneInfo) in
                    if  !MXHomeManager.shard.operationAuthorityCheck() {
                        return
                    }
                    MXSceneManager.shard.delete(scene: info)
                    let needDevices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: nil, oldScene: info)
                    MXSceneManager.shard.showSyncSettingView(devices: needDevices, scene: info) { isFinish in
                        self.loadDataList()
                    }
                }
            }
        } else {
            if self.unsynchronizedList.count > indexPath.row {
                let info = self.unsynchronizedList[indexPath.row]
                cell?.refreshView(info: info)
                cell?.actionBtn.backgroundColor = UIColor(hex: AppUIConfiguration.MainColor.C0.toHexString, alpha: 0.08)
                cell?.actionBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
                cell?.actionBtn.setTitle(localized(key: "同步"), for: .normal)
                cell?.didActionCallback = { (itemInfo: MXSceneInfo) in
                    if  !MXHomeManager.shard.operationAuthorityCheck() {
                        return
                    }
                    let newInfo = itemInfo
                    newInfo.actions.removeAll { (tca:MXSceneTACItem) in
                        if let params = tca.params as? MXDeviceInfo {
                            if params.objType == 0, !params.isValid {
                                return true
                            } else if params.objType == 1, let nodes = params.subDevices, nodes.count <= 0 {
                                return true
                            }
                        }
                        return false
                    }
                    MXSceneManager.shard.update(scene: newInfo)
                    let devices = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: newInfo, oldScene: nil)
                    MXSceneManager.shard.showSyncSettingView(devices: devices, scene: newInfo) { isFinish in
                        self.loadDataList()
                    }
                }
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0.1))
        footer_view.backgroundColor = UIColor.clear
        
        return footer_view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.unsynchronizedList.count > 0 {
                return 50
            }
        } else if section == 1 {
            if self.invalidList.count > 0 {
                return 50
            }
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        header_view.backgroundColor = .clear
        let nameLB = UILabel(frame: CGRect(x: 20, y: 0, width: self.view.frame.size.width - 40, height: 50))
        nameLB.backgroundColor = .clear
        nameLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        nameLB.textAlignment = .left
        nameLB.text = nil
        if section == 0 {
            if self.unsynchronizedList.count > 0 {
                nameLB.text = localized(key: "未同步场景")
            }
        } else if section == 1 {
            if self.invalidList.count > 0 {
                nameLB.text = localized(key: "已失效场景")
            }
        }
        header_view.addSubview(nameLB)
        nameLB.pin.left(20).right(20).top().bottom()
        return header_view
    }
    
}

extension MXSceneExceptionListPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneExceptionListPage()
        if let invalid_list = params["invalids"] as? [MXSceneInfo] {
            vc.invalidList = invalid_list
        }
        if let unsynchronized_list = params["unsynchronizeds"] as? [MXSceneInfo] {
            vc.unsynchronizedList = unsynchronized_list
        }
        return vc
    }
}
