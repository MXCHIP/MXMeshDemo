
import Foundation

class MXSceneSwitchSettingView: UIView {
    
    public typealias SureActionCallback = (_ selectedValue: Bool) -> ()
    public var sureActionCallback : SureActionCallback?
    var contentView: UIView!
    public var switchValue: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        let viewH : CGFloat = 250
        self.contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - viewH - 10, width: self.frame.size.width, height: viewH))
        self.contentView.backgroundColor = AppUIConfiguration.backgroundColor.level1.F2F2F7
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.addSubview(self.contentView)
        self.contentView.pin.left().right().bottom().height(viewH)
        
        self.contentView.addSubview(self.titleView)
        self.titleView.pin.left().top().right().height(50)
        
        self.contentView.addSubview(self.mxCollectionView)
        self.mxCollectionView.pin.below(of: self.titleView).marginTop(0).left().right().bottom()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var contentH: CGFloat = 160
        contentH += self.pin.safeArea.bottom
        let maxH:CGFloat = screenHeight - (AppUIConfiguration.statusBarH + AppUIConfiguration.navBarH)
        let minH:CGFloat = 250
        if contentH > maxH  {
            contentH = maxH
        } else if contentH < minH {
            contentH = minH
        }
        self.contentView.pin.left().right().bottom().height(contentH)
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.titleView.pin.left().top().right().height(50)
        self.titleLB.pin.left(80).right(80).height(20).vCenter()
        self.leftBtn.pin.left(16).top().width(48).bottom()
        self.rightBtn.pin.right(16).top().width(48).bottom()
        self.lineView.pin.left().right().bottom().height(1)
        self.mxCollectionView.pin.below(of: self.titleView).marginTop(0).left().right().bottom()
        self.mxCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var titleLB : UILabel = {
        let _titleLB = UILabel(frame: .zero)
        _titleLB.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4);
        _titleLB.textColor = AppUIConfiguration.NeutralColor.title;
        _titleLB.textAlignment = .center
        _titleLB.text = localized(key: "请选择执行动作")
        return _titleLB
    }()
    
    lazy var titleView : UIView = {
        let _titleView = UIView(frame: CGRect(x: 0, y: 0, width:0, height: 50))
        _titleView.backgroundColor = .clear
        
        _titleView.addSubview(self.titleLB)
        self.titleLB.pin.left(80).right(80).height(20).vCenter()
        
        _titleView.addSubview(self.leftBtn)
        self.leftBtn.pin.left(16).top().width(48).bottom()
        
        _titleView.addSubview(self.rightBtn)
        self.rightBtn.pin.right(16).top().width(48).bottom()
        
        _titleView.addSubview(self.lineView)
        self.lineView.pin.left().right().bottom().height(1)
        
        return _titleView
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
        _rightBtn.setTitle(localized(key:"完成"), for: .normal)
        _rightBtn.setTitleColor(AppUIConfiguration.NeutralColor.title, for: .normal)
        _rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H4)
        _rightBtn.backgroundColor = .clear
        _rightBtn.addTarget(self, action: #selector(rightBtnAction), for: .touchUpInside)
        return _rightBtn
    }()
    
    lazy var lineView : UIView = {
        let _lineView = UILabel(frame: .zero)
        _lineView.backgroundColor = AppUIConfiguration.NeutralColor.dividers
        return _lineView
    }()
    
    lazy var mxCollectionView: MXCollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 12.0, left: 10.0, bottom: 0.0, right: 10.0)
        _layout.minimumInteritemSpacing = 10.0
        _layout.minimumLineSpacing = 10.0
        _layout.itemSize = CGSize(width: (screenWidth - 30)/2.0, height: 80)
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 254), collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXScenePropertyEnumCell.self, forCellWithReuseIdentifier: String (describing: MXScenePropertyEnumCell.self))
        
        _collectionview.register(MXCollectionHeaderView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: String (describing: MXCollectionHeaderView.self))
        _collectionview.backgroundColor  = UIColor.clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = false
        _collectionview.alwaysBounceHorizontal = false
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            _collectionview.contentInsetAdjustmentBehavior = .never
        }
        return _collectionview
    }()
    
    @objc func leftBtnAction() {
        self.dismiss()
    }
    
    @objc func rightBtnAction() {
        self.dismiss()
        self.sureActionCallback?(self.switchValue)
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

extension MXSceneSwitchSettingView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth - 30)/2.0, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXScenePropertyEnumCell.self), for: indexPath) as! MXScenePropertyEnumCell
        cell.canSelected = true
        cell.isMXSelected = false
        if indexPath.row == 0 {
            cell.nameLab.text = localized(key: "关闭")
            cell.isMXSelected = !self.switchValue
        } else {
            cell.nameLab.text = localized(key: "开启")
            cell.isMXSelected = self.switchValue
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.switchValue = false
        } else {
            self.switchValue = true
        }
        self.mxCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize.zero
    }
        
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionView.elementKindSectionHeader {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXCollectionHeaderView.self), for: indexPath as IndexPath) as! MXCollectionHeaderView
            reusableview.backgroundColor = UIColor.clear
            reusableview.moreBtn.isHidden = true
            return reusableview
        }
        return UICollectionReusableView()
    }
}
