
import Foundation

class MXAddDeviceSelectRoomViewController: MXBaseViewController {
    
    var deviceList = [MXDeviceInfo]()
    var roomList = Array<MXRoomInfo>()
    var headerView : MXSelectedRoomHeaderView!
    
    var roomId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = false
        
        self.title = localized(key:"添加成功")
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle(localized(key:"完成"), for: .normal)
        rightBtn.addTarget(self, action: #selector(actionSure(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.headerView = MXSelectedRoomHeaderView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 90))
        self.headerView.roomId = self.roomId
        self.headerView.didSelectedItemCallback = { [weak self] (room: MXRoomInfo) in
            self?.roomId = room.roomId
            self?.updateAllDeviceInfo(with: room)
        }
        self.headerView.addNewDataCallBack = { [weak self] in
            self?.addNewRoom()
        }
        self.contentView.addSubview(self.headerView)
        self.headerView.pin.left().right().top().height(90)
        
        self.contentView.addSubview(self.collectionView)
        self.collectionView.pin.left(10).right(10).below(of: self.headerView).marginTop(0).bottom()
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7

    }
    
    override func gotoBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.headerView.pin.left().right().top().height(90)
        self.collectionView.pin.left(10).right(10).below(of: self.headerView).marginTop(0).bottom()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
    }
    
    lazy var collectionView: MXCollectionView = {
        let _layout = MXCollectionViewRoundFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        _layout.minimumInteritemSpacing = 16.0
        _layout.minimumLineSpacing = 12.0
        _layout.scrollDirection = .vertical
        _layout.isCalculateHeader = true
        _layout.isCalculateFooter = true
        _layout.isCalculateTypeOpenIrregularitiesCell = true
        _layout.collectionCellAlignmentType = .Left
        
        
        let _collectionview = MXCollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXAddDeviceSelectRoomCell.self, forCellWithReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self))
        
        _collectionview.register(MXAddDeviceRoomHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: MXAddDeviceRoomHeaderView.self))
        _collectionview.register(MXAddDeviceRoomFooterView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: String (describing: MXAddDeviceRoomFooterView.self))
        _collectionview.backgroundColor  = .clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = false
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            _collectionview.contentInsetAdjustmentBehavior = .never
        } else {
            
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        return _collectionview
    }()
    
    func loadRequestData() {
        self.roomList = MXHomeManager.shard.currentHome?.rooms ?? [MXRoomInfo]()
        self.headerView?.roomList = self.roomList
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func updateAllDeviceInfo(with room: MXRoomInfo) {
        self.deviceList.forEach { (device:MXDeviceInfo) in
            device.roomId = room.roomId
            device.roomName = room.name
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func addNewRoom() {
        let alert = MXAlertView(title: localized(key:"房间名称"), placeholder: localized(key:"请输入房间名称"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textfield:UITextField) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } rightButtonCallBack: { (textfield:UITextField) in
            if let name = textfield.text {
                let nameStr = name.trimmingCharacters(in: .whitespaces)
                if self.roomList.first(where: {$0.name == nameStr }) != nil {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    MXToastHUD.showInfo(status: localized(key:"名称重复"))
                    return
                }
                if !nameStr.isValidName() {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    MXToastHUD.showInfo(status: localized(key:"名称长度限制"))
                    return
                }
                let roomInfo = MXHomeManager.shard.createRoom(homeId:(MXHomeManager.shard.currentHome?.homeId ?? 0), name: nameStr)
                MXHomeManager.shard.currentHome?.rooms.append(roomInfo)
                MXHomeManager.shard.updateHomeList()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
                self.loadRequestData()
            }
        }
        alert.show()
    }
    
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
}

extension MXAddDeviceSelectRoomViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.deviceList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.roomList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self), for: indexPath) as! MXAddDeviceSelectRoomCell
        cell.backgroundColor = UIColor.clear
        
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            cell.nameLB.text = roomInfo.name
            if self.deviceList.count > indexPath.section {
                let info = self.deviceList[indexPath.section]
                cell.mxSelected = (roomInfo.roomId == info.roomId)
            }
        } else {
            cell.mxSelected = false
            cell.nameLB.text = "\u{e701}"
            cell.nameLB.textColor = AppUIConfiguration.NeutralColor.primaryText
            cell.bgView.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            if let nameStr = roomInfo.name {
                let titleSize = nameStr.size(withAttributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)])
                let itemSize = CGSize(width: titleSize.width+40, height: 32)
                return itemSize
            }
        }
        
        return CGSize(width: 80, height: 32)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: self.collectionView.frame.size.width, height: 82)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.size.width, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXAddDeviceRoomHeaderView.self), for: indexPath as IndexPath) as! MXAddDeviceRoomHeaderView
            if self.deviceList.count > indexPath.section {
                let info = self.deviceList[indexPath.section]
                reusableview.refreshView(info: info)
                reusableview.infoChangeCallback = { [weak self] (device_info : MXDeviceInfo) in
                    if let dInfo = self?.deviceList.first(where: {$0.isSameFrom(device_info)}) {
                        dInfo.name = device_info.name
                    }
                }
            }
            return reusableview
        } else if kind == UICollectionView.elementKindSectionFooter {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXAddDeviceRoomFooterView.self), for: indexPath as IndexPath) as! MXAddDeviceRoomFooterView
            if self.deviceList.count > indexPath.section {
                let info = self.deviceList[indexPath.section]
                reusableview.refreshView(info: info)
                reusableview.infoChangeCallback = { [weak self] (device_info : MXDeviceInfo) in
                    if let dInfo = self?.deviceList.first(where: {$0.isSameFrom(device_info)}) {
                        dInfo.isFavorite = device_info.isFavorite
                    }
                }
            }
            return reusableview
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            if self.deviceList.count > indexPath.section {
                let info = self.deviceList[indexPath.section]
                info.roomId = roomInfo.roomId
                info.roomName = roomInfo.name
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            self.addNewRoom()
        }
    }
}

extension MXAddDeviceSelectRoomViewController : MXCollectionViewDelegateRoundFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, borderEdgeInsertsForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, configModelForSectionAtIndex section: Int) -> MXCollectionViewRoundConfigModel {
        let model = MXCollectionViewRoundConfigModel.init();
        model.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        model.cornerRadius = 16.0;
        
        return model;
        
    }
}

extension MXAddDeviceSelectRoomViewController {
    @objc func actionSure(sender: UIButton) {
        
        let defaultRoom = MXHomeManager.shard.currentHome?.rooms.first(where: { $0.isDefault })
        for device in self.deviceList {
            if device.roomId != defaultRoom?.roomId {
                defaultRoom?.devices.removeAll(where: {$0.isSameFrom(device)})
                if let roomInfo = MXHomeManager.shard.currentHome?.rooms.first(where: { $0.roomId == device.roomId}) {
                    roomInfo.devices.append(device)
                }
            }
        }
        MXHomeManager.shard.updateHomeList()
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension MXAddDeviceSelectRoomViewController: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXAddDeviceSelectRoomViewController()
        if let list = params["devices"] as? [MXDeviceInfo] {
            controller.deviceList = list
        }
        controller.roomId = params["roomId"] as? Int
        return controller
    }
}
