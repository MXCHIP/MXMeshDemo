
import Foundation
import UIKit

class MXSceneLightScenePage: MXBaseViewController {
    
    var sceneInfo = MXSceneInfo(type: "one_click")
    
    @objc func nextAction(sender: UIButton) -> Void {
        guard let list = self.templateInfo.propertys, list.count > 0  else {
            MXToastHUD.showError(status: localized(key: "请选择灯光模版"))
            return
        }
        if self.dataSource.count <= 0 {
            MXToastHUD.showError(status: localized(key: "请选择设备"))
            return
        }
        
        var actions = self.sceneInfo.actions
        
        actions.removeAll { (item:MXSceneTACItem) in
            if let obj = item.params as? MXDeviceInfo, self.devices().first(where: {$0.isSameFrom(obj)}) != nil {
                return true
            }
            return false
        }
        for device in self.devices() {
            let caInfo = MXSceneTACItem()
            var params = MXDeviceInfo()
            if let deviceParams = MXDeviceInfo.mx_keyValue(device), let newDevice = MXDeviceInfo.mx_Decode(deviceParams) {
                params = newDevice
            }
            if device.objType == 0 {  
                caInfo.uri = "mx/action/device/property/set"
            } else if device.objType == 1 { 
                caInfo.uri = "mx/action/group/property/set"
            }
            params.properties = self.propertys
            caInfo.params = params
            actions.append(caInfo)
        }
        self.sceneInfo.actions = actions
        
        if let detailVC = self.navigationController?.viewControllers.first(where: {$0.isKind(of: MXSceneDetailPage.self)}) as? MXSceneDetailPage {
            detailVC.info = self.sceneInfo
            self.navigationController?.popToViewController(detailVC, animated: true)
        } else {
            var params = [String : Any]()
            params["sceneInfo"] = self.sceneInfo
            MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/sceneDetail", params: params)
        }
    }
    
    func addModeAction() -> Void {
        let url = "com.mxchip.bta/page/scene/lightSceneStencil"
        MXURLRouter.open(url: url, params: nil)
    }
    
    func propertysSettingAction() -> Void {
        lightPropertys(with: self.propertys, callback: { propertys in
            let view = MXSceneSettingPropertyView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            view.dataList = propertys
            view.sureActionCallback = { (list: [MXPropertyInfo]) in
                if MXSceneTemplateInfo.checkPropertyIsUpdate(list1: self.propertys, list2: list) {
                    self.dataSource.removeAll()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                self.propertys = list
                self.templateInfo.propertys = list
                if let name = self.templateInfo.name  {
                    self.headerView.refreshUI(with: self.templateInfo)
                } else {
                    self.showAlert(with: list)
                }
            }
            view.show()
        })
    }
    
    func editDevicesAction() -> Void {
        if self.propertys.isEmpty {
            MXToastHUD.showInfo(status: localized(key: "未设置灯光效果"))
            return
        }
        let selectDeviceView = MXSceneSelectDeviceViewV2(frame: .zero)
        selectDeviceView.show(in: self.view, with: self.devices(), properties: self.propertys) { devices in
            self.update(devices: devices)
        }
    }
    
    func update(devices: [MXDeviceInfo]) -> Void {
        var dt = [MXSceneRoomViewModel]()
        
        var set = Set<Int>()
        let filterRoomIDs = devices.map({$0.roomId ?? 0}).filter({set.insert($0).inserted})
        
        filterRoomIDs.forEach { room_id in
            guard let device = devices.first(where: { dvm in
                return dvm.roomId == room_id
            })
            else { return }
            
            let rvm = MXSceneRoomViewModel(from: device)
            dt.append(rvm)
        }
        
        dt = dt.map { rvm -> MXSceneRoomViewModel in
            let roomDevs = devices.filter({$0.roomId == rvm.roomId})
            rvm.devices = roomDevs
            return rvm
        }
        
        self.dataSource = dt
        self.tableView.reloadData()
    }
    
    
    func devices() -> [MXDeviceInfo] {
        let devices = self.dataSource.map({$0.devices}).flatMap({$0})
        return devices
    }
    
    func showAlert(with propertys: [MXPropertyInfo]) -> Void {
        let alert = MXAlertView(title: localized(key: "设置名称"), placeholder: "", leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) { textField in
            
        } rightButtonCallBack: { textField in
            if let text = textField.text?.trimmingCharacters(in: .whitespaces) {
                if let toastMSG = text.toastMessageIfIsInValidHomeName() {
                    MXToastHUD.showInfo(status: toastMSG)
                } else {
                    self.templateInfo.name = text
                    
                    self.headerView.refreshUI(with: self.templateInfo)
                }
            } else {
                MXToastHUD.showInfo(status: localized(key: "输入不能为空"))
            }
        }
        alert.show()
    }
    
    func lightPropertys(with selectedPropertys: [MXPropertyInfo]? = nil, callback: @escaping(_ propertys: [MXPropertyInfo]) -> Void) -> Void {
        let list = MXSceneTemplateInfo.loadLightProperies()
         if let selectedPropertys = selectedPropertys {
             list.forEach { (item:MXPropertyInfo) in
                 if let selectedItem = selectedPropertys.first(where: {$0.identifier == item.identifier}) {
                     item.value = selectedItem.value
                 }
             }
         }
         if let temperature = list.first(where: {$0.identifier == "ColorTemperature"}), temperature.value != nil {
             if let switchProperty = list.first(where: {$0.identifier == "LightSwitch"}) {
                 switchProperty.value = 1 as AnyObject
             }
         } else if let hsv = list.first(where: {$0.identifier == "HSVColorHex" || $0.identifier == "HSVColor"}), hsv.value != nil {
             if let switchProperty = list.first(where: {$0.identifier == "LightSwitch"}) {
                 switchProperty.value = 1 as AnyObject
             }
         }
         callback(list)
    }
    
    @objc func selectedLightSceneStencil(sender: Notification) -> Void {
        if let info = sender.object as? MXSceneTemplateInfo,
           let propertys = info.propertys,
           let name = info.name {
            if MXSceneTemplateInfo.checkPropertyIsUpdate(list1: self.propertys, list2: propertys) {
                self.dataSource.removeAll()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.propertys = propertys
            self.templateInfo = info
            self.headerView.refreshUI(with: self.templateInfo)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key: "灯光场景")
        let rightBarButton = UIButton(frame: .zero)
        let font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let color = AppUIConfiguration.NeutralColor.primaryText
        let att = NSAttributedString(string: localized(key: "下一步"), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
        rightBarButton.setAttributedTitle(att, for: .normal)
        rightBarButton.addTarget(self, action: #selector(nextAction(sender:)), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBarButton)
        rightBarButton.pin.right().top().width(60).height(AppUIConfiguration.navBarH)
        
        initSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedLightSceneStencil(sender:)), name: NSNotification.Name.init(rawValue: "MXSceneLightSceneStencilSelected"), object: nil)
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.contentView.addSubview(headerView)
        self.contentView.addSubview(tableView)
        self.contentView.addSubview(footerView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            
        }
        tableView.register(MXSceneLightSceneTableViewCell.self, forCellReuseIdentifier: "MXSceneLightSceneTableViewCell")
        tableView.register(MXSceneLightSceneTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "MXSceneLightSceneTableSectionHeaderView")
        headerView.round(with: .bottom, rect: CGRect(x: 0, y: 0, width: screenWidth, height: 148), radius: 16)
        headerView.delegate = self
        footerView.delegate = self
        let mxEmptyView = MXTitleEmptyView(frame: tableView.bounds)
        mxEmptyView.titleLB.text = localized(key: "未添加设备\n请添加执行场景的灯")
        tableView.emptyView = mxEmptyView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.pin.top().left().right().height(148)
        footerView.pin.left().right().bottom().height(70 + self.view.safeAreaInsets.bottom)
        tableView.pin.below(of: headerView).above(of: footerView).left().right()
        tableView.emptyView?.pin.all()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let headerView = MXSceneLightSceneHeaderView(frame: .zero)
    let footerView = MXSceneLightSceneFooterView(frame: .zero)
    
    var dataSource = [MXSceneRoomViewModel]()
    var propertys = [MXPropertyInfo]()
    var templateInfo = MXSceneTemplateInfo()
    
}

extension MXSceneLightScenePage: MXSceneLightSceneHeaderViewDelegate {
    
    func addMode() -> Void {
        addModeAction()
    }
    
    func propertysSetting() -> Void {
        propertysSettingAction()
    }
    
}

extension MXSceneLightScenePage: MXSceneLightSceneFooterViewDelegate {
    
    func editDevices() {
        editDevicesAction()
    }
    
}

extension MXSceneLightScenePage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSource.count > section {
            let room = self.dataSource[section]
            return room.devices.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneLightSceneTableViewCell", for: indexPath) as! MXSceneLightSceneTableViewCell
        if self.dataSource.count > indexPath.section {
            let room = self.dataSource[indexPath.section]
            if room.devices.count > indexPath.row {
                let device = room.devices[indexPath.row]
                cell.device = device
                
                if room.devices.count == 1 {
                    cell.round(with: .both, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                } else {
                    if indexPath.row == 0 {
                        cell.round(with: .top, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                    } else if indexPath.row == room.devices.count - 1 {
                        cell.round(with: .bottom, rect: CGRect(x: 10, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
                    } else {
                        cell.removeRound()
                    }
                }
                
            }
        }
        return cell
    }
    
}

extension MXSceneLightScenePage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MXSceneLightSceneTableSectionHeaderView") as! MXSceneLightSceneTableSectionHeaderView
        if self.dataSource.count > section {
            let room = self.dataSource[section]
            view.room = room
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension MXSceneLightScenePage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneLightScenePage()
        if let info = params["sceneInfo"] as? MXSceneInfo {
            vc.sceneInfo = info
        }
        return vc
    }
    
}

protocol MXSceneLightSceneHeaderViewDelegate {
    
    func addMode() -> Void
    
    func propertysSetting() -> Void
    
}

class MXSceneLightSceneHeaderView: UIView {
    
    func refreshUI(with info: MXSceneTemplateInfo) {
        guard let propertys = info.propertys else {
            return
        }
        let atts = propertys.filter({$0.valueAttributedString() != nil}).map({$0.valueAttributedString()!})
        let propertysAtt = NSMutableAttributedString()
        atts.forEach { att in
            propertysAtt.append(att)
        }
        self.settingLabel.attributedText = propertysAtt
        self.titleLabel.text = info.name
        
        var colors = AppUIConfiguration.MXLightSceneColor.blue
        if let colorProperty = propertys.first(where: {$0.identifier == "HSVColorHex"}),
            let value = colorProperty.value as? Int32 {
            
            let hue = MXHSVColorHandle.getHueromColorHex(value: value)
            let index = Int(floor(Double(hue) / (360.0 / 7)))
            
            switch index {
            case 0:
                colors = AppUIConfiguration.MXLightSceneColor.red
            case 1:
                colors = AppUIConfiguration.MXLightSceneColor.orange
            case 2:
                colors = AppUIConfiguration.MXLightSceneColor.yellow
            case 3:
                colors = AppUIConfiguration.MXLightSceneColor.green
            case 4:
                colors = AppUIConfiguration.MXLightSceneColor.cyan
            case 5:
                colors = AppUIConfiguration.MXLightSceneColor.blue
            case 6:
                colors = AppUIConfiguration.MXLightSceneColor.purple
            default:
                break
            }
        }
        guard colors.count > 1 else {
            return
        }
        self.titleLabel.textColor = colors[0]
        self.detailsView.backgroundColor = colors[1]
        
        self.layoutSubviews()
    }
    
    
    @objc func addMode(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.addMode()
    }
    
    @objc func propertysSetting(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.propertysSetting()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.addSubview(tipsLabel)
        self.addSubview(addView)
        addView.addSubview(addTitleLabel)
        addView.addSubview(addIconLabel)
        tipsLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        tipsLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        addTitleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H5)
        addTitleLabel.textColor = AppUIConfiguration.MainColor.C0
        addIconLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H5)
        addIconLabel.textColor = AppUIConfiguration.MainColor.C0
        self.addSubview(detailsView)
        detailsView.addSubview(titleLabel)
        detailsView.addSubview(settingLabel)
        detailsView.addSubview(arrowLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = UIColor(hex: "262626")
        settingLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        settingLabel.textColor = UIColor(hex: "8C8C8C")
        arrowLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H4)
        arrowLabel.textColor = UIColor(hex: "BFBFBF")
        
        tipsLabel.text = localized(key: "设置灯光效果")
        addTitleLabel.text = localized(key: "常用模式")
        addIconLabel.text = localized(key: "\u{e757}")
        titleLabel.text = localized(key: "未设置灯光效果")
        settingLabel.text = localized(key: "去设置")
        arrowLabel.text = "\u{e6df}"
        
        detailsView.layer.cornerRadius = 16
        detailsView.layer.masksToBounds = true
        detailsView.backgroundColor = UIColor(hex: "D9F8FF")
        
        let addModeTap = UITapGestureRecognizer(target: self, action: #selector(addMode(sender:)))
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(addModeTap)
        
        let propertysSettingsTap = UITapGestureRecognizer(target: self, action: #selector(propertysSetting(sender:)))
        detailsView.isUserInteractionEnabled = true
        detailsView.addGestureRecognizer(propertysSettingsTap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tipsLabel.pin.left(20).top(20).sizeToFit()
        addTitleLabel.pin.sizeToFit()
        addIconLabel.pin.after(of: addTitleLabel, aligned: .center).width(16).height(16).marginLeft(8)
        addView.pin.wrapContent().right(20).top(20)
        detailsView.pin.top(58).left(10).right(10).height(80)
        titleLabel.pin.left(16).vCenter().sizeToFit()
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
        settingLabel.pin.before(of: arrowLabel, aligned: .center).marginRight(4).sizeToFit()
    }
    
    let tipsLabel = UILabel(frame: .zero)
    let addView = UIView(frame: .zero)
    let addTitleLabel = UILabel(frame: .zero)
    let addIconLabel = UILabel(frame: .zero)
    let detailsView = UIView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let arrowLabel = UILabel(frame: .zero)
    let settingLabel = UILabel(frame: .zero)
    
    var delegate: MXSceneLightSceneHeaderViewDelegate?
    
}

protocol MXSceneLightSceneFooterViewDelegate {
    
    func editDevices() -> Void
    
}

class MXSceneLightSceneFooterView: UIView {
    
    @objc func buttonAction(sender: UIButton) -> Void {
        self.delegate?.editDevices()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.addSubview(button)
        
        let font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H3) ?? UIFont()
        let color = AppUIConfiguration.MXColor.white
        let att = NSAttributedString(string: localized(key: "添加/移除设备"), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
        button.setAttributedTitle(att, for: UIControl.State.normal)
        button.backgroundColor = AppUIConfiguration.MainColor.C0
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.pin.top(10).left(16).right(16).height(50)
    }
    
    let button = UIButton(frame: .zero)
    var delegate: MXSceneLightSceneFooterViewDelegate?
}

class MXSceneLightSceneTableViewCell: UITableViewCell {
    
    var device: MXDeviceInfo? {
        didSet {
            if let newObj = device {
                if let image = newObj.image {
                    self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
                } else if let image = newObj.productInfo?.image {
                    self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: image))
                }
                self.nameLabel.text = newObj.showName
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.selectionStyle = .none
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        imgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(nameLabel)
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.pin.left(16).vCenter().width(40).height(40)
        nameLabel.pin.after(of: imgView, aligned: .center).marginLeft(16).sizeToFit()
    }
    
    let imgView = UIImageView(frame: .zero)
    let nameLabel = UILabel(frame: .zero)
    
}

class MXSceneLightSceneTableSectionHeaderView: UITableViewHeaderFooterView {
    
    var room: MXSceneRoomViewModel? {
        didSet {
            guard let room = room else {
                return
            }
            self.nameLabel.text = room.name
        }

    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(nameLabel)
        nameLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.pin.left(16).vCenter().marginLeft(16).sizeToFit()
    }
    
    let nameLabel = UILabel(frame: .zero)
}
