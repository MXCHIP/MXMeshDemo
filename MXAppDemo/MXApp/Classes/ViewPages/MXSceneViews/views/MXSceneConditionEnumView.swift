
import Foundation

class MXSceneConditionEnumView: UIView {
    
    public typealias SelectActionCallback = (_ value: Int?) -> ()
    public var selectCallback : SelectActionCallback?
    var contentView: UIView!
    public var dataName: String = ""
    public var dataList = [String: String]() {
        didSet {
            self.layoutSubviews()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    public var titleStr : String? {
        didSet {
            self.titleLB.text = titleStr
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH : CGFloat = 228
        self.contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - viewH, width: UIScreen.main.bounds.width, height: viewH))
        self.contentView = UIView(frame: frame)
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.addSubview(self.contentView)
        
        self.contentView.addSubview(self.titleLB)
        self.titleLB.pin.left(0).top(0).right(0).height(48)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.titleLB).marginTop(0).left().right().bottom(self.pin.safeArea.bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var contentH =  (CGFloat(self.dataList.count) * 60) + 108
        if contentH > 348  {
            contentH = 348
        } else if contentH < 168 {
            contentH = 168
        }
        self.contentView.pin.left().right().bottom().height(contentH + self.pin.safeArea.bottom)
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.titleLB.pin.left(0).top(0).right(0).height(48)
        self.tableView.pin.below(of: self.titleLB).marginTop(0).left().right().bottom()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.pin.safeArea.bottom))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.primaryText;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"选择触发条件")
        return _titleLB
    }()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: .zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        return tableView
    }()
    
    
    func show() -> Void {
        if self.superview != nil {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
        self.pin.left().right().top().bottom()
    }
    
    
    func dismiss() -> Void {
        self.removeFromSuperview()
    }
}

extension MXSceneConditionEnumView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "kCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        
        cell?.textLabel?.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4)
        cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.title
        cell?.textLabel?.textAlignment = .center
        
        let keys =  self.dataList.keys.sorted()
        let list = Array(keys)
        if list.count > indexPath.row {
            let key = list[indexPath.row]
            let nameStr = self.dataName + "-" + (self.dataList[key] ?? "")
            cell?.textLabel?.text = nameStr
        }
        
        if indexPath.row == self.dataList.count {
            cell?.textLabel?.textColor = AppUIConfiguration.NeutralColor.primaryText
            cell?.textLabel?.text = localized(key:"取消")
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys =  self.dataList.keys.sorted()
        let list = Array(keys)
        if list.count > indexPath.row {
            let key = list[indexPath.row]
            self.selectCallback?(Int(key))
        }
        self.dismiss()
    }
}
