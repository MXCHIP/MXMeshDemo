
import Foundation

class MXSelectedSettingView: UIView {
    
    public typealias SureActionCallback = (_ value: Int?) -> ()
    public var sureActionCallback : SureActionCallback?
    var contentView: UIView!
    
    public var currentValue : Int? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    public var dataList = [String : String]() {
        didSet {
            self.layoutSubviews()
            self.tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH : CGFloat = 235
        self.contentView = UIView(frame: CGRect(x: 10, y: UIScreen.main.bounds.height - viewH - 10, width: UIScreen.main.bounds.width - 20, height: viewH))
        self.contentView = UIView(frame: frame)
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 16.0
        self.addSubview(self.contentView)
        var bottomH: CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            bottomH = self.pin.safeArea.bottom
        }
        self.contentView.pin.left(10).right(10).bottom(bottomH).height(viewH)
        
        self.contentView.addSubview(self.titleLB)
        self.titleLB.pin.left(15).top(15).right(15).height(20)
        
        self.contentView.addSubview(self.bottomView)
        self.bottomView.pin.left().right().bottom().height(60)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.titleLB).marginTop(20).left().right().above(of: self.bottomView).marginBottom(0)
        
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var contentH =  (CGFloat(self.dataList.count) * 60) + 115
        if contentH > 355  {
            contentH = 355
        } else if contentH < 235 {
            contentH = 235
        }
        var bottomH: CGFloat = 10
        if self.pin.safeArea.bottom > 10 {
            bottomH = self.pin.safeArea.bottom
        }
        self.contentView.pin.left(10).right(10).bottom(bottomH).height(contentH)
        self.titleLB.pin.left(15).top(15).right(15).height(20)
        self.bottomView.pin.left().right().bottom().height(60)
        self.tableView.pin.below(of: self.titleLB).marginTop(20).left().right().above(of: self.bottomView).marginBottom(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.primaryText;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"主灯开关")
        return _titleLB
    }()
    
    lazy var bottomView : UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 60))
        _bottomView.backgroundColor = .clear
        
        let line1 = UIView(frame: .zero)
        line1.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        _bottomView.addSubview(line1)
        line1.pin.left().right().top().height(1)
        
        let line2 = UIView(frame: .zero)
        line2.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        _bottomView.addSubview(line2)
        line2.pin.below(of: line1).marginTop(0).width(1).bottom().hCenter()
        
        _bottomView.addSubview(self.leftBtn)
        self.leftBtn.pin.left().left(of: line2).marginRight(0).below(of: line1).marginTop(0).bottom()
        
        _bottomView.addSubview(self.rightBtn)
        self.rightBtn.pin.right(of: line2).marginLeft(0).right().below(of: line1).marginTop(0).bottom()
        
        return _bottomView
    }()
    
    lazy var leftBtn : UIButton = {
        let _leftBtn = UIButton(type: .custom)
        _leftBtn.setTitle(localized(key:"取消"), for: .normal)
        _leftBtn.setTitleColor(AppUIConfiguration.NeutralColor.secondaryText, for: .normal)
        _leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _leftBtn.backgroundColor = .clear
        _leftBtn.addTarget(self, action: #selector(leftBtnAction), for: .touchUpInside)
        return _leftBtn
    }()
    lazy var rightBtn : UIButton = {
        let _rightBtn = UIButton(type: .custom)
        _rightBtn.setTitle(localized(key:"确定"), for: .normal)
        _rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        _rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _rightBtn.backgroundColor = .clear
        _rightBtn.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        return _rightBtn
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
    
    @objc func leftBtnAction() {
        self.dismiss()
    }
    
    @objc func rightBtnAction() {
        if self.currentValue != nil {
            self.dismiss()
            self.sureActionCallback?(self.currentValue)
        }
    }
    
    
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

extension MXSelectedSettingView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier2 = "HomeCellIdentifier2"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier2) as? MXPropertySelectCell
        if cell == nil{
            cell = MXPropertySelectCell(style: .default, reuseIdentifier: cellIdentifier2)
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        let keys =  self.dataList.keys.sorted()
        let list = Array(keys)
        if list.count > indexPath.row {
            let key = list[indexPath.row]
            cell?.nameLB.text = self.dataList[key]
            cell?.value = key
            cell?.mxSelected = (Int(key) == self.currentValue)
        }
        
        cell?.selectCallback = { [weak self] (value : String?) in
            if let valueStr = value {
                self?.currentValue = Int(valueStr)
            }
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
            self.currentValue = Int(key)
        }
    }
}

class MXPropertySelectCell: UITableViewCell {
    
    public typealias SelectActionCallback = (_ item: String?) -> ()
    public var selectCallback : SelectActionCallback?
    public var value : String?
    
    public var mxSelected = false {
        didSet {
            if self.mxSelected {
                self.selectBtn.setTitle("\u{e6f3}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.MainColor.C0, for: .normal)
            } else {
                self.selectBtn.setTitle("\u{e6fb}", for: .normal)
                self.selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        
        self.contentView.addSubview(self.selectBtn)
        self.selectBtn.pin.right(20).width(24).height(24).vCenter()
        self.selectBtn.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.left(20).height(20).left(of: self.selectBtn).marginRight(20).vCenter()
        
    }
    
    @objc func selectAction() {
        self.selectCallback?(self.value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.selectBtn.pin.right(20).width(24).height(24).vCenter()
        self.nameLB.pin.left(20).height(20).left(of: self.selectBtn).marginRight(20).vCenter()
    }
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: .zero)
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLB.textAlignment = .left
        return _nameLB
    }()
    
    lazy var selectBtn : UIButton = {
        let _selectBtn = UIButton(type: .custom)
        _selectBtn.titleLabel?.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        _selectBtn.setTitle("\u{e6fb}", for: .normal)
        _selectBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        return _selectBtn
    }()
}
