
import Foundation
import UIKit

class MXRoomCreatePage: MXBaseViewController {
    
    var nameList = Array<[String : Any]>()
    var roomBGColor = "DFE7F2"
    var roomName: String?
    var homeId: Int? = MXHomeManager.shard.currentHome?.homeId
    let colorGradientLayer = CAGradientLayer()
    let nameTF = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setWallpaper(notification:)), name: NSNotification.Name.init("ROOM_SET_WALLPAPER"), object: nil)
        
        self.hidesBottomBarWhenPushed = false
        
        self.title = localized(key:"新建房间")
        
        self.contentView.addSubview(self.collectionView)
        self.collectionView.pin.all()
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(viewTap(sender:)))
        tapView.cancelsTouchesInView = false
        self.collectionView.addGestureRecognizer(tapView)
        
        self.mxNavigationBar.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.collectionView.backgroundColor = UIColor.clear
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.primaryText, for: .normal)
        rightBtn.setTitle(localized(key:"保存"), for: .normal)
        rightBtn.addTarget(self, action: #selector(actionSure), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.collectionView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.pin.all()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadRequestData()
    }
    
    lazy var collectionView: MXCollectionView = {
        let _layout = MaxCellSpacingLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        _layout.minimumInteritemSpacing = 16.0
        _layout.maximumInteritemSpacing = 16.0
        _layout.minimumLineSpacing = 16.0
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: self.view.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXAddDeviceSelectRoomCell.self, forCellWithReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self))
        
        _collectionview.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: UICollectionReusableView.self))
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
    
    private lazy var footerView: UIView = {
        let bgView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 500)
        bgView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        let colorBGView = UIView()
        bgView.addSubview(colorBGView)
        colorBGView.pin.left().right().top().height(60)
        
        let colorTitleLabel = UILabel()
        colorBGView.addSubview(colorTitleLabel)
        colorTitleLabel.text = localized(key: "房间壁纸")
        colorTitleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        colorTitleLabel.textColor = AppUIConfiguration.NeutralColor.title
        colorTitleLabel.pin.left(16).height(20).vCenter().sizeToFit(.height)
        
        let colorArrowLabel = UILabel()
        colorBGView.addSubview(colorArrowLabel)
        colorArrowLabel.text = "\u{e6df}"
        colorArrowLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        colorArrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        colorArrowLabel.pin.right(16).height(20).width(20).vCenter()
        
        self.colorGradientLayer.colors = [UIColor(hex: roomBGColor).cgColor, UIColor(hex: roomBGColor).withAlphaComponent(0.0).cgColor]
        colorGradientLayer.locations = [0.0,1.0]
        colorGradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        colorGradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        colorGradientLayer.cornerRadius = 8
        colorGradientLayer.masksToBounds = true
        
        bgView.layer.addSublayer(colorGradientLayer)
        colorGradientLayer.pin.left(16).top(70).right(16).height(120)
        
        colorBGView.isUserInteractionEnabled = true
        let tapColor = UITapGestureRecognizer(target: self, action: #selector(selectBgColor(sender:)))
        colorBGView.addGestureRecognizer(tapColor)
        
        return bgView
    }()
    
    private lazy var headerView: UIView = {
        let headerV = UIView()
        headerV.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 88)
        headerV.backgroundColor = .clear
        let bgViewName = UIView()
        headerV.addSubview(bgViewName)
        bgViewName.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        bgViewName.pin.left().height(60).width(screenWidth).top(12)
        
        let titleLabel = UILabel()
        bgViewName.addSubview(titleLabel)
        titleLabel.text = localized(key: "房间名称")
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.pin.left(16).height(20).vCenter().sizeToFit(.height).minWidth(64)
        
        bgViewName.addSubview(self.nameTF)
        self.nameTF.placeholder = localized(key:"请输入房间名称")
        self.nameTF.text = self.roomName
        self.nameTF.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        self.nameTF.textColor = AppUIConfiguration.NeutralColor.secondaryText
        self.nameTF.textAlignment = .left
        self.nameTF.delegate = self
        self.nameTF.pin.right(of: titleLabel).marginLeft(24).right(16).height(20).vCenter()
        
        let headerLB = UILabel()
        headerV.addSubview(headerLB)
        
        headerLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        headerLB.textColor = AppUIConfiguration.NeutralColor.secondaryText
        headerLB.pin.left(16).right(16).height(16).below(of: bgViewName).marginTop(16)
        
        return headerV
    }()
    
    
    @objc func selectBgColor(sender: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
        let url = "https://com.mxchip.bta/page/home/room/wallpapers"
        MXURLRouter.open(url: url, params: nil)
    }
    
    @objc func viewTap(sender: UITapGestureRecognizer) -> Void {
        self.view.endEditing(true)
        self.roomName = self.nameTF.text?.trimmingCharacters(in: .whitespaces)
        self.nameTF.text = self.roomName
    }
    
    @objc func setWallpaper(notification: NSNotification) -> Void {
        guard let userInfo = notification.userInfo,
              let color = userInfo["color"] as? String else { return }
        self.roomBGColor = color
        self.colorGradientLayer.colors = [UIColor(hex: roomBGColor).cgColor, UIColor(hex: roomBGColor).withAlphaComponent(0.0).cgColor]
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func loadRequestData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension MXRoomCreatePage:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.nameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXAddDeviceSelectRoomCell.self), for: indexPath) as! MXAddDeviceSelectRoomCell
        
        if self.nameList.count > indexPath.row {
            let roomInfo = self.nameList[indexPath.row]
            if let nameStr = roomInfo["name"] as? String {
                cell.nameLB.text = nameStr
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.nameList.count > indexPath.row {
            let roomInfo = self.nameList[indexPath.row]
            if let nameStr = roomInfo["name"] as? String {
                let titleSize = nameStr.size(withAttributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)])
                let itemSize = CGSize(width: titleSize.width+40, height: 32)
                return itemSize
            }
        }
        
        return CGSize(width: 80, height: 32)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: self.view.frame.size.width, height: 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: 206)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: UICollectionReusableView.self), for: indexPath as IndexPath)
            for v in reusableview.subviews {
                v.removeFromSuperview()
            }
            reusableview.addSubview(self.headerView)
            return reusableview
        } else if kind == UICollectionView.elementKindSectionFooter {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: UICollectionReusableView.self), for: indexPath as IndexPath)
            for v in reusableview.subviews {
                v.removeFromSuperview()
            }
            reusableview.addSubview(self.footerView)
            return reusableview
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.nameList.count > indexPath.row {
            let roomInfo = self.nameList[indexPath.row]
            if let nameStr = roomInfo["name"] as? String {
                self.nameTF.text = nameStr
                self.roomName = nameStr
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
}

extension MXRoomCreatePage: UITextFieldDelegate {
    
    @objc func actionSure() {
        self.view.endEditing(true)
        guard let nameStr = self.roomName, nameStr.count > 0 else {
            MXToastHUD.showInfo(status: localized(key:"请输入房间名称"))
            return
        }
        if MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId})?.rooms.first(where: {$0.name == nameStr }) != nil {
            MXToastHUD.showInfo(status: localized(key:"名称重复"))
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            return
        }
        if !nameStr.isValidName() {
            MXToastHUD.showInfo(status: localized(key:"名称长度限制"))
            return
        }
        
        
        if let homeInfo = MXHomeManager.shard.homeList.first(where: {$0.homeId == self.homeId}) {
            let newRoom = MXHomeManager.shard.createRoom(homeId: homeInfo.homeId, name: nameStr)
            newRoom.bg_color = self.roomBGColor
            
            homeInfo.rooms.append(newRoom)
            MXHomeManager.shard.updateHomeList()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
        }
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.roomName = textField.text?.trimmingCharacters(in: .whitespaces)
        self.nameTF.text = self.roomName
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MXRoomCreatePage: MXURLRouterDelegate {
    static func controller(withParams params: [String : Any]) -> AnyObject {
        let controller = MXRoomCreatePage()
        if let home_id = params["homeId"] as? Int {
            controller.homeId = home_id
        }
        return controller
    }
}
