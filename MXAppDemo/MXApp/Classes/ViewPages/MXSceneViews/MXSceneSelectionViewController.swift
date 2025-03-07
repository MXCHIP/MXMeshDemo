
import Foundation
import SDWebImage

class MXSceneSelectionViewController: MXBaseViewController {
    
    var dataList = [MXSceneInfo]()
    var selectedList = [Int]()
    var pageNo : Int = 1
    
    var sceneInfo = MXSceneInfo(type: "local_auto")
    
    @objc func saveButtonAction(sender: UIButton) -> Void {
        
        if let first = self.selectedList.first,  let selectedScene = self.dataList.first(where: {$0.sceneId == first}) {
            let newActions = selectedScene.actions.filter { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo {
                    obj.status = 0
                    obj.writtenStatus = 0
                    if let subDevice = obj.subDevices {
                        subDevice.forEach { (device:MXDeviceInfo) in
                            device.status = 0
                            device.writtenStatus = 0
                        }
                    }
                    return true
                }
                return false
            }
            self.sceneInfo.actions.removeAll { (item:MXSceneTACItem) in
                if let obj = item.params as? MXDeviceInfo, newActions.first(where: { (tac:MXSceneTACItem) in
                    if let tacObj = tac.params as? MXDeviceInfo, tacObj.isSameFrom(obj) {
                        return true
                    }
                    return false
                }) != nil {
                    return true
                }
                return false
            }
            self.sceneInfo.actions.append(contentsOf: newActions)
        }
        
        if let detailVC = self.navigationController?.viewControllers.first(where: {$0.isKind(of: MXSceneDetailPage.self)}) as? MXSceneDetailPage {
            detailVC.info = self.sceneInfo
            self.navigationController?.popToViewController(detailVC, animated: true)
        } else {
            var params = [String : Any]()
            params["sceneInfo"] = self.sceneInfo
            MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
    }
    
    func initSubviews() -> Void {
        self.title = localized(key: "选择场景")
        
        let rightBarButton = UIButton(frame: .zero)
        let font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let color = AppUIConfiguration.NeutralColor.primaryText
        let att = NSAttributedString(string: localized(key: "保存"), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
        rightBarButton.setAttributedTitle(att, for: .normal)
        rightBarButton.addTarget(self, action: #selector(saveButtonAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBarButton)
        rightBarButton.pin.right().top().width(60).height(AppUIConfiguration.navBarH)
        
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无智能")
        self.tableView.emptyView = mxEmptyView
        
        self.contentView.addSubview(tableView)
        self.tableView.pin.all(12)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.pin.all(12)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDataList()
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(MXSceneSelectionViewCell.self, forCellReuseIdentifier: "MXSceneSelectionViewCell")
        return tableView
    }()
    
    func loadDataList() {
        if let list = MXHomeManager.shard.currentHome?.scenes {
            self.dataList = list.filter({$0.isValid})
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MXSceneSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneSelectionViewCell", for: indexPath) as! MXSceneSelectionViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell.info = info
            cell.mxSelected = (self.selectedList.first(where: {$0 == info.sceneId}) != nil) ? true : false
        }
        cell.cellCorner = []
        if indexPath.row == 0 {
            if self.dataList.count == 1 {
                cell.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            } else {
                cell.cellCorner = [.topLeft, .topRight]
            }
        } else if indexPath.row == self.dataList.count - 1 {
            cell.cellCorner = [.bottomLeft, .bottomRight]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if let sceneIndex = self.selectedList.firstIndex(where: {$0 == info.sceneId}) {
                self.selectedList.remove(at: sceneIndex)
            } else {
                if self.sceneInfo.type == "local_auto", self.selectedList.count > 0 { 
                    return
                }
                self.selectedList.append(info.sceneId)
            }
            
            tableView.reloadData()
        }
    }
}

extension MXSceneSelectionViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneSelectionViewController()
        if let list = params["sceneIds"] as? [Int] {
            vc.selectedList = list
        }
        if let info = params["sceneInfo"] as? MXSceneInfo {
            vc.sceneInfo = info
        }
        return vc
    }
    
}
