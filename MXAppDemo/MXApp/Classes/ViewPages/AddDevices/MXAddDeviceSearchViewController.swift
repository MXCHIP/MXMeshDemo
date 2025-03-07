
import Foundation
import UIKit

class MXAddDeviceSearchViewController: MXBaseViewController {
    
    var roomId: Int?
    
    @objc func cancelButtonAction(sender: UIButton) -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clearTapAction(sender: UITapGestureRecognizer) -> Void {
        let alert = MXAlertView(title: localized(key: "清除搜索历史"), message: localized(key: "是否确定清除搜索历史？"), leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) {
            
        } rightButtonCallBack: {
            
            self.clearHistory()
            self.historySource.removeAll()
            
            self.editingChanged(sender: self.searchTextField)
        }

        alert.show()
    }
    
    @objc func editingChanged(sender: UITextField) -> Void {
        guard let text = sender.text else { return }
        
        var title = ""
        var titleIsHidden = true
        
        if text.count == 0 {
            self.dataSource = self.historySource
            title = localized(key: "搜索历史")
            titleIsHidden = dataSource.count == 0
        } else {
            self.matchSource = self.productSource.filter { (productInfo: MXProductInfo) in
                if let name = productInfo.name {
                    if name.contains(text) {
                        return true
                    }
                }
                return false
            }
            self.dataSource = self.matchSource
            title = localized(key: "搜索结果")
            titleIsHidden = false
        }
        self.historyView.isHidden = titleIsHidden
        self.historyLabel.text = title
        self.historyLabel.sizeToFit()
        self.historyIcon.isHidden = text.count != 0
        self.tableView.reloadData()
        
        if text.count > 0 {
            if self.matchSource.count > 0 {
                self.tableView.hideEmptyView()
            } else {
                self.tableView.showEmptyView()
            }
        } else {
            self.tableView.hideEmptyView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavViews()
        self.productSource = self.products()
        if let historySource = searchHistoryModel() {
            self.historySource = historySource
        }
        initSubViews()
        self.editingChanged(sender: self.searchTextField)
        self.searchTextField.becomeFirstResponder()
    }
    
    func initNavViews() -> Void {
        self.mxNavigationBar.titleLB.addSubview(searchTextField)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        leftView.addSubview(searchIcon)
        searchIcon.text = "\u{e727}"
        searchIcon.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H3)
        searchIcon.textColor = AppUIConfiguration.NeutralColor.disable
        searchTextField.placeholder = localized(key: "请输入设备名称等关键词")
        searchTextField.backgroundColor = AppUIConfiguration.backgroundColor.level4.F5F5F5
        searchTextField.textColor = AppUIConfiguration.NeutralColor.title
        searchTextField.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        searchTextField.layer.cornerRadius = 20
        searchTextField.addTarget(self, action: #selector(editingChanged(sender:)), for: UIControl.Event.editingChanged)
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .whileEditing
        let cancelButton = UIButton()
        let cancelButtonAtt = NSAttributedString(string: localized(key: "取消"), attributes: [NSAttributedString.Key.font : UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont(), NSAttributedString.Key.foregroundColor: AppUIConfiguration.NeutralColor.primaryText])
        cancelButton.setAttributedTitle(cancelButtonAtt, for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.mxNavigationBar.rightView.addSubview(cancelButton)
        cancelButton.pin.width(50).height(40).center()
        
        self.hideBackItem()
    }
    
    func initSubViews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.contentView.addSubview(historyView)
        historyView.backgroundColor = UIColor.clear
        historyView.addSubview(historyLabel)
        historyLabel.text = localized(key: "搜索历史")
        historyLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        historyLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        historyView.addSubview(historyIcon)
        historyIcon.text = "\u{e759}"
        historyIcon.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H3)
        historyIcon.textColor = AppUIConfiguration.NeutralColor.disable
        let clearTap = UITapGestureRecognizer(target: self, action: #selector(clearTapAction(sender:)))
        historyIcon.isUserInteractionEnabled = true
        historyIcon.addGestureRecognizer(clearTap)
        self.contentView.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MXAddDeviceSearchTableViewCell.self, forCellReuseIdentifier: "MXAddDeviceSearchTableViewCell")
        tableView.separatorStyle = .none
        let mxEmptyView = MXTitleEmptyView(frame: .zero)
        mxEmptyView.titleLB.text = localized(key:"无搜索结果")
        self.tableView.emptyView = mxEmptyView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        searchTextField.pin.left(0).bottom(2).height(40).right(0)
        leftView.pin.width(48).height(40)
        searchIcon.pin.width(17).height(17).vCenter().right(9)
        historyView.pin.left().right().height(50)
        historyLabel.pin.left(16).vCenter().sizeToFit()
        historyIcon.pin.right(23).width(18).height(18).vCenter()
        tableView.pin.below(of: historyView).all(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        if let emptyView = tableView.emptyView {
            emptyView.pin.all()
        }
    }
    
    func products() -> [MXProductInfo] {
        var products = [MXProductInfo]()
        
        MXProductManager.shard.categoryList.forEach { (categoryLeve1: MXCategoryInfo) in
            categoryLeve1.categorys?.forEach({ categoryLeve2 in
                categoryLeve2.products?.forEach({ productInfo in
                    products.append(productInfo)
                })
            })
        }
        
        return products
    }
    
    func searchHistory() -> [[String: Any]]? {
        if let history = UserDefaults.standard.value(forKey: "MXUserDefaultsSearchHistory") as? [[String: Any]] {
            return history
        }
        return nil
    }
    
    func searchHistoryModel() -> [MXProductInfo]? {
        if let history = searchHistory() {
            let models = history.map { (element: [String : Any]) -> MXProductInfo in
                return MXProductInfo.mx_Decode(element) ?? MXProductInfo()
            }
            return models
        }
        
        return nil
    }
    
    func clearHistory() -> Void {
        UserDefaults.standard.removeObject(forKey: "MXUserDefaultsSearchHistory")
    }
    
    func updateSearchHistory(with product: MXProductInfo) -> Void {
        guard let product_id = product.product_id else { return }
        
        var newHistory = [[String: Any]]()
        
        let productInfo: [String : Any] = ["category_id": product.category_id,
                                           "product_key": product.product_key ?? "",
                                           "share_type": product.share_type,
                                           "sharing_mode": product.sharing_mode,
                                           "product_id": product_id,
                                           "name": product.name ?? "",
                                           "image": product.image ?? "",
                                           "link_type_id": product.link_type_id,
                                           "cloud_platform": product.cloud_platform]
        
        if let history = searchHistory() {
            newHistory = history.filter { (element: [String : Any]) in
                if let element_id = element["product_id"] as? String {
                    if element_id == product_id {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            }
        }
        
        newHistory.append(productInfo)
        
        UserDefaults.standard.set(newHistory, forKey: "MXUserDefaultsSearchHistory")
    }
    
    
    let searchTextField: UITextField = UITextField()
    let leftView = UIView()
    let searchIcon = UILabel()
    let historyView = UIView()
    let historyLabel = UILabel()
    let historyIcon = UILabel()
    let tableView = UITableView()
    
    var productSource = [MXProductInfo]()
    var historySource = [MXProductInfo]()
    var matchSource = [MXProductInfo]()
    var dataSource = [MXProductInfo]()
    
}

extension MXAddDeviceSearchViewController: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXAddDeviceSearchViewController()
        vc.roomId = params["roomId"] as? Int
        return vc
    }
    
}

extension MXAddDeviceSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}


extension MXAddDeviceSearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXAddDeviceSearchTableViewCell", for: indexPath) as! MXAddDeviceSearchTableViewCell
        if self.dataSource.count > indexPath.row {
            let product = self.dataSource[indexPath.row]
            cell.updateSubviews(with: ["image": product.image ?? "", "name": product.name ?? ""])
        }
        let count = self.dataSource.count
        if count == 1 {
            cell.corner(byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radii: 16)
        } else {
            if indexPath.row == 0 {
                cell.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
            } else if indexPath.row == count - 1{
                cell.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 16)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTextField.endEditing(true)
        
        if self.dataSource.count > indexPath.row {
            let product = self.dataSource[indexPath.row]
            updateSearchHistory(with: product)
            if let historySource = searchHistoryModel() {
                self.historySource = historySource
            }
            nextPage(with: product)
        }
    }
    
    func nextPage(with productInfo: MXProductInfo) -> Void {
        guard let networkKey = MXHomeManager.shard.currentHome?.networkKey else { return }
        
        if productInfo.link_type_id == 7 || productInfo.link_type_id == 8 {
            var params = [String :Any]()
            params["networkKey"] = networkKey
            params["productInfo"] = productInfo
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/deviceInit", params: params)
            
        } else {
            var params = [String :Any]()
            params["networkKey"] = networkKey
            params["isSkip"] = false
            if productInfo.link_type_id == 11  {
                params["isSkip"] = true
            }
            params["productInfo"] = productInfo
            params["roomId"] = self.roomId
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/wifiPassword", params: params)
        }
    }
    
}

extension MXAddDeviceSearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
}

class MXAddDeviceSearchTableViewCell: MXTableViewCell {
    
    override func updateSubviews(with data: [String : Any]) {
        guard let image = data["image"] as? String,
              let name = data["name"] as? String else { return }
        
        self.productImageView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image), completed: nil)
        self.titleLabel.text = name
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func initSubViews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.contentView.addSubview(productImageView)
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        self.contentView.addSubview(arrowLabel)
        arrowLabel.text = "\u{e6df}"
        arrowLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productImageView.pin.left(16).width(40).height(40).vCenter()
        titleLabel.pin.after(of: productImageView, aligned: .center).marginLeft(16).width(200).height(20)
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
    }
    
    let productImageView = UIImageView()
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    
}
