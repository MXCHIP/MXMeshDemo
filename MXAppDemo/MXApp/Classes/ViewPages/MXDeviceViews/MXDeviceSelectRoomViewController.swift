
import Foundation

class MXDeviceSelectRoomViewController: MXBaseViewController {
    
    var deviceInfo: MXDeviceInfo?
    var selectedRoomId : Int?
    var selectedRoomName : String?
    
    var isFavorite = false
    var nickName : String? = nil
    
    var roomList = Array<MXRoomInfo>()
    var headerView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hidesBottomBarWhenPushed = false
        
        self.title = localized(key:"选择房间")
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(70)
        self.bottomView.addSubview(self.nextBtn)
        self.nextBtn.pin.left(16).right(16).height(50).vCenter()
        
        self.contentView.addSubview(self.collectionView)
        self.collectionView.pin.above(of: self.bottomView).marginBottom(10).left().top(20).right(20)
        
        self.selectedRoomId = self.deviceInfo?.roomId
        self.selectedRoomName = self.deviceInfo?.roomName
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.collectionView.backgroundColor = UIColor.clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.bottomView.pin.left().right().bottom().height(70 + self.view.pin.safeArea.bottom)
        self.nextBtn.pin.left(16).right(16).height(50).top(10)
        self.collectionView.pin.above(of: self.bottomView).marginBottom(10).left().top().right()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
    }
    
    lazy var collectionView: MXCollectionView = {
        let _layout = MaxCellSpacingLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        _layout.minimumInteritemSpacing = 8.0
        _layout.maximumInteritemSpacing = 8.0
        _layout.minimumLineSpacing = 24.0
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXAddDeviceSelectRoomCell.self, forCellWithReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self))
        
        _collectionview.register(MXCollectionHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: MXCollectionHeaderView.self))
        _collectionview.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: String (describing: UICollectionReusableView.self))
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
    
    private lazy var bottomView : UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70))
        _bottomView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        _bottomView.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        _bottomView.layer.shadowOffset = CGSize.zero
        _bottomView.layer.shadowOpacity = 1
        _bottomView.layer.shadowRadius = 8
        return _bottomView
    }()
    
    lazy var nextBtn : UIButton = {
        let _nextBtn = UIButton(type: .custom)
        _nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H3)
        _nextBtn.setTitle(localized(key:"完成"), for: .normal)
        _nextBtn.setTitleColor(AppUIConfiguration.MXColor.white, for: .normal)
        _nextBtn.backgroundColor = AppUIConfiguration.MainColor.C0
        _nextBtn.layer.cornerRadius = 25
        _nextBtn.addTarget(self, action: #selector(actionSure), for: .touchUpInside)
        return _nextBtn
    }()
    
    func loadRequestData() {
        if let list = MXHomeManager.shard.currentHome?.rooms {
            self.roomList = list
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        print("页面释放了")
    }
}

extension MXDeviceSelectRoomViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.roomList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self), for: indexPath) as! MXAddDeviceSelectRoomCell
        
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            cell.nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
            cell.nameLB.text = roomInfo.name
            cell.mxSelected = (roomInfo.roomId == self.selectedRoomId)
        } else {
            cell.mxSelected = false
            cell.nameLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
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
        return CGSize(width: self.view.frame.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXCollectionHeaderView.self), for: indexPath as IndexPath) as! MXCollectionHeaderView
            reusableview.titleLB.text = localized(key:"选择房间")
            reusableview.moreBtn.isHidden = true
            reusableview.titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
            return reusableview
        } else if kind == UICollectionView.elementKindSectionFooter {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: UICollectionReusableView.self), for: indexPath as IndexPath)
            reusableview.backgroundColor = UIColor.clear
            return reusableview
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.roomList.count > indexPath.row {
            let roomInfo = self.roomList[indexPath.row]
            self.selectedRoomId = roomInfo.roomId
            self.selectedRoomName = roomInfo.name
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            let alert = MXAlertView(title: localized(key:"房间名称"), placeholder: localized(key:"请输入房间名称"), leftButtonTitle: localized(key:"取消"), rightButtonTitle: localized(key:"确定")) { (textfield:UITextField) in
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } rightButtonCallBack: { (textfield:UITextField) in
                guard let text = textfield.text?.trimmingCharacters(in: .whitespaces) else {
                    MXToastHUD.showInfo(status: localized(key: "输入不能为空"))
                    return
                }
                if let msg = text.toastMessageIfIsInValidRoomName() {
                    MXToastHUD.showInfo(status: msg)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    return
                }
                if self.roomList.first(where: {$0.name == text }) != nil {
                    MXToastHUD.showInfo(status: localized(key:"该名称已存在，请重新命名"))
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    return
                }
                let roomInfo = MXHomeManager.shard.createRoom(homeId:(MXHomeManager.shard.currentHome?.homeId ?? 0), name: text)
                MXHomeManager.shard.currentHome?.rooms.append(roomInfo)
                MXHomeManager.shard.updateHomeList()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
                self.loadRequestData()
            }
            alert.show()
        }
    }
}

extension MXDeviceSelectRoomViewController {
    @objc func actionSure() {
        if let device = self.deviceInfo, self.selectedRoomId != device.roomId {
            device.roomId = self.selectedRoomId
            device.roomName = self.selectedRoomName
            if device.objType == 1 {
                device.subDevices?.forEach({ (item:MXDeviceInfo) in
                    item.roomId = self.selectedRoomId
                    item.roomName = self.selectedRoomName
                })
            }
            MXHomeManager.shard.currentHome?.rooms.forEach({ (info:MXRoomInfo) in
                info.devices.removeAll(where: {$0.isSameFrom(device)})
                if info.roomId == self.selectedRoomId {
                    info.devices.append(device)
                }
            })
            MXHomeManager.shard.updateHomeList()
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension MXDeviceSelectRoomViewController: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXDeviceSelectRoomViewController()
        if let info = params["device"] as? MXDeviceInfo {
            controller.deviceInfo = info
        }
        return controller
    }
}
