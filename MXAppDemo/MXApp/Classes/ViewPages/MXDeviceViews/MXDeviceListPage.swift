
import Foundation

class MXDeviceListPage: MXBaseViewController {
    
    public var roomId : Int = 0 
    public var type: Int = 3  
    var dataList = [MXDeviceInfo]()
    
    lazy var collectionView: UICollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.itemSize = CGSize.init(width: (self.view.frame.size.width - 30)/2.0, height: 124)
        _layout.sectionInset = UIEdgeInsets.init(top: 8.0, left: 10.0, bottom: 8.0, right: 10.0)
        _layout.minimumInteritemSpacing = 10.0
        _layout.minimumLineSpacing = 10.0
        _layout.scrollDirection = .vertical
        
        
        let _collectionview = MXCollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXDeviceItemCell.self, forCellWithReuseIdentifier: String (describing: MXDeviceItemCell.self))
        _collectionview.register(MXCollectionHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: MXCollectionHeaderView.self))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(meshConnectChange(notif:)), name: NSNotification.Name(rawValue: "kMeshConnectStatusChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceStatusChangeLocate(notif:)), name: NSNotification.Name(rawValue: "kDeviceLocateStatusChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyChangeLocate(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyChangeFromLocate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(devicePropertyCacheInvalid(notif:)), name: NSNotification.Name(rawValue: "kDevicePropertyCacheInvalidFromLocate"), object: nil)
        
        self.view.backgroundColor = UIColor.clear
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle("\u{e6fa}", for: .normal)
        rightBtn.addTarget(self, action: #selector(gotoDeviceManager), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.collectionView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.collectionView)
        self.collectionView.pin.all()
        
        let mxEmptyView = MXTitleEmptyView(frame: self.collectionView.bounds)
        mxEmptyView.titleLB.text = localized(key:"暂无设备")
        self.collectionView.emptyView = mxEmptyView
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.collectionView.backgroundColor = UIColor.clear
        
        self.refreshDeviceData()
    }
    
    @objc func gotoDeviceManager() {
            var params = [String: Any]()
            params["homeId"] = MXHomeManager.shard.currentHome?.homeId
            params["roomId"] = self.roomId
            params["type"] = self.type
            MXURLRouter.open(url: "com.mxchip.bta/page/device/editList", params: params)
    }
    
    deinit {
        print("页面释放了")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshDeviceData()
    }
    
    func refreshDeviceData() {
        self.dataList = MXDeviceManager.shard.loadDevices(roomId: self.roomId, type: self.type)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    public func scrollToTop() {
        self.collectionView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.pin.all()
        self.collectionView.mj_header?.layoutSubviews()
        self.collectionView.mj_footer?.layoutSubviews()
    }
    
    @objc func meshConnectChange(notif:Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @objc func deviceStatusChangeLocate(notif: Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func refreshTableViewCell(uuidStr:String) {
        if let deviceIndex = self.dataList.firstIndex(where: {$0.meshInfo?.uuid == uuidStr}) {
            DispatchQueue.main.async {
                let device = self.dataList[deviceIndex]
                let cellIndexPath = IndexPath(row: deviceIndex, section: 1)
                if let cell = self.collectionView.cellForItem(at: cellIndexPath) as? MXDeviceItemCell {
                    cell.refreshView(info: device)
                }
            }
        }
    }
    
    @objc func devicePropertyChangeLocate(notif: Notification) {
        
        if let result = notif.object as? [String : Any], let uuidStr = result.keys.first(where: {$0.count > 30}) {
            self.refreshTableViewCell(uuidStr: uuidStr)
        }
    }
    
    @objc func devicePropertyCacheInvalid(notif: Notification) {
        if let uuid = notif.object as? String {
            self.refreshTableViewCell(uuidStr: uuid)
        }
    }
}

extension MXDeviceListPage: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXDeviceItemCell.self), for: indexPath) as! MXDeviceItemCell
        cell.removeAllAnimation()
        cell.setupViews()
        if self.dataList.count > indexPath.row {
            let item = self.dataList[indexPath.row]
            cell.refreshView(info: item)
        }
        
        cell.moreActionCallback = { (info: MXDeviceInfo, url: String?) in
            MXDeviceManager.gotoControlPanel(with: info, testUrl: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width - 30)/2.0, height: 124)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if self.dataList.count > 0 {
            return CGSize(width: self.view.frame.size.width, height: 50)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets.init(top: 8.0, left: 10.0, bottom: 8.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXCollectionHeaderView.self), for: indexPath as IndexPath) as! MXCollectionHeaderView
            reusableview.backgroundColor = .clear
            reusableview.titleLB.text = localized(key:"设备数量") + ":" + String(self.dataList.count)
            reusableview.moreBtn.isHidden = true
            return reusableview
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let item = self.dataList[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) {
                didSelectItem(item: item, cell: cell)
            }
        }
    }
    
    public func didSelectItem(item: MXDeviceInfo, cell: UICollectionViewCell) {
        if item.objType == 1 {  
            guard let subDevices = item.subDevices, subDevices.count > 0 else {
                let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"群组没有设备提示"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
                    
                } rightButtonCallBack: {
                    MXDeviceManager.shard.delete(device: item, isSave:true)
                    self.refreshDeviceData()
                }
                alert.show()
                return
            }
            if let pList = subDevices.first?.properties?.filter({$0.isSupportQuickControl}), let nameStr = item.name {
                let cv = MXGroupControlView(title: nameStr, dataList: pList)
                cv.groupInfo = item
                cv.didOptionCallback = {
                    MXDeviceManager.gotoControlPanel(with: item)
                }
                cv.didSelectedCallback = { (info: MXDeviceInfo, pInfo: MXPropertyInfo) in
                    MXDeviceManager.setProperty(with: info, pInfo: pInfo)
                }
                cv.show()
            }
            return
        }
        if let pList = item.properties?.filter({$0.isSupportQuickControl}), pList.count > 0 {
            if pList.count == 1, let pInfo = pList.first {
                if let deviceCell = cell as? MXDeviceItemCell {
                    deviceCell.showSelectedAnimation();
                }
                MXDeviceManager.setProperty(with: item, pInfo: pInfo)
            } else {
                MXDeviceManager.showLaconic(with: item)
            }
        } else {
            MXDeviceManager.gotoControlPanel(with: item)
        }

    }
    
    func gotoControlPanel(with device: MXDeviceInfo, testUrl:String? = nil) -> Void {
        if device.objType == 1 {
            guard let subDevices = device.subDevices, subDevices.count > 0 else {
                let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"群组没有设备提示"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) {
                    
                } rightButtonCallBack: {
                    MXDeviceManager.shard.delete(device: device, isSave:true)
                    self.refreshDeviceData()
                }
                alert.show()
                return
            }
        }
        MXDeviceManager.gotoControlPanel(with: device, testUrl: testUrl)
    }
}

extension MXDeviceListPage: MXURLRouterDelegate {
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXDeviceListPage()
        return vc
    }
}
