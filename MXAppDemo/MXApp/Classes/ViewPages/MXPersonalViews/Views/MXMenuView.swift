
import Foundation
import UIKit


class MXMenuView: UIView {
    
    
    @objc func showMenu(notification: Notification) -> Void {
        guard let theSuperView = self.superview,
              let theLast = theSuperView.subviews.last else { return }
        
        if !theLast.isKind(of: MXMenuView.self) {
            theSuperView.bringSubviewToFront(self)
        }
        
        show(with: true)
    }
    
    func show() -> Void {
        show(with: true)
    }
    
    
    @objc func tapToDisappear(sender: UITapGestureRecognizer) -> Void {
        disappear(with: true)
    }
    
    
    func updateSubviews(with model: MXMenuModel) -> Void {
        self.darkMode(with: model)
        self.tableView.reloadData()
    }
    
    func darkMode(with model: MXMenuModel) -> Void {
        if #available(iOS 12.0, *) {
            var style: UIUserInterfaceStyle = .unspecified
            if model.darkMode == 0 {
                style = .unspecified
            } else if model.darkMode == 1 {
                style = .light
            } else if model.darkMode == 2 {
                style =  .dark
            }
            UIApplication.shared.windows.forEach { window in
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = style
                } else {
                    
                }
            }
        } else {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviws()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showMenu(notification:)), name: NSNotification.Name.init("SHOW_MAIN_MENU"), object: nil)
        
        viewModel.observe { [weak self] (model: MXMenuModel) in
            self?.updateSubviews(with: model)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviws() -> Void {
        self.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        
        self.addSubview(navView)
        
        navView.addSubview(titleLB)
        titleLB.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H3)
        titleLB.text = localized(key: "我的")
        titleLB.textAlignment = .center
        titleLB.backgroundColor = .clear
        titleLB.textColor = AppUIConfiguration.NeutralColor.title
        
        navView.addSubview(deleteLabel)
        deleteLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        deleteLabel.text = "\u{e71c}"
        deleteLabel.textColor = AppUIConfiguration.NeutralColor.secondaryText
        deleteLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDisappear(sender:)))
        deleteLabel.addGestureRecognizer(tap)
        
        self.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImageTitleContentImageCell.self, forCellReuseIdentifier: "ImageTitleContentImageCell")
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left(paddingLeft).top().bottom().width(screenWidth)
        navView.pin.top(statusBarHight).left().right().height(44.0)
        titleLB.pin.width(120.0).height(40.0).center()
        deleteLabel.pin.right(10.0).width(40.0).height(40.0).vCenter()
        tableView.pin.below(of: navView).marginTop(0).left().bottom().right()
    }
    
    
    let alp: CGFloat = 0.6
    let duration: TimeInterval = 0.2

    var paddingLeft = -screenWidth
    var navView = UIView()
    let titleLB = UILabel()
    let deleteLabel = UILabel()
    var tableView = UITableView(frame: .zero, style: .grouped)
    
    let viewModel = MXMenuViewModel()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MXMenuView {
    
    func show(with animation: Bool) -> Void {
        paddingLeft = 0
        
        if animation {
            UIView.animate(withDuration: duration) {
                self.pin.all()
            } completion: { (status) in
            }
        } else {
            self.pin.all()
        }
    }
    
    func disappear(with animation: Bool) -> Void {
        paddingLeft = -screenWidth
        
        if animation {
            UIView.animate(withDuration: duration) {
                self.pin.left(-screenWidth).top().bottom().width(screenWidth)
            } completion: { (status) in
                if let vc = self.superview?.next as? UIViewController {
                    vc.dismiss(animated: false, completion: nil)
                }
            }
        } else {
            self.pin.left(-screenWidth).top().bottom().width(screenWidth)
            if let vc = self.superview?.next as? UIViewController {
                vc.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}

extension MXMenuView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = viewModel.cellIdentifierForRowAt(indexPath: indexPath)
        let titleContentCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ImageTitleContentImageCell
        titleContentCell.contentView.backgroundColor = UIColor.clear
        titleContentCell.backgroundColor = UIColor.clear
        let model = viewModel.modelAtIndexPath(indexPath: indexPath)
        titleContentCell.updateSubviews(model: model)
        if indexPath.section == 0, indexPath.row == 0 {
            titleContentCell.isShowBg = true
            titleContentCell.leftImageLabel.textColor = AppUIConfiguration.MainColor.C0
            titleContentCell.bgView.pin.left(16).right(16).top().bottom()
            titleContentCell.bgView.backgroundColor = AppUIConfiguration.MXBackgroundColor.bgA
        } else {
            titleContentCell.isShowBg = false
            titleContentCell.leftImageLabel.textColor = AppUIConfiguration.NeutralColor.title
            titleContentCell.bgView.pin.all()
            titleContentCell.bgView.backgroundColor = .clear
        }
        return titleContentCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: .zero)
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 38
        }
        return 16
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath: indexPath)
    }
    
}


extension MXMenuView: UITableViewDelegate {
    
    
}
