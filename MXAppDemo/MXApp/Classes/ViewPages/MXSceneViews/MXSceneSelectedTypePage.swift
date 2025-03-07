
import Foundation
import UIKit

class MXSceneSelectedTypePage: MXBaseViewController {
    
    func createOneClick() -> Void {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        let url = "com.mxchip.bta/page/scene/selectedAction"
        var params = [String : Any]()
        params["sceneInfo"] = MXSceneInfo(type: "one_click")
        MXURLRouter.open(url: url, params: nil)
    }

    func createLocalAuto() -> Void {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        
        var params = [String : Any]()
        params["sceneInfo"] = MXSceneInfo(type: "local_auto")
        MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/selectConditionDevice", params: params)
        
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"创建场景")
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top().bottom()
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(10).right(10).top().bottom()
    }
}

extension MXSceneSelectedTypePage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SceneTypeCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXSceneTypeCell
        if cell == nil{
            cell = MXSceneTypeCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        cell?.iconView.image = nil
        cell?.cellCorner = []
        
        if indexPath.section == 0 {
            cell?.iconView.image = UIImage(named: "mx_scene_click_icon")
            cell?.nameLab.text = localized(key:"手动场景")
            cell?.valueLab.text = localized(key:"一键打开或切换场景，例如：开启客厅的灯")
            cell?.cellCorner = [.topLeft,.topRight,.bottomLeft,.bottomRight]
        } else if indexPath.section == 1 {
            cell?.iconView.image = UIImage(named: "mx_scene_linkage_icon")
            cell?.nameLab.text = localized(key:"本地自动场景")
            cell?.valueLab.text = localized(key:"本地自动场景描述")
            cell?.cellCorner = [.bottomLeft,.bottomRight]
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section ==  1 {
            return 118
        } else {
            return 100
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        
        if indexPath.section == 0 {
            createOneClick()
        } else if indexPath.section == 1 {
            createLocalAuto()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 12.0))
        header_view.backgroundColor = UIColor.clear
        return header_view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_view = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0.1))
        footer_view.backgroundColor = UIColor.clear
        return footer_view
    }
    
}

extension MXSceneSelectedTypePage: MXURLRouterDelegate {
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneSelectedTypePage()
        return vc
    }
}
