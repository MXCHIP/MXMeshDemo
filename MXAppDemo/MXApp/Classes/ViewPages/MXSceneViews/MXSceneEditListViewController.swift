
import Foundation
import MJRefresh
import UIKit


class MXSceneEditListViewController: MXBaseViewController {
    
    public var sceneType : String = "one_click"
    var dataList = [MXSceneInfo]()
    var selectedItems = [MXSceneInfo]()
    
    var footerView : MXListFooterView!
    var editMenu : [String : Any] = [String : Any]()
    var menuList = Array<[String : Any]>()
    
    var snapView: UIView?
    var sourceIndex:IndexPath?
    
    let tableView = MXBaseTableView(frame: .zero, style: UITableView.Style.plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"智能管理")
        self.hideBackItem()
        var noContentMsg = localized(key:"暂无数据")
        let menuName = localized(key:"删除")
        if self.sceneType == "one_click" {
            self.title = localized(key:"场景管理")
            
            noContentMsg = localized(key:"暂无场景")
        } else if self.sceneType == "cloud_auto" || self.sceneType == "local_auto" || self.sceneType == "cloud_auto,local_auto"  {
            self.title = localized(key:"自动化管理")
            
            noContentMsg = localized(key:"暂无自动化")
        }
        
        self.editMenu = ["name": menuName,"type":MXDeviceMenuType.MXDeviceMenuType_Delete.rawValue,"enable":false]
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle(localized(key:"完成"), for: .normal)
        rightBtn.addTarget(self, action: #selector(updateSceneOrder), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 16))
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.contentView.addSubview(self.tableView)
        
        
        self.menuList.append(editMenu)
        
        self.footerView = MXListFooterView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
        self.contentView.addSubview(self.footerView)
        self.footerView.dataList = self.menuList
        self.footerView.didActionCallback = { [weak self] (type: Int) in
            if type == MXDeviceMenuType.MXDeviceMenuType_Delete.rawValue {
                var titleStr = localized(key:"删除智能")
                var msgStr = localized(key:"是否删除选中智能？")
                if self?.sceneType == "one_click" {
                    titleStr = localized(key:"删除场景")
                    msgStr = localized(key:"是否删除选中场景？")
                } else if self?.sceneType == "cloud_auto" || self?.sceneType == "cloud_auto,local_auto" {
                    titleStr = localized(key:"删除自动化")
                    msgStr = localized(key:"是否删除选中自动化？")
                }
                let alert = MXAlertView(title: titleStr, message: msgStr, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
                    
                } rightButtonCallBack: {
                    self?.deleteScenes()
                }
                alert.show()
            }
        }
        self.footerView.pin.left().right().bottom().height(80 + self.view.pin.safeArea.bottom)
        self.tableView.pin.left().right().top().above(of: self.footerView).marginBottom(0)
        
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        mxEmptyView.titleLB.text = noContentMsg
        self.tableView.emptyView = mxEmptyView
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognizer(sender:)))
        longPress.minimumPressDuration = 0.3
        self.tableView.addGestureRecognizer(longPress)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
        self.footerView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        self.loadDataList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.footerView.pin.left().right().bottom().height(80 + self.view.pin.safeArea.bottom)
        self.tableView.pin.left().right().top().above(of: self.footerView).marginBottom(0)
    }
    
    @objc func updateSceneOrder() {
        var list = self.dataList
        if self.sceneType == "one_click" {
            if let delete_list = MXHomeManager.shard.currentHome?.scenes.filter({!$0.isValid}) {
                list.append(contentsOf: delete_list)
            }
            MXHomeManager.shard.currentHome?.scenes = list
        } else {
            if let delete_list = MXHomeManager.shard.currentHome?.autoScenes.filter({!$0.isValid}) {
                list.append(contentsOf: delete_list)
            }
            MXHomeManager.shard.currentHome?.autoScenes = list
        }
        MXHomeManager.shard.updateHomeList()
        self.gotoBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadDataList() {
        if self.sceneType == "one_click" {
            self.dataList = MXHomeManager.shard.currentHome?.scenes.filter({$0.isValid}) ?? [MXSceneInfo]()
        } else {
            self.dataList = MXHomeManager.shard.currentHome?.autoScenes.filter({$0.isValid}) ?? [MXSceneInfo]()
        }
    }
    
    func fetchMenuStatus() {
        let isEnableEdit = self.selectedItems.count > 0 ? true : false
        editMenu["enable"] = isEnableEdit
        self.menuList.removeAll()
        self.menuList.append(editMenu)
        self.footerView.dataList = self.menuList
    }
    
    func deleteScenes() {
        var needSyncDevices = [MXDeviceInfo]()
        let delete_scene = self.selectedItems.first
        self.selectedItems.forEach { (item:MXSceneInfo) in
            let device_list = MXSceneManager.shard.filterNeedWriteRuleDevice(scene: nil, oldScene: item)
            device_list.forEach { (device:MXDeviceInfo) in
                if needSyncDevices.first(where: {$0.isSameFrom(device)}) == nil {
                    needSyncDevices.append(device)
                }
            }
            MXSceneManager.shard.delete(scene: item)
            self.dataList.removeAll(where: {$0.sceneId == item.sceneId})
        }
        MXSceneManager.shard.showSyncSettingView(devices: needSyncDevices, scene: delete_scene) { isFinish in
            self.tableView.reloadData()
        }
        
    }
}

extension MXSceneEditListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScenesCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXSceneEditCell
        if cell == nil{
            cell = MXSceneEditCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell?.refreshView(info: info)
            cell?.mxSelected = (self.selectedItems.first(where: {$0.sceneId == info.sceneId}) != nil) ? true : false
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if let sceneIndex = self.selectedItems.firstIndex(where: {$0.sceneId == info.sceneId}) {
                self.selectedItems.remove(at: sceneIndex)
            } else {
                self.selectedItems.append(info)
            }
            self.fetchMenuStatus()
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 12.0))
        footer_view.backgroundColor = UIColor.clear
        
        return footer_view
    }
    
}

extension MXSceneEditListViewController {
    
    @objc func longPressRecognizer(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.tableView)
        switch sender.state {
        case .began:
            guard let indexPath = self.tableView.indexPathForRow(at: location), let cell = self.tableView.cellForRow(at: indexPath) else {
                print("没有按在cell上面")
                return
            }
            self.snapView = self.customViewWithTargetView(target: cell)
            sourceIndex = indexPath
            var center = cell.center
            self.snapView?.center = center
            self.snapView?.alpha = 0.0
            self.tableView.addSubview(self.snapView!)
            UIView.animate(withDuration: 0.25) {
                center.y = location.y
                self.snapView?.center = center
                self.snapView?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.snapView?.alpha = 1.0
                cell.alpha = 0.0
            } completion: { (finished: Bool) in
                cell.alpha = 0.0
            }
            break
        case .changed:
            if var center = self.snapView?.center {
                center.y = location.y
                self.snapView?.center = center
            }
            if let source_Index = self.sourceIndex, let cell = self.tableView.cellForRow(at: source_Index) {
                cell.alpha = 0.0
            }
            if let indexPath = self.tableView.indexPathForRow(at: location), let source_Index = self.sourceIndex, indexPath != source_Index  {
                let source = self.dataList[source_Index.row]
                self.dataList.remove(at: source_Index.row)
                self.dataList.insert(source, at: indexPath.row)
                self.tableView.moveRow(at: source_Index, to: indexPath)
                self.sourceIndex = indexPath
            }
            break
        default:
            UIView.animate(withDuration: 0.25) {
                if let indexPath = self.tableView.indexPathForRow(at: location), let cell = self.tableView.cellForRow(at: indexPath) {
                    self.snapView?.center = cell.center
                    cell.alpha = 1.0
                }
                self.snapView?.transform = .identity
                self.snapView?.alpha = 0.0
            } completion: { (finished: Bool) in
                self.snapView?.removeFromSuperview()
                self.snapView = nil
            }
            self.sourceIndex = nil
            break
        }
    }
    
    
    func customViewWithTargetView(target:UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(target.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            target.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot = UIImageView.init(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }

}

extension MXSceneEditListViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneEditListViewController()
        if let type = params["sceneType"] as? String {
            vc.sceneType = type
        }
        return vc
    }
    
}
