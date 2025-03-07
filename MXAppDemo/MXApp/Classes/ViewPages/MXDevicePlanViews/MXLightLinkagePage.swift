//
//  MXLightLinkagePage.swift
//  MXApp
//
//  Created by mxchip on 2023/10/24.
//

import Foundation
import UIKit
import MeshSDK

class MXLightLinkagePage: MXBaseViewController {
    
    var device: MXDeviceInfo?
    var headerImgView: UIImageView = UIImageView(image: UIImage(named: "light_linkage_header"))
    var headerLB: UILabel = UILabel(frame: .zero)
    
    @objc func gotoDetail() -> Void {
        var params = [String : Any]()
        params["device"] = self.device
        MXURLRouter.open(url: "https://com.mxchip.bta/page/device/detail", params: params)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubviews()
        
    }
    
    func initSubviews() -> Void {
        self.title = "电视追光控制盒"
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        rightBtn.titleLabel?.font = UIFont.iconFont(size: 24)
        rightBtn.setTitleColor(.white, for: .normal)
        rightBtn.setTitle("\u{e75b}", for: .normal)
        rightBtn.addTarget(self, action: #selector(gotoDetail), for: .touchUpInside)
        self.mxNavigationBar.rightView.addSubview(rightBtn)
        rightBtn.pin.right().top().width(44).height(AppUIConfiguration.navBarH)
        
        self.headerImgView.frame = CGRect(x: 24, y: 44, width: self.view.frame.size.width - 48, height: 142)
        self.headerImgView.backgroundColor = .clear
        self.headerImgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.headerImgView)
        
        self.headerLB.frame = CGRect(x: 20, y: 226, width: self.view.frame.size.width - 40, height: 16)
        self.headerLB.text = "提示：上方1 ~ 9代表9个色块，请为每个色块添加灯设备"
        self.headerLB.textColor = .white
        self.headerLB.backgroundColor = .clear
        self.headerLB.font = UIFont.systemFont(ofSize: 12)
        self.headerLB.textAlignment = .left
        self.contentView.addSubview(self.headerLB)
        self.headerLB.pin.left(20).right(20).height(16).below(of: self.headerImgView).marginTop(40)
        
        self.contentView.addSubview(tableView)
        self.tableView.pin.left(16).right(16).below(of: self.headerLB).marginTop(16).bottom()
        
        self.mxNavigationBar.backgroundColor = .black
        self.backBtn?.setTitleColor(.white, for: .normal)
        self.mxNavigationBar.titleLB.textColor = .white
        self.contentView.backgroundColor = .black
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.headerImgView.pin.left(24).right(24).top(44).height(142)
        self.headerLB.pin.left(20).right(20).height(16).below(of: self.headerImgView).marginTop(40)
        self.tableView.pin.left(16).right(16).below(of: self.headerLB).marginTop(16).bottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private lazy var tableView :MXBaseTableView = {
        let tableView = MXBaseTableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(MXLightLinkageViewCell.self, forCellReuseIdentifier: "MXLightLinkageViewCell")
        return tableView
    }()
    
    func loadSelectedDevices(index:Int) -> [MXDeviceInfo]? {
        return nil
    }
    func update(devices: [MXDeviceInfo]) -> Void {
        MXHomeManager.shard.currentHome?.rooms.forEach({ (room:MXRoomInfo) in
            room.devices.forEach { (device:MXDeviceInfo) in
                if let newDevice = devices.first(where: {$0.isSameFrom(device)}) {
                    
                }
            }
        })
        self.tableView.reloadData()
    }
}

extension MXLightLinkagePage: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MXLightLinkageViewCell", for: indexPath) as! MXLightLinkageViewCell
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.iconView.text = String(indexPath.section + 1)
        cell.detailLB.text = "未设置"
        if let selectedList = self.loadSelectedDevices(index: indexPath.section), selectedList.count > 0 {
            cell.detailLB.text = String(format: "%d个灯", selectedList.count)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = self.loadSelectedDevices(index: indexPath.section)
        let selectDeviceView = MXLinkageSelectedDevicesView(frame: .zero)
        selectDeviceView.show(in: self.view, with: selectedList) { devices in
            self.update(devices: devices)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        tableView.backgroundColor = .clear
        return v
    }
}

extension MXLightLinkagePage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        let vc = MXLightLinkagePage()
        vc.device = params["device"] as? MXDeviceInfo
        return vc
    }
    
}

class MXLightLinkageViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.1)
        
        self.contentView.addSubview(self.iconView)
        self.iconView.pin.left(16).width(24).height(24).vCenter()
        
        self.contentView.addSubview(self.nameLB)
        self.nameLB.pin.right(of: self.iconView).marginLeft(2).height(20).width(80).vCenter()
        
        self.contentView.addSubview(self.detailLB)
        self.detailLB.pin.right(of: self.nameLB).marginLeft(8).height(20).right(16).vCenter()
        
        self.corner(byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radii: 16)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.pin.left(16).width(24).height(24).vCenter()
        self.nameLB.pin.right(of: self.iconView).marginLeft(2).height(20).width(80).vCenter()
        self.detailLB.pin.right(of: self.nameLB).marginLeft(8).height(20).right(16).vCenter()
        self.corner(byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radii: 16)
    }
    
    public lazy var iconView : UILabel = {
        let _iconView = UILabel(frame: CGRect(x: 16, y: 28, width: 24, height: 24))
        _iconView.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.15)
        _iconView.layer.masksToBounds = true
        _iconView.layer.cornerRadius = 12
        _iconView.textColor = .white
        _iconView.textAlignment = .center
        _iconView.font = UIFont.systemFont(ofSize: 15)
        return _iconView
    }()
    
    public lazy var nameLB : UILabel = {
        let _nameLB = UILabel(frame: CGRect(x: 42, y: 30, width: 100, height: 20))
        _nameLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _nameLB.backgroundColor = .clear
        _nameLB.textColor = .white;
        _nameLB.textAlignment = .left
        _nameLB.text = "追光色块"
        return _nameLB
    }()
    
    public lazy var detailLB : UILabel = {
        let _detailLB = UILabel(frame: CGRect(x: 16, y: 100, width: 24, height: 24))
        _detailLB.backgroundColor = .clear
        _detailLB.textColor = UIColor(hex: "FFFFFF",alpha: 0.65)
        _detailLB.textAlignment = .right
        _detailLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4);
        _detailLB.text = "未设置"
        return _detailLB
    }()
}
