
import Foundation
import UIKit
import WebKit
import PinLayout
import SwiftUI
import SDWebImage

class MXCustomizeAlertView: UIView {
    
    
    func show() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
    }
    
    
    func disappear() -> Void {
        self.removeFromSuperview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)

        self.addSubview(contentView)
        contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left().right().top().bottom()
        contentView.pin.center().width(304).height(426)
    }
    
    var contentView = UIView()
}

class MXAlertView: MXCustomizeAlertView {
        
    
    
    
    
    
    
    
    
    convenience init(title: String, message: String, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping (() -> Void), rightButtonCallBack:@escaping (() -> Void)) {
        self.init()
        self.titleLabel.text = title
        
        let messageLabel = UILabel()
        contentView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        messageLabel.font = UIFont(name: "PingFang-SC-Regular", size: AppUIConfiguration.TypographySize.H4)
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        self.messageLabel = messageLabel
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = AppUIConfiguration.ButtonColor.weak
        leftButton.setTitleColor(AppUIConfiguration.NeutralColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = AppUIConfiguration.MainColor.C0
        rightButton.setTitleColor(AppUIConfiguration.MXColor.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.leftButtonClosure = leftButtonCallBack
        self.rightButtonClosure = rightButtonCallBack
    }
    
    
    
    
    
    
    
    convenience init(title: String, message: String, confirmButtonTitle:String, confirmButtonCallBack: @escaping (() -> Void)) {
        self.init()
        self.titleLabel.text = title
        
        let messageLabel = UILabel()
        contentView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        messageLabel.font = UIFont(name: "PingFang-SC-Regular", size: AppUIConfiguration.TypographySize.H4)
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        self.messageLabel = messageLabel
        
        let confirmButton = UIButton()
        confirmButton.setTitle(confirmButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(confirmButton)
        confirmButton.backgroundColor = AppUIConfiguration.MainColor.C0
        confirmButton.setTitleColor(AppUIConfiguration.MXColor.white, for: UIControl.State.normal)
        confirmButton.layer.cornerRadius = 22
        confirmButton.addTarget(self, action: #selector(confirmButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.confirmButton = confirmButton
        
        self.confirmButtonClosure = confirmButtonCallBack
    }
    
    convenience init(title: String, placeholder: String, text: String? = nil, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping ((_ textField: UITextField) -> Void), rightButtonCallBack:@escaping ((_ textField: UITextField) -> Void)) {
        self.init()
        self.titleLabel.text = title

        let textField = UITextField()
        contentView.addSubview(textField)
        textField.placeholder = placeholder
        textField.text = text
        textField.layer.borderWidth = 2
        textField.layer.borderColor = AppUIConfiguration.MainColor.C0.cgColor
        textField.layer.cornerRadius = 8
        textField.textColor = AppUIConfiguration.NeutralColor.primaryText
        textField.font = UIFont(name: "PingFang-SC-Regular", size: AppUIConfiguration.TypographySize.H4)
        textField.tintColor = AppUIConfiguration.MainColor.C0
        let leftView = UIView()
        leftView.pin.width(16).height(0)
        textField.leftView = leftView
        textField.leftViewMode = .always
        self.textField = textField
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = AppUIConfiguration.ButtonColor.weak
        leftButton.setTitleColor(AppUIConfiguration.NeutralColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = AppUIConfiguration.MainColor.C0
        rightButton.setTitleColor(AppUIConfiguration.MXColor.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.inputLeftButtonClosure = leftButtonCallBack
        self.inputRightButtonClosure = rightButtonCallBack
    }
    
    
    override func show() {
        super.show()
        if let textField = textField {
            textField.becomeFirstResponder()
        }
    }
    
    override func initSubviews() -> Void {
        super.initSubviews()
        contentView.addSubview(titleLabel)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.font = UIFont(name: "PingFang-SC-Medium", size: AppUIConfiguration.TypographySize.H2)
        titleLabel.numberOfLines = 0
    }
    
    @objc func leftButtonAction(sender: UIButton) -> Void {
        disappear()
        if let closure = self.leftButtonClosure {
            closure()
        }
        if let closure = inputLeftButtonClosure, let textField = textField {
            closure(textField)
        }
    }
    
    @objc func rightButtonAction(sender: UIButton) -> Void {
        disappear()
        if let closure = self.rightButtonClosure {
            closure()
        }
        if let closure = inputRightButtonClosure, let textField = textField {
            closure(textField)
        }
    }
    
    @objc func confirmButtonAction(sender: UIButton) -> Void {
        disappear()
        guard let closure = self.confirmButtonClosure else { return }
        closure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.pin.top(24).width(256).sizeToFit(.width)
        
        if let messageLabel = messageLabel {
            messageLabel.pin.below(of: titleLabel).marginTop(16).width(256).sizeToFit(.width)
            if let leftButton = leftButton {
                leftButton.pin.below(of: messageLabel, aligned: .left).marginTop(32).width(120).height(44)
            }
            if let rightButton = rightButton {
                rightButton.pin.below(of: messageLabel, aligned: .right).marginTop(32).width(120).height(44)
            }
            if let confirmButton = confirmButton {
                confirmButton.pin.below(of: messageLabel).marginTop(32).width(256).height(44)
            }
            
            contentView.pin.wrapContent(padding: 24.0).center()
        }
        
        if let textField = textField {
            textField.pin.below(of: titleLabel).marginTop(16).width(256).height(50)
            if let leftButton = leftButton {
                leftButton.pin.below(of: textField, aligned: .left).marginTop(32).width(120).height(44)
            }
            if let rightButton = rightButton {
                rightButton.pin.below(of: textField, aligned: .right).marginTop(32).width(120).height(44)
            }
            
            contentView.pin.wrapContent(padding: 24.0).hCenter().vCenter(-15%)
        }

    }
    
    let titleLabel = UILabel()
    
    var messageLabel: UILabel?

    var textField: UITextField?

    var leftButton: UIButton?
    var rightButton: UIButton?

    var leftButtonClosure: (() -> Void)?
    var rightButtonClosure: (() -> Void)?
    
    var confirmButton: UIButton?
    var confirmButtonClosure: (() -> Void)?

    var inputLeftButtonClosure: ((_ textField: UITextField) -> Void)?
    var inputRightButtonClosure: ((_ textField: UITextField) -> Void)?
}

class MXItemsAlertView: MXCustomizeAlertView {
    
    @objc func cancelAction(sender: UITapGestureRecognizer) -> Void {
        disappear()
    }
    
    override func show() {
        super.show()
        self.tableView.reloadData()
    }
    
    convenience init(title: String,
                     actionTitles: [String],
                     cancel: String,
                     style: MXItemsAlertView.Style,
                     selected: @escaping (_ atIndex: Int) -> Void) {
        self.init()
        self.style = style
        
        dataSource = actionTitles
        selectedClosure = selected
        
        self.addSubview(contentView)
        contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        
        contentView.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        titleLabel.textAlignment = .center
        
        contentView.addSubview(tableView)
        tableView.register(MXItemsAlertTableViewCell.self, forCellReuseIdentifier: "MXItemsAlertTableViewCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    
        contentView.addSubview(cancelLabel)
        cancelLabel.text = cancel
        cancelLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        cancelLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        cancelLabel.textAlignment = .center
        
        let cancel = UITapGestureRecognizer(target: self, action: #selector(cancelAction(sender:)))
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.addGestureRecognizer(cancel)
    }

    override func initSubviews() {
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left().right().top().bottom()
        
        if self.style == .actionSheet {
            contentView.pin.height(48 + 60 + 60 * CGFloat(dataSource.count) + self.pin.safeArea.bottom).bottom().left().right()
        } else {
            contentView.pin.height(48 + 60 + 60 * CGFloat(dataSource.count))
        }
        contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 20.0)

        titleLabel.pin.left().right().top(16).height(16)
        tableView.pin.below(of: titleLabel).marginTop(16).left().right().height(60 * CGFloat(dataSource.count))
        cancelLabel.pin.below(of: tableView).left().right().height(60)
    }
    
    let titleLabel = UILabel()
    let tableView = UITableView()
    let cancelLabel = UILabel()

    var dataSource = [String]()
    
    var selectedClosure: ((_ atIndex: Int) -> Void)!
    
    var style: MXItemsAlertView.Style!
}

extension MXItemsAlertView {
    
    enum Style : Int {
        
        case actionSheet = 0
        
        case alert = 1
    }
    
}


extension MXItemsAlertView: UITableViewDelegate {
    
}

class MXItemsAlertTableViewCell: UITableViewCell {
    
    func updateSubviews(title: String) -> Void {
        titleLabel.text = title
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.selectionStyle = .none
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.pin.all()
    }
    
    let titleLabel = UILabel()
    
}


extension MXItemsAlertView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXItemsAlertTableViewCell", for: indexPath) as! MXItemsAlertTableViewCell
        if dataSource.count > indexPath.row {
            let title = dataSource[indexPath.row]
            cell.updateSubviews(title: title)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        disappear()
        selectedClosure(indexPath.row)
    }
    
}

protocol MXItemsSytle1AlertViewDelegate {
    
    func didSelected(in itemsAlertView: MXItemsSytle1AlertView, at index: Int) -> Void
    
}

class MXItemsSytle1AlertView: UIView {
    
    convenience init(title: String, dataSource: [[String: Any]]) {
        self.init()
        self.titleLabel.text = title
        self.dataSource = dataSource
        self.tableView.reloadData()
    }
    
    func show() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
    }
    
    func disappear() -> Void {
        self.removeFromSuperview()
    }
    
    @objc func cancelTapAction(sender: UITapGestureRecognizer) -> Void {
        self.disappear()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = UIColor(hex: "000000", alpha: 0.4)
        self.addSubview(contentView)
        contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.contentView.addSubview(navView)
        navView.backgroundColor = UIColor.clear
        navView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.textAlignment = .center
        navView.addSubview(cancelLabel)
        cancelLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        cancelLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        cancelLabel.text = "\u{e71c}"
        let cancelTap = UITapGestureRecognizer(target: self, action: #selector(cancelTapAction(sender:)))
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.addGestureRecognizer(cancelTap)
        navView.addSubview(lineView)
        lineView.backgroundColor = AppUIConfiguration.NeutralColor.border
        contentView.addSubview(tableView)
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(MXItemsSytle1AlertTableViewCell.self, forCellReuseIdentifier: "MXItemsSytle1AlertTableViewCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.all()
        var contentViewHeight: CGFloat = 51 + 15 * 2 + 80 * CGFloat(dataSource.count) + self.pin.safeArea.bottom
        if contentViewHeight > 480 {
            contentViewHeight = 480
            tableView.isScrollEnabled = true
        } else{
            tableView.isScrollEnabled = false
        }
        contentView.pin.left().right().bottom().height(contentViewHeight)
        contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 20)
        navView.pin.top().left().right().height(51)
        lineView.pin.left().right().bottom().height(1)
        titleLabel.pin.width(200).height(20).center()
        cancelLabel.pin.right(24).width(24).height(24).vCenter()
        tableView.pin.below(of: navView).marginTop(15).left().right().bottom(15)
    }
    
    let contentView = UIView()
    let navView = UIView()
    let titleLabel = UILabel()
    let cancelLabel = UILabel()
    let lineView = UIView()
    let tableView = UITableView(frame: .zero, style: UITableView.Style.plain)
    
    var dataSource = [[String: Any]]()
    
    var delegate: MXItemsSytle1AlertViewDelegate?
}

extension MXItemsSytle1AlertView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXItemsSytle1AlertTableViewCell", for: indexPath) as! MXItemsSytle1AlertTableViewCell
        if self.dataSource.count > indexPath.row {
            let source = dataSource[indexPath.row]
            cell.updateSubviews(with: source)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelected(in: self, at: indexPath.row)
    }
    
}

extension MXItemsSytle1AlertView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class MXItemsSytle1AlertTableViewCell: UITableViewCell {
    
    func updateSubviews(with data: [String: Any]) -> Void {
        if let title = data["title"] as? String {
            titleLabel.text = title
        }
        if let subTitle = data["subTitle"] as? String {
            subTitleLabel.text = subTitle.phoneNumberEncryption()
        }
        if let avatar = data["avatar"] as? String,
           let url = URL(string: avatar) {
            avatarView.sd_setImage(with: url, placeholderImage: UIImage(named: "avatar"), options: .retryFailed, context: nil)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initSubViews() -> Void {
        self.selectionStyle = .none
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level3.FFFFFF
        self.contentView.addSubview(avatarView)
        avatarView.image = UIImage(named: "avatar")
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        subTitleLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.pin.left(16).width(48).height(48).vCenter()
        titleLabel.pin.after(of: avatarView, aligned: .top).marginLeft(16).height(20).right(16)
        subTitleLabel.pin.after(of: avatarView, aligned: .bottom).marginLeft(16).height(18).right(16)
    }
    
    let avatarView = UIImageView()
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    
}


class MXItemsStyle2AlertView: MXCustomizeAlertView {
    
    @objc func cancelAction(sender: UITapGestureRecognizer) -> Void {
        disappear()
    }
    
    override func show() {
        super.show()
        self.tableView.reloadData()
    }
    
    convenience init(title: String,
                     actionTitles: [[String: Any]],
                     selected: @escaping (_ atIndex: Int) -> Void) {
        self.init()
        
        dataSource = actionTitles
        selectedClosure = selected
        
        self.addSubview(contentView)
        contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        
        contentView.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        titleLabel.textAlignment = .center
        
        contentView.addSubview(cancelLabel)
        cancelLabel.text = "\u{e721}"
        cancelLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
        cancelLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        cancelLabel.textAlignment = .center
        
        contentView.addSubview(lineView)
        lineView.backgroundColor = AppUIConfiguration.lineColor.XX0AEEEEEE
        
        contentView.addSubview(tableView)
        tableView.register(MXItemsStyle2AlertTableViewCell.self, forCellReuseIdentifier: "MXItemsStyle2AlertTableViewCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    
        let cancel = UITapGestureRecognizer(target: self, action: #selector(cancelAction(sender:)))
        cancelLabel.isUserInteractionEnabled = true
        cancelLabel.addGestureRecognizer(cancel)
    }

    override func initSubviews() {
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left().right().top().bottom()
        contentView.pin.height(16 + 65 + 80 * CGFloat(dataSource.count) + self.pin.safeArea.bottom).bottom().left().right()
        contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 20)
        titleLabel.pin.top(16).hCenter().sizeToFit()
        cancelLabel.pin.top(14).right(24).width(24).height(24)
        lineView.pin.top(52).left().right().height(1)
        tableView.pin.top(65).left(10).right(10).bottom(10 + self.pin.safeArea.bottom)
    }
    
    let titleLabel = UILabel()
    let lineView = UIView(frame: .zero)
    let tableView = UITableView()
    let cancelLabel = UILabel()

    var dataSource = [[String: Any]]()
    
    var selectedClosure: ((_ atIndex: Int) -> Void)!
    
    var style: MXItemsAlertView.Style!
}


extension MXItemsStyle2AlertView: UITableViewDelegate {
    
}

extension MXItemsStyle2AlertView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXItemsStyle2AlertTableViewCell", for: indexPath) as! MXItemsStyle2AlertTableViewCell
        if dataSource.count > indexPath.row {
            let info = dataSource[indexPath.row]
            cell.updateSubviews(info: info)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        disappear()
        selectedClosure(indexPath.row)
    }
    
}

class MXItemsStyle2AlertTableViewCell: UITableViewCell {
    
    func updateSubviews(info: [String: Any]) -> Void {
        if let image = info["image"] as? String {
            if image.hasPrefix("http") {
                imgView.sd_setImage(with: URL(string: image))
            } else {
                imgView.image = UIImage(named: image)
            }
        }
        if let title = info["title"] as? String {
            self.titleLabel.text = title
        }
        if let content = info["content"] as? String {
            self.contentLabel.text = content
        }
        self.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.selectionStyle = .none
        self.contentView.addSubview(imgView)
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Medium, size: AppUIConfiguration.TypographySize.H5)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        self.contentView.addSubview(contentLabel)
        contentLabel.font = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H5)
        contentLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        self.contentView.addSubview(arrowLabel)
        arrowLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H1)
        arrowLabel.textColor = AppUIConfiguration.NeutralColor.disable
        arrowLabel.text = "\u{e6df}"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.pin.left(16).width(24).height(24).vCenter()
        titleLabel.pin.left(60).top(19).sizeToFit()
        contentLabel.pin.below(of: titleLabel, aligned: .left).marginTop(4).sizeToFit()
        arrowLabel.pin.right(16).width(20).height(20).vCenter()
    }
    
    let imgView = UIImageView()
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let arrowLabel = UILabel()

}



class MXOptionsAlertView: MXCustomizeAlertView {
    
    @objc func cancelButtonAction(sender: UIButton) -> Void {
        disappear()
    }
    
    @objc func cancelAction(sender: UITapGestureRecognizer) -> Void {
        disappear()
    }
    
    override func show() {
        super.show()
        self.tableView.reloadData()
    }
    
    convenience init(title: String,
                     actionInfos: [[String: Any]],
                     style: MXItemsAlertView.Style,
                     selected: @escaping (_ atIndex: Int) -> Void) {
        self.init()
        
        self.style = style
        dataSource = actionInfos
        selectedClosure = selected
        
        self.insertSubview(cancelButton, at: 0)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        
        contentView.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        titleLabel.textAlignment = .center
        
        contentView.addSubview(tableView)
        tableView.register(MXOptionsAlertTableViewCell.self, forCellReuseIdentifier: "MXOptionsAlertTableViewCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButton.pin.all()
        if self.style == .alert {
            contentView.pin.height(48 + 80 * CGFloat(dataSource.count))
        } else {
            contentView.pin.left().right().bottom().height(48 + 80 * CGFloat(dataSource.count) + self.pin.safeArea.bottom)
        }
        titleLabel.pin.left().right().top(16).height(16)
        tableView.pin.below(of: titleLabel).marginTop(16).left().right().height(80 * CGFloat(dataSource.count))
    }
    
    let titleLabel = UILabel()
    let tableView = UITableView()
    let cancelButton = UIButton(frame: .zero)

    var dataSource = [[String: Any]]()
    
    var selectedClosure: ((_ atIndex: Int) -> Void)!
    
    var style: MXItemsAlertView.Style!

}

extension MXOptionsAlertView: UITableViewDelegate {
    
}

class MXOptionsAlertTableViewCell: UITableViewCell {
    
    func updateSubviews(info: [String: Any]) -> Void {
        if let image = info["image"] as? String,
           let placeholderImage = info["placeholderImage"] as? String {
            self.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: placeholderImage))
        }
        if let title = info["title"] as? String,
           let content = info["content"] as? String,
           let isSelected = info["isSelected"] as? Bool {
            titleLabel.text = title
            contentLabel.text = content
            var icon: String!
            var iconColor: UIColor!
            if isSelected {
                icon = "\u{e6f3}"
                iconColor = AppUIConfiguration.MainColor.C0
            } else {
                icon = "\u{e6fb}"
                iconColor = AppUIConfiguration.NeutralColor.disable
            }
            selectedLabel.text = icon
            selectedLabel.textColor = iconColor
        }
        
        self.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        self.contentView.addSubview(imgView)
        
        self.contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.title
        
        self.contentView.addSubview(contentLabel)
        contentLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        contentLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        
        self.contentView.addSubview(selectedLabel)
        selectedLabel.font = UIFont(name: AppUIConfiguration.Font.iconfont, size: AppUIConfiguration.TypographySize.H0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.pin.left(16).vCenter().width(48).height(48)
        if let _ = imgView.image {
            titleLabel.pin.after(of: imgView).marginLeft(16).top(18).sizeToFit()
            contentLabel.pin.below(of: titleLabel, aligned: .left).marginTop(8).sizeToFit()
        } else {
            titleLabel.pin.top(18).left(20).sizeToFit()
            contentLabel.pin.below(of: titleLabel, aligned: .left).marginTop(8).sizeToFit()
        }
        selectedLabel.pin.vCenter().right(20).width(24).height(24)
    }
    
    let imgView = UIImageView(frame: .zero)
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let selectedLabel = UILabel()

}

extension MXOptionsAlertView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXOptionsAlertTableViewCell", for: indexPath) as! MXOptionsAlertTableViewCell
        if dataSource.count > indexPath.row {
            let info = dataSource[indexPath.row]
            cell.updateSubviews(info: info)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        disappear()
        selectedClosure(indexPath.row)
    }
    
}

class MXMultipleOptionsAlertView: MXCustomizeAlertView {
    
    @objc func cancelButtonAction(sender: UIButton) -> Void {
        disappear()
    }
    
    @objc func confirmButtonAction(sender: UIButton) -> Void {
        disappear()
        let indexs = self.dataSource.enumerated()
            .filter { index, ele in
                if let isSelected = ele["isSelected"] as? Bool {
                    return isSelected
                }
                return false
            }
            .map { index, ele in
                return index
            }
        
        self.selectedClosure?(indexs)
    }
    
    @objc func cancelAction(sender: UITapGestureRecognizer) -> Void {
        disappear()
    }
    
    override func show() {
        super.show()
        self.tableView.reloadData()
    }
    
    func updateSource(at indexPath: IndexPath) -> Void {
        if self.dataSource.count > indexPath.row {
            var element = self.dataSource[indexPath.row]
            if let isSelected = element["isSelected"] as? Bool {
                element["isSelected"] = !isSelected
                self.dataSource[indexPath.row] = element
                self.tableView.reloadData()
            }
        }
    }
    
    convenience init(title: String,
                     actionInfos: [[String: Any]],
                     selected: @escaping (_ atIndex: [Int]) -> Void) {
        self.init()
        
        dataSource = actionInfos
        selectedClosure = selected
        
        self.insertSubview(cancelButton, at: 0)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        
        contentView.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        titleLabel.textColor = AppUIConfiguration.NeutralColor.primaryText
        titleLabel.textAlignment = .center
        
        contentView.addSubview(tableView)
        tableView.register(MXOptionsAlertTableViewCell.self, forCellReuseIdentifier: "MXOptionsAlertTableViewCell")
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        contentView.addSubview(hLine)
        hLine.backgroundColor = AppUIConfiguration.lineColor.XX0AEEEEEE
        contentView.addSubview(cancelButton)
        let cancelButtonAttFont = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let cancelButtonAttColor = AppUIConfiguration.NeutralColor.secondaryText
        let cancelButtonAtt = NSAttributedString(string: localized(key: "Modules_取消"), attributes: [NSAttributedString.Key.font : cancelButtonAttFont,
                                                                                                    NSAttributedString.Key.foregroundColor: cancelButtonAttColor])
        cancelButton.setAttributedTitle(cancelButtonAtt, for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        contentView.addSubview(vLine)
        vLine.backgroundColor = AppUIConfiguration.lineColor.XX0AEEEEEE
        contentView.addSubview(confirmButton)
        let confirmButtonAttFont = UIFont(name: AppUIConfiguration.Font.PingFang_Regular, size: AppUIConfiguration.TypographySize.H4) ?? UIFont()
        let confirmButtonAttColor = AppUIConfiguration.NeutralColor.secondaryText
        let confirmButtonAtt = NSAttributedString(string: localized(key: "Modules_确定"), attributes: [NSAttributedString.Key.font : confirmButtonAttFont,
                                                                                                    NSAttributedString.Key.foregroundColor: confirmButtonAttColor])
        confirmButton.setAttributedTitle(confirmButtonAtt, for: UIControl.State.normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonAction(sender:)), for: UIControl.Event.touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButton.pin.all()
        let maxHeight = self.dataSource.count > 4 ? 80 * 4 : 80 * CGFloat(dataSource.count)
        contentView.pin.left(10).right(10).bottom(10 + self.pin.safeArea.bottom).height(48.0 + maxHeight + 60)
        titleLabel.pin.left().right().top(16).height(16)
        tableView.pin.below(of: titleLabel).marginTop(16).left().right().height(maxHeight)
        hLine.pin.below(of: tableView).left().right().height(1)
        cancelButton.pin.below(of: hLine).left().height(60).width((screenWidth - 10 * 2.0 - 1.0) / 2)
        vLine.pin.after(of: cancelButton, aligned: .top).bottom().width(1)
        confirmButton.pin.after(of: vLine, aligned: .top).height(60).width((screenWidth - 10 * 2.0 - 1.0) / 2)
    }
    
    let titleLabel = UILabel()
    let tableView = UITableView()
    let hLine = UIView(frame: .zero)
    let vLine = UIView(frame: .zero)
    let cancelButton = UIButton(frame: .zero)
    let confirmButton = UIButton(frame: .zero)

    var dataSource = [[String: Any]]()
    
    var selectedClosure: ((_ atIndex: [Int]) -> Void)!
    
}

extension MXMultipleOptionsAlertView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXOptionsAlertTableViewCell", for: indexPath) as! MXOptionsAlertTableViewCell
        if dataSource.count > indexPath.row {
            let info = dataSource[indexPath.row]
            cell.updateSubviews(info: info)
        }
        return cell
    }
    
}

extension MXMultipleOptionsAlertView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateSource(at: indexPath)
    }
    
}


class MXWebAlertView: MXAlertView {
    
    func reload() -> Void {
        loadView()
    }
    
    convenience init(url: String) {
        
        self.init()
        
        self.urlString = url
        
        loadView()
    }
    
    convenience init(url: String, leftButtonTitle:String, rightButtonTitle: String, leftButtonCallBack: @escaping (() -> Void), rightButtonCallBack:@escaping (() -> Void)) {
        
        self.init()
        
        self.urlString = url
        
        let leftButton = UIButton()
        leftButton.setTitle(leftButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(leftButton)
        leftButton.backgroundColor = AppUIConfiguration.ButtonColor.weak
        leftButton.setTitleColor(AppUIConfiguration.NeutralColor.title, for: UIControl.State.normal)
        leftButton.layer.cornerRadius = 22
        leftButton.addTarget(self, action: #selector(leftButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.leftButton = leftButton
        
        let rightButton = UIButton()
        rightButton.setTitle(rightButtonTitle, for: UIControl.State.normal)
        contentView.addSubview(rightButton)
        rightButton.backgroundColor = AppUIConfiguration.MainColor.C0
        rightButton.setTitleColor(AppUIConfiguration.MXColor.white, for: UIControl.State.normal)
        rightButton.layer.cornerRadius = 22
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        self.rightButton = rightButton
        
        self.leftButtonClosure = leftButtonCallBack
        self.rightButtonClosure = rightButtonCallBack
        
        loadView()
    }
    
    func loadView() {
        if let string = urlString,
           let url = URL(string: string) {
            if url.isFileURL {
                webView.loadFileURL(url, allowingReadAccessTo: MXResourcesManager.loadAgreementRootUrl())
            } else {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
    

    let webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
    var urlString: String?
    
    override func initSubviews() {
        super.initSubviews()
        
        self.webView.evaluateJavaScript("navigator.userAgent") { (result: Any?, error: Error?) in
            let oldUA = (result as? String) ?? ""
            let appBuildID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
            let language = MXAccountManager.shared.language ?? Locale.preferredLanguages[0]
            var userInterfaceStyleString = "light"
            if #available(iOS 13, *) {
                userInterfaceStyleString = (UITraitCollection.current.userInterfaceStyle == .dark) ? "dark" : "light"
            }
            if MXAccountManager.shared.darkMode == 1 {
                userInterfaceStyleString = "light"
            } else if MXAccountManager.shared.darkMode == 2 {
                userInterfaceStyleString = "dark"
            }
            let newUA = "\(oldUA) mxchip app/\(appBuildID) lang/\(language) theme/\(userInterfaceStyleString) productType/virtual"
            self.webView.customUserAgent = newUA
        }

        contentView.addSubview(webView)
        webView.backgroundColor = AppUIConfiguration.NeutralColor.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let leftButton = leftButton {
            leftButton.pin.left(24).width(120).height(44).bottom(24)
            webView.pin.above(of: leftButton).marginBottom(24).top(24).left(24).right(24)
        } else {
            webView.pin.all()
        }
        
        if let rightButton = rightButton {
            rightButton.pin.right(24).width(120).height(44).bottom(24)
        }

    }
    
}


