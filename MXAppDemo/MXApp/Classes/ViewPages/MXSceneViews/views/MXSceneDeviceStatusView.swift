
import Foundation
import SDWebImage

class MXSceneDeviceStatusView: UIView {
    
    public static var shard = MXSceneDeviceStatusView(frame: .zero)
    
    public typealias SureActionCallback = () -> ()
    public var sureActionCallback : SureActionCallback?
    public var retryCallback : SureActionCallback?
    var contentView: UIView!
    public var isGroupSetting: Bool = false
    
    public var isFinish: Bool = false {
        didSet {
            let sortList = self.dataList.sorted { (item1: MXDeviceInfo, item2: MXDeviceInfo) in
                return item1.writtenStatus > item2.writtenStatus ? true : false
            }
            DispatchQueue.main.async {
                self.dataList = sortList
                self.bottomBtn.isUserInteractionEnabled = self.isFinish
                if self.isFinish {
                    self.bottomBtn.setTitle(localized(key:"好的"), for: .normal)
                }
                self.bottomBtn.setTitleColor((self.isFinish ? AppUIConfiguration.NeutralColor.title : AppUIConfiguration.NeutralColor.disable), for: .normal)
                if self.dataList.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
                
                let failDevices = sortList.filter({$0.writtenStatus == 3})
                if self.isFinish, failDevices.count > 0 {  
                    let titleMsg = localized(key:"重试") + "(\(failDevices.count))"
                    self.retryBtn.setTitle(titleMsg, for: .normal)
                    self.retryBtn.isHidden = (self.retryCallback == nil)
                    self.layoutSubviews()
                } else {
                    self.retryBtn.isHidden = true
                    self.layoutSubviews()
                }
            }
        }
    }
    
    public var dataList = [MXDeviceInfo]() {
        didSet {
            DispatchQueue.main.async {
                self.layoutSubviews()
                self.tableView.reloadData()
            }
        }
    }
    
    public func updateWrittenStatus() {
        DispatchQueue.main.async {
            let finishList = self.dataList.filter({$0.writtenStatus > 0})
            let msg = localized(key:"同步中") + "(\(finishList.count)/\(self.dataList.count))"
            if self.isFinish {
                self.bottomBtn.setTitle(localized(key:"好的"), for: .normal)
            } else {
                self.bottomBtn.setTitle(msg, for: .normal)
            }
            self.tableView.reloadData()
            if let index = self.dataList.firstIndex(where: {$0.writtenStatus == 1}) {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        self.addSubview(self.bgView)
        self.bgView.pin.all()
        
        let viewH : CGFloat = 178
        self.contentView = UIView(frame: CGRect(x: 24, y: (UIScreen.main.bounds.height - viewH)/2.0, width: UIScreen.main.bounds.width - 48, height: viewH))
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.addSubview(self.contentView)
        self.contentView.pin.left(24).right(24).height(viewH).vCenter()
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radii: 16)
        
        self.contentView.addSubview(self.titleLB)
        self.titleLB.pin.left(0).top(0).right(0).height(54)
        
        self.contentView.addSubview(self.retryBtn)
        self.retryBtn.pin.left().right().bottom().height(60)
        self.retryBtn.isHidden = true
        
        self.contentView.addSubview(self.bottomBtn)
        self.bottomBtn.pin.left().right().bottom().height(60)
        self.bottomBtn.isUserInteractionEnabled = false
        self.bottomBtn.setTitleColor(AppUIConfiguration.NeutralColor.disable, for: .normal)
        
        self.contentView.addSubview(self.tableView)
        self.tableView.pin.below(of: self.titleLB).marginTop(0).left().right().above(of: self.bottomBtn).marginBottom(0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bgView.pin.all()
        var contentH =  (CGFloat(self.dataList.count) * 64) + 114
        if contentH > 310  {
            contentH = 310
        } else if contentH < 118 {
            contentH = 118
        }
        
        self.contentView.pin.left(24).right(24).height(contentH).vCenter()
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radii: 16)
        self.titleLB.pin.left(0).top(0).right(0).height(54)
        if self.retryBtn.isHidden {
            self.bottomBtn.pin.left().right().bottom().height(60)
        } else {
            self.retryBtn.pin.left().bottom().height(60).width(self.contentView.frame.size.width/2.0)
            self.bottomBtn.pin.right().bottom().height(60).width(self.contentView.frame.size.width/2.0)
        }
        self.tableView.pin.below(of: self.titleLB).marginTop(0).left().right().above(of: self.bottomBtn).marginBottom(0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView : UIView = {
        let _bgView = UIView(frame: UIScreen.main.bounds)
        _bgView.backgroundColor = .clear
        return _bgView
    }()
    
    lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H2);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.title;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key:"同步设置")
        return _titleLB
    }()
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: .zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 10))
        return tableView
    }()
    
    lazy var bottomBtn : UIButton = {
        let _bottomBtn = UIButton(type: .custom)
        _bottomBtn.setTitle(localized(key:"好的"), for: .normal)
        _bottomBtn.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        _bottomBtn.titleLabel?.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H2)
        _bottomBtn.addTarget(self, action: #selector(bottomAction), for: .touchUpInside)
        _bottomBtn.layer.borderWidth = 0.5
        _bottomBtn.layer.borderColor = AppUIConfiguration.NeutralColor.dividers.cgColor
        _bottomBtn.layer.masksToBounds = true
        return _bottomBtn
    }()
    
    lazy var retryBtn : UIButton = {
        let _retryBtn = UIButton(type: .custom)
        _retryBtn.setTitle(localized(key:"重试"), for: .normal)
        _retryBtn.setTitleColor(AppUIConfiguration.MXAssistColor.red, for: .normal)
        _retryBtn.titleLabel?.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H2)
        _retryBtn.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        _retryBtn.layer.borderWidth = 0.5
        _retryBtn.layer.borderColor = AppUIConfiguration.NeutralColor.dividers.cgColor
        _retryBtn.layer.masksToBounds = true
        return _retryBtn
    }()
    
    @objc func bottomAction() {
        self.dismiss()
        self.sureActionCallback?()
        self.dataList.removeAll()
    }
    
    @objc func retryAction() {
        self.dismiss()
        self.retryCallback?()
    }
    
    
    func show() -> Void {
        if self.superview != nil {
            return
        }
        if self.dataList.count <= 0 {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
        if self.dataList.first(where: {$0.writtenStatus == 0 || $0.writtenStatus == 1}) != nil {
            self.isFinish = false
        } else {
            self.isFinish = true
        }
        self.pin.left().right().top().bottom()
    }
    
    
    @objc func dismiss() -> Void {
        self.removeFromSuperview()
    }
}

extension MXSceneDeviceStatusView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "kCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MXDeviceStatusCell
        if cell == nil{
            cell = MXDeviceStatusCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.selectionStyle = .none
        cell?.accessoryType = .none
        
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if self.isGroupSetting {
                cell?.refreshViewFromGroupDevice(info: info)
            } else {
                cell?.refreshViewInfo(info: info)
            }
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let info = self.dataList[indexPath.row]
            if info.writtenStatus == 3 {
                self.dismiss()
                MXURLRouter.open(url: "https://com.mxchip.bta/page/home/writeRuleFailPage", params: nil)
            }
        }
    }
}

class MXDeviceStatusCell: UITableViewCell {
    
    var info: MXDeviceInfo?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        
        self.contentView.addSubview(self.statusLab)
        self.statusLab.pin.right(16).width(20).height(18).vCenter()
        
        self.contentView.addSubview(self.nameLab)
        self.nameLab.pin.right(of: self.iconView).marginLeft(16).top(14).height(18).left(of: self.statusLab).marginRight(10)
        
        self.contentView.addSubview(self.valueLab)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).height(16).left(of: self.statusLab).marginRight(10)
        
    }
    
    func refreshViewFromGroupDevice(info: MXDeviceInfo) {
        
        self.info = info
        
        self.iconView.image = nil
        self.nameLab.text = nil
        self.valueLab.text = nil
        
        if let productImage = info.image, productImage.count > 0 {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        } else if let productImage = info.productInfo?.image, productImage.count > 0 {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        }
        
        self.nameLab.text = info.showName
        
        if info.isIntoGroup {
            self.valueLab.text = localized(key:"加入群组")
        } else {
            self.valueLab.text = localized(key:"移出群组")
        }
        
        if info.writtenStatus == 3 {
            self.statusLab.pin.right(16).width(90).height(18).vCenter()
        } else {
            self.statusLab.pin.right(16).width(20).height(18).vCenter()
        }
        self.nameLab.pin.right(of: self.iconView).marginLeft(16).top(14).height(18).left(of: self.statusLab).marginRight(10)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).height(16).left(of: self.statusLab).marginRight(10)
        
        switch info.writtenStatus {
        case 1:
            self.statusLab.text = "\u{e70d}"
            self.statusLab.textColor =  AppUIConfiguration.MainColor.C0
            break
        case 2:
            self.statusLab.text = "\u{e6f3}"
            self.statusLab.textColor =  AppUIConfiguration.MainColor.C0
            break
        case 3:
            let statusStr = NSMutableAttributedString()
            let str1 = NSAttributedString(string: localized(key:"保存失败"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.MXAssistColor.red])
            statusStr.append(str1)
            let str2 = NSAttributedString(string: "\u{e73a}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.MXAssistColor.red,.baselineOffset:-1])
            statusStr.append(str2)
            self.statusLab.attributedText = statusStr
            self.statusLab.textColor =  AppUIConfiguration.MXAssistColor.red
            break
        default:
            self.statusLab.text = nil
            break
        }
        
        self.statusLab.layer.removeAllAnimations()
        if info.writtenStatus == 1 {
            let animatiion = CABasicAnimation(keyPath: "transform.rotation.z")
            animatiion.fromValue = 0.0
            animatiion.toValue = 2*Double.pi
            animatiion.repeatCount = 0
            animatiion.duration = 1
            animatiion.isRemovedOnCompletion = false
            self.statusLab.layer.add(animatiion, forKey: "LoadingAnimation")
        }
    }
    
    func refreshViewInfo(info: MXDeviceInfo) {
        
        self.info = info
        
        self.iconView.image = nil
        self.nameLab.text = nil
        self.valueLab.text = nil
        
        if let productImage = info.image, productImage.count > 0 {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        } else if let productImage = info.productInfo?.image, productImage.count > 0 {
            self.iconView.sd_setImage(with: URL(string: productImage), placeholderImage: UIImage(named: productImage), completed: nil)
        }
        
        self.nameLab.text = info.showName
        
        let desStr = NSMutableAttributedString()
        if let propertyList = info.properties {
            propertyList.forEach { (item:MXPropertyInfo) in
                if let type = item.dataType?.type {
                    if (type == "bool" || type == "enum") {
                        if let dataValue = item.value as? Int, let specsParams = item.dataType?.specs as? [String: String] {
                            let valueStr = NSAttributedString(string: ((item.name ?? "") + "-" + (specsParams[String(dataValue)] ?? "") + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                            desStr.append(valueStr)
                        }
                    } else if type == "struct" {
                        if let dataValue = item.value as? [String: Int] {
                            if let p_identifier = item.identifier, p_identifier == "HSVColor",let hValue = dataValue["Hue"], let sValue = dataValue["Saturation"], let vValue = dataValue["Value"] {
                                let str = NSMutableAttributedString()
                                let nameStr = NSAttributedString(string: (item.name ?? "") + " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                                str.append(nameStr)
                                let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:UIColor(hue: CGFloat(hValue)/360, saturation: CGFloat(sValue)/100, brightness: CGFloat(vValue)/100, alpha: 1.0),.baselineOffset:-4])
                                str.append(valueStr)
                                desStr.append(str)
                            }
                        }
                    } else {
                        if let p_identifier = item.identifier, p_identifier == "HSVColorHex", let dataValue = item.value as? Int32 {
                            let str = NSMutableAttributedString()
                            let nameStr = NSAttributedString(string: (item.name ?? "") + " ", attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                            str.append(nameStr)
                            let valueStr = NSAttributedString(string: "\u{e72e} ", attributes: [.font: UIFont.iconFont(size: 24),.foregroundColor:MXHSVColorHandle.colorFromHSVColor(value: dataValue),.baselineOffset:-4])
                            str.append(valueStr)
                            desStr.append(str)
                        } else if let dataValue = item.value as? Int {
                            var compareType = item.compare_type
                            if compareType == "==" {
                                compareType = "-"
                            }
                            let valueStr = NSAttributedString(string: ((item.name ?? "") + compareType + String(dataValue) + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                            desStr.append(valueStr)
                        } else if let dataValue = item.value as? Double {
                            var compareType = item.compare_type
                            if compareType == "==" {
                                compareType = "-"
                            }
                            var floatNum = 0
                            if let stepStr = item.dataType?.specs?["step"] as? String, let step = Float(stepStr) {
                                if step < 0.1 {
                                    floatNum = 2
                                } else if step < 1 {
                                    floatNum = 1
                                }
                            }
                            let valueStr = NSAttributedString(string: ((item.name ?? "") + compareType +  String(format: "%.\(floatNum)f", dataValue) + " "), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.NeutralColor.secondaryText])
                            desStr.append(valueStr)
                        }
                    }
                }
            }
        }
        if desStr.length > 0 {
            self.valueLab.attributedText = desStr
        } else {
            self.valueLab.text = localized(key:"移除全部任务")
        }
        
        if info.writtenStatus == 3 {
            self.statusLab.pin.right(16).width(90).height(18).vCenter()
        } else {
            self.statusLab.pin.right(16).width(20).height(18).vCenter()
        }
        self.nameLab.pin.right(of: self.iconView).marginLeft(16).top(14).height(18).left(of: self.statusLab).marginRight(10)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).height(16).left(of: self.statusLab).marginRight(10)
        
        switch info.writtenStatus {
        case 1:
            self.statusLab.text = "\u{e70d}"
            self.statusLab.textColor =  AppUIConfiguration.MainColor.C0
            break
        case 2:
            self.statusLab.text = "\u{e6f3}"
            self.statusLab.textColor =  AppUIConfiguration.MainColor.C0
            break
        case 3:
            let statusStr = NSMutableAttributedString()
            let str1 = NSAttributedString(string: localized(key:"保存失败"), attributes: [.font: UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5),.foregroundColor:AppUIConfiguration.MXAssistColor.red])
            statusStr.append(str1)
            let str2 = NSAttributedString(string: "\u{e73a}", attributes: [.font: UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4),.foregroundColor:AppUIConfiguration.MXAssistColor.red,.baselineOffset:-1])
            statusStr.append(str2)
            self.statusLab.attributedText = statusStr
            self.statusLab.textColor =  AppUIConfiguration.MXAssistColor.red
            break
        default:
            self.statusLab.text = nil
            break
        }
        
        self.statusLab.layer.removeAllAnimations()
        if info.writtenStatus == 1 {
            let animatiion = CABasicAnimation(keyPath: "transform.rotation.z")
            animatiion.fromValue = 0.0
            animatiion.toValue = 2*Double.pi
            animatiion.repeatCount = 0
            animatiion.duration = 1
            animatiion.isRemovedOnCompletion = false
            self.statusLab.layer.add(animatiion, forKey: "LoadingAnimation")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(16).width(40).height(40).vCenter()
        if let status = self.info?.writtenStatus, status == 3 {
            self.statusLab.pin.right(16).width(80).height(18).vCenter()
        } else {
            self.statusLab.pin.right(16).width(20).height(18).vCenter()
        }
        self.nameLab.pin.right(of: self.iconView).marginLeft(16).top(14).height(18).left(of: self.statusLab).marginRight(10)
        self.valueLab.pin.below(of: self.nameLab, aligned: .left).marginTop(4).height(16).left(of: self.statusLab).marginRight(10)
    }
    
    public lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 16, y: 0, width: 40, height: 40))
        _iconView.backgroundColor = UIColor.clear
        _iconView.contentMode = .scaleAspectFit
        _iconView.clipsToBounds = true
        return _iconView
    }()
    
    public lazy var nameLab : UILabel = {
        let _nameLab = UILabel(frame: .zero)
        _nameLab.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H5);
        _nameLab.textColor = AppUIConfiguration.NeutralColor.title;
        _nameLab.textAlignment = .left
        return _nameLab
    }()
    
    public lazy var valueLab : UILabel = {
        let _valueLab = UILabel(frame: .zero)
        _valueLab.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6);
        _valueLab.textColor = AppUIConfiguration.NeutralColor.secondaryText;
        _valueLab.textAlignment = .left
        return _valueLab
    }()
    
    public lazy var statusLab : UILabel = {
        let _tagLab = UILabel(frame: CGRect(x: 0, y: 0, width: 16, height: 18))
        _tagLab.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H4)
        _tagLab.backgroundColor = .clear
        _tagLab.textAlignment = .right
        _tagLab.text = "\u{e70d}"
        _tagLab.textColor =  AppUIConfiguration.MainColor.C0
        return _tagLab
    }()
}
