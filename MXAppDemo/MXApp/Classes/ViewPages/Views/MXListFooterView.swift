
import Foundation

public enum MXDeviceMenuType : Int {
    case MXDeviceMenuType_Share = 0      
    case MXDeviceMenuType_Delete = 1   
    case MXDeviceMenuType_Rename = 2   
}

class MXListFooterView: UIView {
    
    public typealias DidActionCallback = (_ menuType: Int) -> ()
    public var didActionCallback : DidActionCallback!
    
    public var dataList = Array<[String: Any]>() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = AppUIConfiguration.MXAssistColor.shadow.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 16
        self.addSubview(self.collectionView)
        self.collectionView.pin.all()
    }
    
    override func layoutSubviews() {
        self.collectionView.pin.all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView = {
        let _layout = UICollectionViewFlowLayout()
        _layout.itemSize = CGSize.init(width: 80, height: 60)
        _layout.sectionInset = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        _layout.minimumInteritemSpacing = 20.0
        _layout.scrollDirection = .horizontal
        
        let _collectionview = UICollectionView (frame: self.bounds, collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXFooterMenuCell.self, forCellWithReuseIdentifier: String (describing: MXFooterMenuCell.self))
        _collectionview.register(UICollectionReusableView.self, forSupplementaryViewOfKind:UICollectionView.elementKindSectionFooter, withReuseIdentifier: String (describing: UICollectionReusableView.self))
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
}

extension MXListFooterView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var offset_x = 20.0 as CGFloat
        if self.dataList.count > 0 {
            offset_x = (self.frame.size.width - CGFloat(self.dataList.count * 100) + 20)/2.0
        }
        
        return UIEdgeInsets.init(top: 10.0, left: offset_x, bottom: 10.0, right: offset_x)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXFooterMenuCell.self), for: indexPath) as! MXFooterMenuCell
        cell.backgroundColor = UIColor.clear
        if self.dataList.count > indexPath.row {
            let item = self.dataList[indexPath.row]
            if let name = item["name"] as? String {
                cell.nameLab.text = name
            }
            if let type = item["type"] as? Int {
                switch type {
                case MXDeviceMenuType.MXDeviceMenuType_Share.rawValue:
                    cell.iconLB.text = "\u{e71a}"
                    cell.iconLB.backgroundColor = UIColor(hex: "00CBDE")
                    break
                case MXDeviceMenuType.MXDeviceMenuType_Delete.rawValue:
                    cell.iconLB.text = "\u{e719}"
                    cell.iconLB.backgroundColor = UIColor(hex: "FE6974")
                    break
                case MXDeviceMenuType.MXDeviceMenuType_Rename.rawValue:
                    cell.iconLB.text = "\u{e7cb}"
                    cell.iconLB.backgroundColor = UIColor(hex: "976FFB")
                    break
                default:
                    break
                }
            }
            
            if let enable = item["enable"] as? Bool {
                if !enable {
                    cell.iconLB.backgroundColor = AppUIConfiguration.NeutralColor.disable
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataList.count > indexPath.row {
            let item = self.dataList[indexPath.row]
            if let type = item["type"] as? Int, let enable = item["enable"] as? Bool {
                if enable {
                    self.didActionCallback?(type)
                }
            }
        }
    }
}
