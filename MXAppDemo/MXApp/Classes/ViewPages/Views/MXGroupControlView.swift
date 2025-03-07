
import Foundation

class MXGroupControlView: UIView {
    
    public typealias DidOptionCallback = () -> ()
    public var didOptionCallback : DidOptionCallback!
    public typealias DidSelectedCallback = (_ info: MXDeviceInfo, _ propertyInfo:MXPropertyInfo) -> ()
    public var didSelectedCallback : DidSelectedCallback!
    
    let contentViewMarginLeft: CGFloat = 10.0
    var contentViewH: CGFloat = 218
    var itemMarginLeft: CGFloat = 75.0

    var itemMarginTop: CGFloat = 68.0

    let itemWidth: CGFloat = 80
    
    let itemHeight: CGFloat = 80

    var minimumInteritemSpacing: CGFloat = 16.0
    
    public var name: String = ""
    
    var groupInfo: MXDeviceInfo?
    
    func show() -> Void {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window
        else { return  }
        
        itemMarginTop = 37.0
        contentViewH = 218
        if self.dataSources.count > 1 {
            contentViewH = 368
            itemMarginTop = 24
        }
        itemMarginLeft = (screenWidth - contentViewMarginLeft * 2 - minimumInteritemSpacing - itemWidth * 2)/2.0
        
        nameLabel.text = self.name
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            window.addSubview(self)
        }
    }
    
    @objc func disappearButtonAction(sender: UIButton) {
        disappear()
    }
    
    @objc func options(sender: UIButton) -> Void {
        self.didOptionCallback?()
        disappear()
    }
    
    func disappear() -> Void {
        NotificationCenter.default.removeObserver(self)
        self.removeFromSuperview()
    }
    
    init(title: String, dataList:[MXPropertyInfo]) {
        super.init(frame: .zero)
        self.name = title
        self.dataSources = dataList
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        
        self.addSubview(disappearButton)
        disappearButton.addTarget(self, action: #selector(disappearButtonAction(sender:)), for: UIControl.Event.touchUpInside)
        
        self.addSubview(contentView)
        contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(nameLabel)
        nameLabel.text = "XXX-XXXX"
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont.mxMediumFont(size: AppUIConfiguration.TypographySize.H4)
        nameLabel.textAlignment = .center
        
        contentView.addSubview(optionsLabel)
        optionsLabel.text = "\u{e6e0}"
        optionsLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H1)
        optionsLabel.textColor = AppUIConfiguration.NeutralColor.disable
        let tap = UITapGestureRecognizer(target: self, action: #selector(options(sender:)))
        optionsLabel.isUserInteractionEnabled = true
        optionsLabel.addGestureRecognizer(tap)
        
        contentView.addSubview(moreLabel)
        moreLabel.text = "\u{e736}"
        moreLabel.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H6)
        moreLabel.textColor = AppUIConfiguration.NeutralColor.disable
        moreLabel.textAlignment = .center
                
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MXGroupControlViewCell.self, forCellWithReuseIdentifier: "CELL")
        collectionView.register(MXGroupFooterView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: String (describing: MXGroupFooterView.self))
        collectionView.delaysContentTouches = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.left().right().top().bottom()
        disappearButton.pin.all()
        contentView.pin.left(contentViewMarginLeft).right(contentViewMarginLeft).bottom(contentViewMarginLeft).height(contentViewH)
        nameLabel.pin.left().right().top(16).height(20)
        optionsLabel.pin.top().right().height(50).width(50)
        moreLabel.pin.bottom(16).height(12).width(12).hCenter()
        collectionView.pin.below(of: nameLabel).left().right().above(of: moreLabel)
    }
    
    let disappearButton = UIButton()

    let contentView = UIView()
    
    let nameLabel = UILabel()
    
    let optionsLabel = UILabel()
    
    let moreLabel = UILabel()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var dataSources = [MXPropertyInfo]()
    
    
}

extension MXGroupControlView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath) as! MXGroupControlViewCell
        cell.nameLabel.text = indexPath.row%2 == 0 ? localized(key:"开启") : localized(key:"关闭")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.dataSources.count > 1 {
            return CGSize(width: screenWidth - contentViewMarginLeft * 2, height: 40)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionView.elementKindSectionFooter {
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String (describing: MXGroupFooterView.self), for: indexPath as IndexPath) as! MXGroupFooterView
            reusableview.backgroundColor = UIColor.clear
            if self.dataSources.count > indexPath.section {
                let pInfo = self.dataSources[indexPath.section]
                reusableview.titleLB.text = pInfo.name
            }
            return reusableview
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level2.DADADA
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level2.F8F8F7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: itemMarginTop, left: itemMarginLeft, bottom: 0, right: itemMarginLeft)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let info = self.groupInfo, self.dataSources.count > indexPath.section {
            let pInfo = self.dataSources[indexPath.section]
            pInfo.value = (indexPath.row%2 == 0 ? 1 : 0) as AnyObject
            self.didSelectedCallback?(info, pInfo)
        }
    }
    
}

class MXGroupControlViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() -> Void {
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level2.F8F8F7
        self.contentView.addSubview(nameLabel)
        nameLabel.text = localized(key: "开启")
        nameLabel.textColor = AppUIConfiguration.NeutralColor.title
        nameLabel.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H5)
        nameLabel.textAlignment = .center
        
        self.contentView.addSubview(imageView)
        imageView.text = "\u{e749}"
        imageView.textColor = AppUIConfiguration.NeutralColor.title
        imageView.font = UIFont.iconFont(size: AppUIConfiguration.TypographySize.H0)
        imageView.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.pin.left().right().bottom(15).height(18)
        imageView.pin.above(of: nameLabel, aligned: .center).marginBottom(8).width(24).height(24)
        self.contentView.layer.cornerRadius = 16.0
        self.contentView.layer.masksToBounds = true
    }
    
    
    let imageView = UILabel()
    
    let nameLabel = UILabel()
    
}

class MXGroupFooterView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLB)
        self.titleLB.pin.left(20).right(20).top(16).height(16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLB.pin.left(20).right(20).top(16).height(16)
    }
    
    lazy public var titleLB : UILabel = {
        let _titleLB = UILabel(frame: CGRect.init(x: 20, y: 0, width: self.frame.size.width-40, height: 16))
        _titleLB.backgroundColor = UIColor.clear
        _titleLB.textAlignment = .center
        _titleLB.font = UIFont.systemFont(ofSize: AppUIConfiguration.TypographySize.H6)
        _titleLB.textColor = AppUIConfiguration.NeutralColor.primaryText
        
        return _titleLB
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
