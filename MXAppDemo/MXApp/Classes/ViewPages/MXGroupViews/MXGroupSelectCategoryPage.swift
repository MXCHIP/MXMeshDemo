
import Foundation


class MXGroupSelectCategoryPage: MXBaseViewController {
    
    var dataList = [MXProductInfo]()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 10))
        tableView.register(MXOTADeviceListCell.self, forCellReuseIdentifier: String(describing: MXOTADeviceListCell.self))
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key:"选择类别")
        
        let mxEmptyView = MXTitleEmptyView(frame: self.tableView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无内容")
        self.tableView.emptyView = mxEmptyView
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.left(10).right(10).top().bottom()
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.tableView.backgroundColor = UIColor.clear
        
        self.mxDataSource()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.pin.left(10).right(10).top().bottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func mxDataSource() {
        self.dataList = MXProductManager.shard.loadGroupProductList()
        self.tableView.reloadData()
    }
}

extension MXGroupSelectCategoryPage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MXSelectCategoryCell.self)) as? MXSelectCategoryCell
        if cell == nil{
            cell = MXSelectCategoryCell(style: .value1, reuseIdentifier: String(describing: MXSelectCategoryCell.self))
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .disclosureIndicator
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cell?.detailTextLabel?.textColor = AppUIConfiguration.NeutralColor.disable
        cell?.detailTextLabel?.text = nil
        cell?.cellCorner = []
        
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            cell?.refreshView(info: info)
        }
        
        let firstCellIndex = 0
        let lastCellIndex = self.dataList.count - 1
        
        if firstCellIndex == lastCellIndex {
            cell?.cellCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        } else if indexPath.row == firstCellIndex {
            cell?.cellCorner = [.topLeft, .topRight]
        } else if indexPath.row == lastCellIndex {
            cell?.cellCorner = [.bottomLeft, .bottomRight]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            let alertView = MXGroupSelectCategoryAlertView()
            alertView.show(in: self.view, category_id: info.category_id) { devices in
                self.createGroup(with: info, devices: devices)
            }
        }
        
    }
    
    func createGroup(with productInfo: MXProductInfo, devices: [MXDeviceInfo]) -> Void {
        let url = "com.mxchip.bta/page/home/groupSetting"
        
        let groupInfo = MXDeviceInfo()
        groupInfo.objType = 1
        groupInfo.category_id = productInfo.category_id
        groupInfo.subDevices = devices
        groupInfo.productKey = productInfo.product_key
        groupInfo.properties = productInfo.properties
        groupInfo.image = "light_group"
        let params = ["device": groupInfo] as [String : Any]
        
        MXURLRouter.open(url: url, params: params)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension MXGroupSelectCategoryPage: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXGroupSelectCategoryPage()
        return controller
    }
}
