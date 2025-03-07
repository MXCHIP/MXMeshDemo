
import Foundation

class MXSceneItemsView: UIView {
    
    func show(with dataSource: [[String: Any]]) -> Void {
        self.dataSource = dataSource
        self.tableView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = UIColor.clear
        self.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(MXSceneItemsTableViewCell.self, forCellReuseIdentifier: "MXSceneItemsTableViewCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.pin.all()
    }
    
    let tableView = UITableView(frame: .zero, style: .plain)
    var dataSource = [[String: Any]]()
    
}

extension MXSceneItemsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXSceneItemsTableViewCell", for: indexPath) as! MXSceneItemsTableViewCell
        if self.dataSource.count > indexPath.row {
            let info = self.dataSource[indexPath.row]
            cell.updateSubviews(with: info)
        }
        
        if self.dataSource.count == 1 {
            cell.round(with: .both, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
        } else {
            if indexPath.row == 0 {
                cell.round(with: .top, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
            } else if indexPath.row == self.dataSource.count - 1 {
                cell.round(with: .bottom, rect: CGRect(x: 0, y: 0, width: screenWidth - 10 * 2, height: 80), radius: 16)
            } else {
                cell.removeRound()
            }
        }
        return cell
    }
    
}

extension MXSceneItemsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dataSource = self.dataSource.enumerated().map { index, element in
            var newElement = element
            if index == indexPath.row {
                newElement["isSelected"] = true
            } else {
                newElement["isSelected"] = false
            }
            return newElement
        }
        
        self.tableView.reloadData()
    }
    
}

class MXSceneItemsTableViewCell: UITableViewCell {
    
    func updateSubviews(with info: [String: Any]) -> Void {
        self.info = info
        if let title = info["title"] as? String {
            titleLabel.text = title
        }
        if let content = info["content"] as? String {
            contentLabel.text = content
            contentLabel.isHidden = false
        } else {
            contentLabel.isHidden = true
        }
        if let isSelected = info["isSelected"] as? Bool {
            var status = ""
            var statusColor = AppUIConfiguration.MainColor.C0
            if isSelected {
                status = "\u{e644}"
                statusColor = AppUIConfiguration.MainColor.C0
            } else {
                status = "\u{e648}"
                statusColor = AppUIConfiguration.NeutralColor.disable
            }
            optionLabel.text = status
            optionLabel.textColor = statusColor
        }
        
        self.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubviews() -> Void {
        self.selectionStyle = .none
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(optionLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        contentLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H6)
        contentLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        optionLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let _ = info["content"] as? String {
            titleLabel.pin.top(20).left(16).sizeToFit()
            contentLabel.pin.top(44).left(16).sizeToFit()
        } else {
            titleLabel.pin.top(20).left(16).sizeToFit()
        }
        optionLabel.pin.right(16).vCenter().width(24).height(24)
    }
    
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let optionLabel = UILabel()
    var info = [String: Any]()
    
}
