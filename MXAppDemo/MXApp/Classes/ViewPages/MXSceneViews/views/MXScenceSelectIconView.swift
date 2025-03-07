
import Foundation
import SDWebImage


class MXScenceSelectIconView: UIView {
    
    public typealias SelectIconCallback = (_ valueStr: String) -> ()
    public var selectIconCallback : SelectIconCallback?
    public var selectColorCallback : SelectIconCallback?
    var contentView: UIView!
    
    public var iconList = [[String : Any]]() {
        didSet {
            DispatchQueue.main.async {
                self.iconSelectView.reloadData()
            }
        }
    }
    public var colorList = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.colorSelectView.reloadData()
            }
        }
    }
    
    public var selectedIcon : String?
    public var selectedColorHex : String?
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = .clear
        
        let bgView = UIView(frame: UIScreen.main.bounds)
        bgView.backgroundColor = AppUIConfiguration.MXAssistColor.mask.withAlphaComponent(0.4)
        self.addSubview(bgView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        bgView.addGestureRecognizer(tapGesture)
        
        self.colorList = ["FE6974","FF8062","FEC60C","37C453","00CBA7","00CBDE","29A3FF","5C70FF","976FFB","FF5BA3"]
        
        let viewH : CGFloat = 322
        self.contentView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - viewH, width: UIScreen.main.bounds.width, height: viewH))
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        self.addSubview(self.contentView)
        
        self.contentView.addSubview(self.titleView)
        let titleW: CGFloat = min(UIScreen.main.bounds.width - 40, self.titleView.contentWidth)
        self.titleView.pin.top(20).height(48).width(titleW).hCenter()
        
        self.contentView.addSubview(self.contentScrollView)
        self.contentScrollView.pin.below(of: self.titleView).marginTop(10).bottom(self.pin.safeArea.bottom).left().right()
        
        self.contentScrollView.addSubview(self.colorSelectView)
        self.colorSelectView.pin.left().top().bottom().width(self.contentScrollView.frame.width)
        self.contentScrollView.addSubview(self.iconSelectView)
        self.iconSelectView.pin.left(self.contentScrollView.frame.width).top().bottom().width(self.contentScrollView.frame.width)
        
        self.contentView.backgroundColor = AppUIConfiguration.floatViewColor.level1.FFFFFF

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewH : CGFloat = 322 + self.pin.safeArea.bottom
        self.contentView.pin.left().right().bottom().height(viewH)
        self.contentView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 16)
        let titleW: CGFloat = min(UIScreen.main.bounds.width - 40, self.titleView.contentWidth)
        self.titleView.pin.top(20).height(48).width(titleW).hCenter()
        self.contentScrollView.pin.below(of: self.titleView).marginTop(10).bottom(self.pin.safeArea.bottom).left().right()
        self.colorSelectView.pin.left().top().bottom().width(self.contentScrollView.frame.width)
        self.iconSelectView.pin.left(self.contentScrollView.frame.width).top().bottom().width(self.contentScrollView.frame.width)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleView : MXPageHeadView = {
        
        var attri = MXPageHeadTextAttribute()
        attri.needBottomLine = true
        attri.defaultFontSize = AppUIConfiguration.TypographySize.H1
        attri.defaultTextColor = AppUIConfiguration.NeutralColor.secondaryText
        attri.selectedFontSize = AppUIConfiguration.TypographySize.H1
        attri.selectedTextColor = AppUIConfiguration.NeutralColor.title
        attri.bottomLineWidth = 4
        attri.bottomLineHeight = 4
        attri.bottomLineColor = AppUIConfiguration.NeutralColor.title
        attri.itemSpacing = 10
        attri.itemOffset = 0
        attri.itemWidth = 80
        
        let titles = [localized(key:"颜色"),localized(key:"图标")]
        let _HeadView = MXPageHeadView (frame: CGRect (x: 0, y: 20, width: 200, height: 48), titles: titles, delegate: self ,textAttributes:attri)
        _HeadView.backgroundColor = UIColor.clear
        return _HeadView
    }()
    
    lazy var contentScrollView : UIScrollView = {
        let _scrollV = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 254))
        _scrollV.backgroundColor = .clear
        _scrollV.showsHorizontalScrollIndicator = false
        _scrollV.showsVerticalScrollIndicator = false
        _scrollV.isPagingEnabled = true
        return _scrollV
    }()
    
    lazy var iconSelectView: MXCollectionView = {
        let _layout = MXHeadersFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 20.0, left: 15.0, bottom: 0.0, right: 20.0)
        _layout.minimumInteritemSpacing = 12.0
        _layout.minimumLineSpacing = 12.0
        _layout.itemSize = CGSize(width: 60, height: 60)
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 254), collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXSceneSelectIconCell.self, forCellWithReuseIdentifier: String (describing: MXSceneSelectIconCell.self))
        _collectionview.backgroundColor  = UIColor.clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = true
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            _collectionview.contentInsetAdjustmentBehavior = .never
        }
        return _collectionview
    }()
    
    lazy var colorSelectView: MXCollectionView = {
        let _layout = MXHeadersFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 20.0, left: 15.0, bottom: 0.0, right: 20.0)
        _layout.minimumInteritemSpacing = 12.0
        _layout.minimumLineSpacing = 12.0
        _layout.itemSize = CGSize(width: 60, height: 60)
        _layout.scrollDirection = .vertical
        
        let _collectionview = MXCollectionView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 254), collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXSceneSelectIconCell.self, forCellWithReuseIdentifier: String (describing: MXSceneSelectIconCell.self))
        _collectionview.backgroundColor  = UIColor.clear
        _collectionview.showsHorizontalScrollIndicator = false
        _collectionview.showsVerticalScrollIndicator = false
        _collectionview.alwaysBounceVertical = true
        _collectionview.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        if #available(iOS 11.0, *) {
            _collectionview.contentInsetAdjustmentBehavior = .never
        }
        return _collectionview
    }()
    
    @objc func hide() {
        self.removeFromSuperview()
    }
    
    
    func show() {
        if self.superview != nil {
            return
        }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        
        window.addSubview(self)
        self.pin.left().right().top().bottom()
    }
}

extension MXScenceSelectIconView:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.iconSelectView {
            return self.iconList.count
        } else if collectionView == self.colorSelectView {
            return self.colorList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXSceneSelectIconCell.self), for: indexPath) as! MXSceneSelectIconCell
        cell.backgroundColor = UIColor.clear
        
        cell.iconView.image = nil
        cell.iconView.backgroundColor = .clear
        if collectionView == self.colorSelectView  {
            cell.bgView.layer.cornerRadius = 30.0
            cell.bgView.layer.borderWidth = 0
            cell.bgView.layer.borderColor = UIColor.clear.cgColor
            cell.iconView.pin.width(40).height(40).center()
            cell.iconView.layer.cornerRadius = 20
            if self.colorList.count > indexPath.row {
                let colorHex = self.colorList[indexPath.row]
                cell.iconView.backgroundColor = UIColor(hex: colorHex)
                if colorHex == self.selectedColorHex {
                    cell.bgView.layer.borderWidth = 3.0
                    cell.bgView.layer.borderColor = UIColor(hex: colorHex).cgColor
                }
            }
        } else {
            cell.bgView.layer.cornerRadius = 20.0
            cell.bgView.layer.borderWidth = 0
            cell.bgView.layer.borderColor = UIColor.clear.cgColor
            cell.iconView.pin.width(32).height(32).center()
            cell.iconView.layer.cornerRadius = 0
            if self.iconList.count > indexPath.row {
                let iconInfo = self.iconList[indexPath.row]
                if let imageUrl = iconInfo["image"] as? String {
                    cell.iconView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: imageUrl)?.mx_imageByTintColor(color: UIColor(hex: self.selectedColorHex ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))) { (image :UIImage?, error:Error?, cacheType:SDImageCacheType, imageURL:URL? ) in
                        if let img = image {
                            cell.iconView.image = img.mx_imageByTintColor(color: UIColor(hex: self.selectedColorHex ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString))
                        }
                    }
                    if imageUrl == self.selectedIcon {
                        cell.bgView.layer.borderWidth = 3.0
                        cell.bgView.layer.borderColor = UIColor(hex: self.selectedColorHex ?? AppUIConfiguration.NeutralColor.secondaryText.toHexString).cgColor
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.colorSelectView  {
            if self.colorList.count > indexPath.row {
                let colorHex = self.colorList[indexPath.row]
                self.selectedColorHex = colorHex
                self.selectColorCallback?(colorHex)
                DispatchQueue.main.async {
                    self.colorSelectView.reloadData()
                }
            }
        } else {
            if self.iconList.count > indexPath.row {
                let iconInfo = self.iconList[indexPath.row]
                if let imageUrl = iconInfo["image"] as? String {
                    self.selectedIcon = imageUrl
                    self.selectIconCallback?(imageUrl)
                    DispatchQueue.main.async {
                        self.iconSelectView.reloadData()
                    }
                }
            }
        }
    }
}

extension MXScenceSelectIconView : MXPageHeadViewDelegate {
    
    func mx_pageHeadViewSelectedAt(_ index: Int) {
        self.contentScrollView.setContentOffset(CGPoint(x: self.contentScrollView.frame.size.width*CGFloat(index), y: 0), animated: true)
        if index == 0 {
            DispatchQueue.main.async {
                self.colorSelectView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.iconSelectView.reloadData()
            }
        }
    }

}

class MXSceneSelectIconCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    public func setupViews() {
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.bgView)
        self.bgView.pin.all()
        
        self.bgView.addSubview(self.iconView)
        self.iconView.pin.width(32).height(32).center()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var bgView : UIView = {
        let _bgView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        _bgView.backgroundColor = UIColor.clear
        _bgView.layer.masksToBounds = true
        _bgView.clipsToBounds = true
        _bgView.layer.cornerRadius = 20
        return _bgView
    }()
    
    public lazy var iconView : UIImageView = {
        let _iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        _iconView.backgroundColor = UIColor.clear
        _iconView.clipsToBounds = true
        return _iconView
    }()
}
