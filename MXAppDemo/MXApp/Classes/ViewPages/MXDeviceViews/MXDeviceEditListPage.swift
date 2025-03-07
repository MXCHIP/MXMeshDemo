
import Foundation
import MeshSDK


class MXDeviceEditListPage: MXBaseViewController {
    
    public var type = 0
    public var roomId : Int = 0
    var selectedItems = [MXDeviceInfo]()
    public var dataList = [MXDeviceInfo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var footerView : MXListFooterView!
    var renameMenu : [String : Any] = ["name": localized(key:"重命名"),"type":MXDeviceMenuType.MXDeviceMenuType_Rename.rawValue,"enable":false]
    var editMenu : [String : Any] = ["name": localized(key:"删除设备"),"type":MXDeviceMenuType.MXDeviceMenuType_Delete.rawValue,"enable":false]
    var menuList = Array<[String : Any]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = localized(key:"设备管理")
        self.hideBackItem()
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle(localized(key:"完成"), for: .normal)
        rightBtn.addTarget(self, action: #selector(gotoBack), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.contentView.addSubview(self.collectionView)
        self.menuList.append(renameMenu)
        self.menuList.append(editMenu)
        
        self.footerView = MXListFooterView(frame: .zero)
        self.contentView.addSubview(self.footerView)
        self.footerView.dataList = self.menuList
        self.footerView.didActionCallback = { [weak self] (type: Int) in
            if type == MXDeviceMenuType.MXDeviceMenuType_Delete.rawValue {
                let alert = MXAlertView(title: localized(key:"删除设备"), message: localized(key:"是否删除选中设备？删除设备后与设备相关设置将失效"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
                    
                } rightButtonCallBack: {
                    self?.deleteDevices()
                }
                alert.show()
            } else if type == MXDeviceMenuType.MXDeviceMenuType_Rename.rawValue {
                if let info = self?.selectedItems.first {
                    let alertView = MXAlertView(title: localized(key:"设备名称"), placeholder: localized(key:"请输入名称"), text:info.name, leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textField: UITextField) in
                        
                    } rightButtonCallBack: { (textField: UITextField) in
                        guard let text = textField.text?.trimmingCharacters(in: .whitespaces) else {
                            MXToastHUD.showInfo(status: localized(key:"输入不能为空"))
                            return
                        }
                        if let msg = text.toastMessageIfIsInValidDeviceName() {
                            MXToastHUD.showInfo(status: msg)
                            return
                        }
                        info.name = text
                        MXDeviceManager.shard.update(device: info)
                        DispatchQueue.main.async {
                            self?.collectionView.reloadData()
                        }
                    }
                    alertView.show()
                }
            }
        }
        
        self.footerView.pin.left().right().bottom().height(80 + self.view.pin.safeArea.bottom)
        self.collectionView.pin.left().right().top().above(of: self.footerView).marginBottom(0)
        
        let mxEmptyView = MXTitleEmptyView(frame: self.collectionView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无设备")
        self.collectionView.emptyView = mxEmptyView
        
        self.loadDeviceList()
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.collectionView.backgroundColor = UIColor.clear
        self.footerView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
    }
    
    public func loadDeviceList() {
        self.dataList = MXDeviceManager.shard.loadDevices(roomId: self.roomId, type: self.type)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func deleteDevices() {
        for device in self.selectedItems {
            if device.objType == 0, let uuidStr = device.meshInfo?.uuid {
                MeshSDK.sharedInstance.resetNode(uuid: uuidStr)
            }
            MXDeviceManager.shard.delete(device: device, isSave: false)
        }
        MXHomeManager.shard.updateHomeList()
        self.loadDeviceList()
    }
    
    func fetchMenuStatus() {
        if self.selectedItems.count == 1 {
            renameMenu["enable"] = true
            editMenu["enable"] = true
            self.menuList.removeAll()
            self.menuList.append(renameMenu)
            self.menuList.append(editMenu)
        } else if self.selectedItems.count > 1 {
            renameMenu["enable"] = false
            editMenu["enable"] = true
            self.menuList.removeAll()
            self.menuList.append(renameMenu)
            self.menuList.append(editMenu)
        } else {
            renameMenu["enable"] = false
            editMenu["enable"] = false
            self.menuList.removeAll()
            self.menuList.append(renameMenu)
            self.menuList.append(editMenu)
        }
        self.footerView.dataList = self.menuList
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.footerView.pin.left().right().bottom().height(80 + self.view.pin.safeArea.bottom)
        self.collectionView.pin.left().right().top().above(of: self.footerView).marginBottom(0)
    }
    
    lazy var collectionView: UICollectionView = {
        let _layout = MXHeadersFlowLayout()
        _layout.itemSize = CGSize.init(width: (self.view.frame.size.width - 30)/2.0, height: 124)
        _layout.sectionInset = UIEdgeInsets.init(top: 16.0, left: 10.0, bottom: 10.0, right: 10.0)
        _layout.minimumInteritemSpacing = 10.0
        _layout.minimumLineSpacing = 10.0
        _layout.scrollDirection = .vertical
        _layout.sectionHeadersPinToVisibleBounds = true
        
        let _collectionview = UICollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXDeviceItemCell.self, forCellWithReuseIdentifier: String (describing: MXDeviceItemCell.self))
        
        _collectionview.register(MXSelectCollectionHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MXSelectCollectionHeaderView")
        _collectionview.backgroundColor  = UIColor.clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = true
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            _collectionview.contentInsetAdjustmentBehavior = .never
        } else {
            
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        return _collectionview
    }()
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
}

extension MXDeviceEditListPage: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXDeviceItemCell.self), for: indexPath) as! MXDeviceItemCell
        cell.isEdit = true
        cell.setupViews()
        if self.dataList.count > indexPath.row {
            let item = self.dataList[indexPath.row]
            cell.refreshView(info: item)
            cell.mxSelected = (self.selectedItems.first(where: {$0.isSameFrom(item)}) != nil)
        }
        cell.moreActionCallback = { [weak self] (info : MXDeviceInfo, url:String?) in
            let hasItem = (self?.selectedItems.first(where: {$0.isSameFrom(info)}) != nil)
            if hasItem {
                self?.selectedItems.removeAll(where: { $0.isSameFrom(info)})
            } else {
                self?.selectedItems.append(info)
            }
            DispatchQueue.main.async {
                self?.fetchMenuStatus()
                self?.collectionView.reloadData()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let item = self.dataList[indexPath.row]
            if self.selectedItems.contains(item) {
                self.selectedItems.removeAll(where: { $0.isSameFrom(item) })
            } else {
                self.selectedItems.append(item)
            }
            DispatchQueue.main.async {
                self.fetchMenuStatus()
                self.collectionView.reloadData()
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: self.view.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MXSelectCollectionHeaderView", for: indexPath) as! MXSelectCollectionHeaderView
            reusableview.backgroundColor = UIColor.clear
            reusableview.titleLB.text = localized(key:"设备")
            reusableview.isSelected = (self.selectedItems.count == self.dataList.count)
            reusableview.didActionCallback = { () in
                if self.selectedItems.count == self.dataList.count {  
                    self.selectedItems.removeAll()
                } else {
                    self.selectedItems.removeAll()
                    self.selectedItems.append(contentsOf: self.dataList)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.fetchMenuStatus()
                }
            }
            return reusableview
        }
        return UICollectionReusableView()
    }
}

extension MXDeviceEditListPage:MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let controller = MXDeviceEditListPage()
        controller.roomId = (params["roomId"] as? Int) ?? 0
        controller.type = (params["type"] as? Int) ?? 0
        return controller
    }
}
