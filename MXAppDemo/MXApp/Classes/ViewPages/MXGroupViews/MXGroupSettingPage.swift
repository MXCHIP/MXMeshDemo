
import Foundation
import UIKit

class MXGroupSettingPage: MXBaseViewController {
    
    @objc func saveAction(sender: UIButton) -> Void {
        
        self.updateGroupDevices()
    }
    
    func updateGroupDevices() {
        guard let devices = self.groupInfo.subDevices else { return }
        MXGroupManager.shared.update(with: self.groupInfo, devices: devices) { list in
            if list.count > 0 {
                self.groupInfo.subDevices = list
                MXDeviceManager.shard.add(device: self.groupInfo, isSave: true)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                MXToastHUD.showError(status: localized(key: "创建群组失败"))
            }
        }
    }
    
    @objc func groupDevicesUpdate(sender: Notification) -> Void {
        guard let userInfo = sender.userInfo,
              let devices = userInfo["devices"] as? [MXDeviceInfo]
        else { return }
        
        self.groupInfo.subDevices = devices
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func fetchData() -> Void {
        self.rooms = MXHomeManager.shard.currentHome?.rooms ?? [MXRoomInfo]()
        
        if self.groupInfo.meshInfo == nil {
            if let theFirst = self.rooms.first {
                theFirst.isSelected = true
                self.groupInfo.roomId = theFirst.roomId
            }
            if let nodes = self.groupInfo.subDevices,
               let theFirstDevice = nodes.first,
               let productName = theFirstDevice.productInfo?.name {
                self.groupInfo.name = productName + localized(key: "群组")
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            self.rooms.forEach { room in
                if room.roomId == self.groupInfo.roomId {
                    room.isSelected = true
                } else {
                    room.isSelected = false
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavViews()
        initSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(groupDevicesUpdate(sender:)), name: NSNotification.Name.init(rawValue: "MXGroupDevicesUpdate"), object: nil)
    }
    
    func initNavViews() -> Void {
        self.title = localized(key: "设置群组")
    }
    
    func initSubviews() -> Void {
        self.collectionView.backgroundColor = UIColor.clear
        self.contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MXGroupSettingRoomCell.self, forCellWithReuseIdentifier: "MXGroupSettingRoomCell")
        collectionView.register(MXGroupSettingHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MXGroupSettingHeaderView")
        collectionView.register(MXGroupSettingFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MXGroupSettingFooterView")
        
        self.contentView.addSubview(bottomView)
        bottomView.addSubview(bottomButton)
        bottomView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        bottomButton.setBackgroundColor(color: AppUIConfiguration.MainColor.C0, forState: UIControl.State.normal)
        bottomButton.setTitleColor(AppUIConfiguration.MXColor.white, for: UIControl.State.normal)
        bottomButton.layer.cornerRadius = 25
        
        let att = NSAttributedString(string: localized(key: "保存"), attributes: nil)
        bottomButton.setAttributedTitle(att, for: UIControl.State.normal)
        
        bottomButton.addTarget(self, action: #selector(saveAction(sender:)), for: UIControl.Event.touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        bottomView.pin.left().right().bottom().height(self.view.safeAreaInsets.bottom + 70)
        bottomButton.pin.left(16).top(10).right(16).height(50)
        collectionView.pin.above(of: bottomView).all()
    }
    
    var rooms = [MXRoomInfo]()
    var dataList = [Int:[MXDeviceInfo]]()
    
    var groupInfo = MXDeviceInfo()

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let bottomView = UIView(frame: .zero)
    let bottomButton = UIButton(frame: .zero)

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension MXGroupSettingPage: MXGroupSettingHeaderViewDelegate {
    
    func updated(name: String) {
        self.groupInfo.name = name
    }
    
}

extension MXGroupSettingPage: MXGroupSettingFooterViewDelegate {
    
    func editDevices() {
        let url = "https://com.mxchip.bta/page/group/selectDevice"
        let params = ["device": self.groupInfo]
        
        MXURLRouter.open(url: url, params: params)
    }
    
    func setFavorite(status: Bool) {
        self.groupInfo.isFavorite = status
    }
    
    func createdSuccess() -> Void {
        MXURLRouterUtil.currentTopViewController().navigationController?.popToRootViewController(animated: true)
    }
    
    func createdFaulure() -> Void {
        let alert = MXAlertView(title: localized(key:"提示"), message: localized(key:"创建群组失败"), confirmButtonTitle: localized(key:"确定")) {
            
        }
        alert.show()
    }
    
}

extension MXGroupSettingPage: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MXGroupSettingRoomCell", for: indexPath) as! MXGroupSettingRoomCell
        cell.round(with: .both, rect: CGRect(x: 0, y: 0, width: 80, height: 40), radius: 8)
        if self.rooms.count > indexPath.row {
            let room = self.rooms[indexPath.row]
            cell.info = room
        }
        return cell
    }
    
}

extension MXGroupSettingPage: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MXGroupSettingHeaderView", for: indexPath) as! MXGroupSettingHeaderView
            headerView.delegate = self
            headerView.group = self.groupInfo
            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MXGroupSettingFooterView", for: indexPath) as! MXGroupSettingFooterView
            footerView.delegate = self
            footerView.group = self.groupInfo
            return footerView
        }
                
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.rooms.enumerated().forEach { (index, element) in
            if index == indexPath.row {
                element.isSelected = true
                self.groupInfo.roomId = element.roomId
                self.groupInfo.roomName = element.name
            } else {
                element.isSelected = false
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
}

extension MXGroupSettingPage: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 226)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: screenWidth, height: 160 + self.view.safeAreaInsets.bottom + 70 + 80)
    }
    
}

extension MXGroupSettingPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXGroupSettingPage()
        if let info = params["device"] as? MXDeviceInfo,
           let infoParams = MXDeviceInfo.mx_keyValue(info),
           let groupInfo = MXDeviceInfo.mx_Decode(infoParams) {
            vc.groupInfo = groupInfo
        } else if let infoParams = params["device"] as? [String: Any],
                  let groupInfo = MXDeviceInfo.mx_Decode(infoParams) {
            vc.groupInfo = groupInfo
        }
        return vc
    }
}
