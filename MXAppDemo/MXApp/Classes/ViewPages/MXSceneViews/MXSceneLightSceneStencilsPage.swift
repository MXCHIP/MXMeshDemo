
import Foundation
import UIKit

class MXSceneLightSceneStencilPage: MXBaseViewController {
    
    func showPropertyView(with info: MXSceneTemplateInfo? = nil) -> Void {
        self.lightPropertys(with: info?.propertys, callback: { propertys in
            let view = MXSceneSettingPropertyView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            view.dataList = propertys
            view.sureActionCallback = { (list: [MXPropertyInfo]) in
                if let templateId = info?.id, let oldName = info?.name {
                    self.updateLightSceneStencil(id: templateId, name: oldName, propertys: list)
                } else {
                    self.showAlert(with: list, oldInfo: info)
                }

            }
            view.show()
        })
        
    }
    
    func showAlert(with propertys: [MXPropertyInfo], oldInfo: MXSceneTemplateInfo? = nil) -> Void {
        let alert = MXAlertView(title: localized(key: "设置名称"), placeholder: "", leftButtonTitle: localized(key: "取消"), rightButtonTitle: localized(key: "确定")) { textField in
            
        } rightButtonCallBack: { textField in
            if let text = textField.text?.trimmingCharacters(in: .whitespaces) {
                if let toastMSG = text.toastMessageIfIsInValidHomeName() {
                    MXToastHUD.showInfo(status: toastMSG)
                } else {
                    if let templateId = oldInfo?.id, templateId > 0 {
                        self.updateLightSceneStencil(id: templateId, name: text, propertys: propertys)
                    } else {
                        self.createLightSceneStencil(name: text, propertys: propertys)
                    }
                }
            } else {
                MXToastHUD.showInfo(status: localized(key: "输入不能为空"))
            }
        }
        alert.show()
    }
    
    func createLightSceneStencil(name: String, propertys: [MXPropertyInfo]) -> Void {
        let info = MXSceneTemplateInfo()
        var lastId = 1
        if let last = MXSceneManager.shard.lightTemplateList.last {
            if last.id > lastId {
                lastId = last.id + 1
            }
        }
        info.id = lastId
        info.name = name
        info.propertys = propertys
        MXSceneManager.shard.lightTemplateList.append(info)
        MXSceneManager.shard.updateLightTemplateList()
        self.fetchData()
    }
    
    func updateLightSceneStencil(id: Int, name: String, propertys: [MXPropertyInfo]) -> Void {
        if let info = MXSceneManager.shard.lightTemplateList.first(where: {$0.id == id}) {
            info.name = name
            info.propertys = propertys
        }
        MXSceneManager.shard.updateLightTemplateList()
        self.fetchData()
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
    
    func fetchData() -> Void {
        self.dataSource = MXSceneManager.shard.lightTemplateList
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = localized(key: "模板管理")
        initSubviews()
        fetchData()
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        self.contentView.addSubview(tipsLabel)
        tipsLabel.text = localized(key: "模板列表（点击选择使用的模板）")
        self.contentView.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MXSceneLightSceneStencilTableViewCell.self, forCellReuseIdentifier: "MXSceneLightSceneStencilTableViewCell")
        self.contentView.addSubview(footerView)
        footerView.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tipsLabel.pin.left(20).top(16).sizeToFit()
        footerView.pin.left().right().bottom().height(70 + self.view.safeAreaInsets.bottom)
        tableView.pin.below(of: tipsLabel).above(of: footerView).marginTop(6).left().right()
    }
    
    let tipsLabel = UILabel(frame: .zero)
    let tableView = UITableView(frame: .zero)
    let footerView = MXSceneLightSceneStencilFooterView(frame: .zero)
    
    var dataSource = [MXSceneTemplateInfo]()
}

extension MXSceneLightSceneStencilPage: MXSceneLightSceneStencilFooterViewDelegate {
    
    func add() {
        showPropertyView()
    }
    
}

extension MXSceneLightSceneStencilPage: MXSceneLightSceneStencilTableViewCellDelegate {
    
    func editLightSceneStencil(with viewMode: MXSceneTemplateInfo) {
        showPropertyView(with: viewMode)
    }
    
}

extension MXSceneLightSceneStencilPage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSource.count > indexPath.row {
            let stencil = self.dataSource[indexPath.row]
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "MXSceneLightSceneStencilSelected"), object: stencil, userInfo: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension MXSceneLightSceneStencilPage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneLightSceneStencilTableViewCell", for: indexPath) as! MXSceneLightSceneStencilTableViewCell
        if self.dataSource.count > indexPath.row {
            let stencil = self.dataSource[indexPath.row]
            cell.info = stencil
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.dataSource.count > indexPath.row {
                let delItem = self.dataSource[indexPath.row]
                MXSceneManager.shard.lightTemplateList.removeAll(where: {$0.id == delItem.id})
                MXSceneManager.shard.updateLightTemplateList()
                self.fetchData()
            }
        }
    }
    
}

extension MXSceneLightSceneStencilPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneLightSceneStencilPage()
        return vc
    }
    
}

protocol MXSceneLightSceneStencilTableViewCellDelegate {
    
    func editLightSceneStencil(with viewMode: MXSceneTemplateInfo) -> Void
    
}

class MXSceneLightSceneStencilTableViewCell: UITableViewCell {
    
    var info: MXSceneTemplateInfo? {
        didSet {
            guard let viewModel = info else {
                return
            }
            self.titleLable.text = viewModel.name
            var colors = AppUIConfiguration.MXLightSceneColor.blue
            if let colorProperty = viewModel.propertys?.first(where: {$0.identifier == "HSVColor"}),
               let value = colorProperty.value as? [String: Any], let hue = value["Hue"] as? Int {
                
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
            self.titleLable.textColor = colors[0]
            self.iconLable.textColor = colors[0]
            self.contentView.backgroundColor = colors[1]
            
        }
    }
    
    
    @objc func tapGestureAction(sender: UITapGestureRecognizer) -> Void {
        self.delegate?.editLightSceneStencil(with: self.info!)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.contentView.addSubview(titleLable)
        self.contentView.addSubview(iconLable)
        titleLable.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        iconLable.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        self.round(with: .both, rect: CGRect(x: 10, y: 10, width: screenWidth - 10 * 2, height: 80), radius: 16)
        iconLable.text = "\u{e6e0}"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:)))
        iconLable.isUserInteractionEnabled = true
        iconLable.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLable.pin.left(26).vCenter(5).sizeToFit()
        iconLable.pin.right(26).width(24).height(24).vCenter(5)
    }
    
    let titleLable = UILabel(frame: .zero)
    let iconLable = UILabel(frame: .zero)
    
    var delegate: MXSceneLightSceneStencilTableViewCellDelegate?
}

protocol MXSceneLightSceneStencilFooterViewDelegate {
    
    func add() -> Void
    
}

class MXSceneLightSceneStencilFooterView: UIView {
    
    @objc func buttonAction(sender: UIButton) -> Void {
        self.delegate?.add()
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
        let att = NSAttributedString(string: localized(key: "新建模板"), attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: color])
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
    var delegate: MXSceneLightSceneStencilFooterViewDelegate?
}
