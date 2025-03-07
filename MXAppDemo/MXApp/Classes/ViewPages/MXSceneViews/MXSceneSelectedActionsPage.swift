
import Foundation

class MXSceneSelectedActionsPage: MXBaseViewController {
    
    var sceneInfo = MXSceneInfo(type: "one_click")
    
    func deviceControl() -> Void {
        var params = [String : Any]()
        params["sceneInfo"] = self.sceneInfo
        MXURLRouter.open(url: "https://com.mxchip.bta/page/scene/selectDevice", params: params)
    }
    
    func manyDevicesControl() -> Void {
        let url = "com.mxchip.bta/page/scene/oneClickDevicesSwitch"
        var params = [String : Any]()
        params["sceneInfo"] = self.sceneInfo
        MXURLRouter.open(url: url, params: params)
    }
    
    func lightScene() -> Void {
        let url = "com.mxchip.bta/page/scene/lightScene"
        var params = [String : Any]()
        params["sceneInfo"] = self.sceneInfo
        MXURLRouter.open(url: url, params: params)
    }
    
    func oneClickControl() -> Void {
        var params = [String : Any]()
        params["sceneInfo"] = self.sceneInfo
        MXURLRouter.open(url: "com.mxchip.bta/page/scene/selection", params: params)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = localized(key: "选择执行动作")
        initSubviews()
        
        self.dataSource.removeAll()
        
        let list1 = [MXSceneOneClickActionViewModel(icon: "\u{e705}",
                                                    title: localized(key: "控制设备"),
                                                    content: localized(key: "例如：打开客厅开关"),
                                                    action: .deviceControl),
                    MXSceneOneClickActionViewModel(icon: "\u{e7be}",
                                                   title: localized(key: "批量打开/关闭设备"),
                                                   content: localized(key: "例如：打开客厅全部设备"),
                                                   action: .manyDevicesControl),
                    MXSceneOneClickActionViewModel(icon: "\u{e6ff}",
                                                   title: localized(key: "灯光场景"),
                                                   content: localized(key: "例如：一键调节家里的灯光效果"),
                                                   action: .lightScene)]
        self.dataSource.append(list1)
        
        var list2 = [MXSceneOneClickActionViewModel]()
        if self.sceneInfo.type != "one_click" {
            list2.append(MXSceneOneClickActionViewModel(icon: "\u{e6fd}",
                                                        title: localized(key: "执行手动场景"),
                                                        content: localized(key: "例如：执行已创建的手动场景"),
                                                        action: .oneClickControl))
        }
        self.dataSource.append(list2)
    }
    
    func initSubviews() -> Void {
        self.contentView.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MXSceneOneClickActionTableViewCell.self, forCellReuseIdentifier: "MXSceneOneClickActionTableViewCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.pin.all()
    }
    
    let tableView = UITableView(frame: .zero)
    var dataSource = [[MXSceneOneClickActionViewModel]]()
}

extension MXSceneSelectedActionsPage: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSource.count > indexPath.section {
            let list = self.dataSource[indexPath.section]
            if list.count > indexPath.row {
                let vm = list[indexPath.row]
                switch vm.type {
                case .deviceControl:
                    deviceControl()
                case .manyDevicesControl:
                    manyDevicesControl()
                case .lightScene:
                    lightScene()
                case .oneClickControl:
                    oneClickControl()
                default:
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}

extension MXSceneSelectedActionsPage: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSource.count > section {
            let list = self.dataSource[section]
            return list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneOneClickActionTableViewCell", for: indexPath) as! MXSceneOneClickActionTableViewCell
        if self.dataSource.count > indexPath.section {
            let list = self.dataSource[indexPath.section]
            if list.count > indexPath.row {
                let vm = list[indexPath.row]
                cell.info = vm
            }
        }
        return cell
    }
    
}

extension MXSceneSelectedActionsPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXSceneSelectedActionsPage()
        if let info = params["sceneInfo"] as? MXSceneInfo {
            vc.sceneInfo = info
        }
        return vc
    }
    
}

enum MXSceneOneClickAction {
    case deviceControl
    case manyDevicesControl
    case lightScene
    case autoSceneControl
    case oneClickControl
    case delayControl
    case sendMessage
    case undefind
}

class MXSceneOneClickActionViewModel: NSObject {
    
    var icon = ""
    var title = ""
    var content = ""
    var type: MXSceneOneClickAction = .undefind
    
    init(icon: String, title: String, content: String, action: MXSceneOneClickAction) {
        self.icon = icon
        self.title = title
        self.content = content
        self.type = action
    }
    
}

class MXSceneOneClickActionTableViewCell: UITableViewCell {
    
    var info: MXSceneOneClickActionViewModel? {
        didSet {
            guard let info = info else {
                return
            }
            self.iconLabel.text = info.icon
            self.titleLabel.text = info.title
            self.contentLabel.text = info.content
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
        self.contentView.addSubview(iconLabel)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(arrowLabel)
        
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        
        iconLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographyUndefinedSize.H4)
        iconLabel.textColor = AppUIConfiguration.MainColor.C0
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        contentLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        contentLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        arrowLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H4)
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        arrowLabel.text = "\u{e6df}"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconLabel.pin.left(20).width(32).height(32).vCenter()
        titleLabel.pin.left(72).top(19).sizeToFit()
        contentLabel.pin.left(72).bottom(19).sizeToFit()
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
    }
    
    let iconLabel = UILabel(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let contentLabel = UILabel(frame: .zero)
    let arrowLabel = UILabel(frame: .zero)
    
}
