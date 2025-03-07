
import Foundation
import UIKit
import MJRefresh

class ScenesListViewController: MXBaseViewController {
    
    var oneClickList = [MXSceneInfo]()
    var cloudAutoList = [MXSceneInfo]()
    
    var invalidList = [MXSceneInfo]() 
    var unsynchronizedList = [MXSceneInfo]() 
    
    let tableView = MXBaseTableView(frame: .zero, style: .grouped)
    
    var pageNo : Int = 1
    
    var isShowAnimation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(homeChange), name: NSNotification.Name(rawValue: "kHomeChangeNotification"), object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.all()
        
        let mxEmptyView = MXActionEmptyView(frame: self.tableView.bounds)
        mxEmptyView.imageView.image = UIImage(named: "mx_view_no_scene")
        mxEmptyView.actionBtn.setTitle(localized(key:"添加智能"), for: .normal)
        mxEmptyView.didClickActionCallback = {
            if !MXHomeManager.shard.operationAuthorityCheck() {
                return
            }
            MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/selectSceneType", params: nil)
        }
        self.tableView.emptyView = mxEmptyView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.pin.all()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func homeChange() {
        DispatchQueue.main.async {
            self.refreshData()
        }
    }
    
    func refreshData() {
        self.oneClickList = MXHomeManager.shard.currentHome?.scenes.filter({$0.isValid}) ?? [MXSceneInfo]()
        self.cloudAutoList = MXHomeManager.shard.currentHome?.autoScenes.filter({$0.isValid}) ?? [MXSceneInfo]()
        self.checkExceptionScenes()
        self.tableView.reloadData()
    }
    
    func checkExceptionScenes() {
        self.invalidList.removeAll()
        self.unsynchronizedList.removeAll()
        self.oneClickList.forEach { (scene:MXSceneInfo) in
            if MXSceneManager.checkSceneIsInvalid(scene: scene) {
                self.invalidList.append(scene)
            } else if MXSceneManager.checkSceneHasUnsynchronized(scene: scene) {
                self.unsynchronizedList.append(scene)
            }
        }
        self.cloudAutoList.forEach { (scene:MXSceneInfo) in
            if MXSceneManager.checkSceneIsInvalid(scene: scene) {
                self.invalidList.append(scene)
            } else if MXSceneManager.checkSceneHasUnsynchronized(scene: scene) {
                self.unsynchronizedList.append(scene)
            }
        }
        var statusStr = ""
        if self.invalidList.count > 0 {
            statusStr += String(format: "%d", self.invalidList.count) + localized(key: "个场景已失效")
        }
        if self.unsynchronizedList.count > 0 {
            if  statusStr.count > 0 {
                statusStr += "； "
            }
            statusStr += String(format: "%d", self.unsynchronizedList.count) + localized(key: "个场景未同步")
        }
        if statusStr.count > 0 {
            let headerView = MXSceneListHearderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 56))
            headerView.contentLB.text = statusStr
            headerView.didActionCallback = {
                var params = [String: Any]()
                params["invalids"] = self.invalidList
                params["unsynchronizeds"] = self.unsynchronizedList
                MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/exception", params: params)
            }
            self.tableView.tableHeaderView = headerView
        } else {
            self.tableView.tableHeaderView  = UIView(frame: .zero)
        }
    }
}

extension ScenesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.oneClickList.count
        } else if section == 1 {
            return self.cloudAutoList.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let automationCellIdentifier = "AutomationCellIdentifier"
            var cell = tableView.dequeueReusableCell(withIdentifier: automationCellIdentifier) as? MXAutomationCell
            if cell == nil{
                cell = MXAutomationCell(style: .default, reuseIdentifier: automationCellIdentifier)
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            
            if self.cloudAutoList.count > indexPath.row {
                let info = self.cloudAutoList[indexPath.row]
                cell?.refreshView(info: info)
                cell?.didActionCallback = { (item:MXSceneInfo, isOn:Bool) in
                    info.enable = isOn
                }
                if info.type == "local_auto" {
                    cell?.actionBtn.isHidden = true
                } else {
                    cell?.actionBtn.isHidden = false
                }
            }
            return cell!
        } else {
            let cellIdentifier = "ScenesCellIdentifier"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXScenesCell
            if cell == nil{
                cell = MXScenesCell(style: .default, reuseIdentifier: cellIdentifier)
            }
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
            if self.oneClickList.count > indexPath.row {
                let info = self.oneClickList[indexPath.row]
                cell?.refreshView(info: info)
                cell?.didActionCallback = { (item: MXSceneInfo) in
                    MXSceneManager.shard.didActionScene(scene: item)
                    cell?.showAnimation()
                }
            }
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if self.oneClickList.count > indexPath.row {
                if  !MXHomeManager.shard.operationAuthorityCheck() {
                    return
                }
                let info = self.oneClickList[indexPath.row]
                var params = [String : Any]()
                params["sceneInfo"] = info
                MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
            }
        } else if indexPath.section == 1 {
            if self.cloudAutoList.count > indexPath.row {
                if  !MXHomeManager.shard.operationAuthorityCheck() {
                    return
                }
                let info = self.cloudAutoList[indexPath.row]
                var params = [String : Any]()
                params["sceneInfo"] = info
                MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
            }
        }
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
            if self.oneClickList.count > 0 {
                return 50
            }
        } else if section == 1 {
            if self.cloudAutoList.count > 0 {
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
            if self.oneClickList.count > 0 {
                nameLB.text = localized(key: "手动场景")
            }
        } else if section == 1 {
            if self.cloudAutoList.count > 0 {
                nameLB.text = localized(key: "自动场景")
            }
        }
        header_view.addSubview(nameLB)
        nameLB.pin.left(20).right(20).top().bottom()
        return header_view
    }
    
}
