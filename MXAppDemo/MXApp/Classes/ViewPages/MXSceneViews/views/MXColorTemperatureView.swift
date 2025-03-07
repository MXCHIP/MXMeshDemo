
import Foundation
import UIKit

class MXColorTemperatureView: UIView {
    
    public typealias ValueChangeCallback = (_ value: Double) -> ()
    public var valueCallback : ValueChangeCallback?
    public var currentPercent: Double = 0 {
        didSet {
            if self.currentPercent != self.colorControl.currentPercent {
                self.colorControl.refreshPointLocation(precent: self.currentPercent)
            }
            self.selectView.reloadData()
            self.valueCallback?(self.currentPercent)
        }
    }
    
    var colorControl: MXRadialCircleView!
    
    lazy var selectView: MXCollectionView = {
        let _layout = MXHeadersFlowLayout()
        _layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        _layout.minimumInteritemSpacing = 24.0
        _layout.minimumLineSpacing = 24.0
        _layout.itemSize = CGSize(width: 32, height: 32)
        _layout.scrollDirection = .horizontal
        
        let _collectionview = MXCollectionView (frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 32), collectionViewLayout: _layout)
        _collectionview.delegate  = self
        _collectionview.dataSource = self
        _collectionview.register(MXSceneSelectIconCell.self, forCellWithReuseIdentifier: String (describing: MXSceneSelectIconCell.self))
        _collectionview.backgroundColor  = .clear
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.colorControl = MXRadialCircleView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width))
        self.colorControl.valueCallback = { (value:Double) in
            if self.currentPercent != value {
                self.currentPercent = value
            }
        }
        self.addSubview(self.colorControl)
        self.addSubview(self.selectView)
        var selectW: CGFloat = 3*32 + 2*24
        var selectX: CGFloat = (self.frame.size.width - selectW)/2.0
        if selectX < 0 {
            selectX = 0
            selectW = self.frame.size.width
        }
        self.selectView.pin.below(of: self.colorControl).marginTop(20).left(selectX).width(selectW).height(32)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorControl.pin.left().top().right().height(self.frame.size.width)
        var selectW: CGFloat = 3*32 + 2*24
        var selectX: CGFloat = (self.frame.size.width - selectW)/2.0
        if selectX < 0 {
            selectX = 0
            selectW = self.frame.size.width
        }
        self.selectView.pin.below(of: self.colorControl).marginTop(20).left(selectX).width(selectW).height(32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MXColorTemperatureView:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String (describing: MXSceneSelectIconCell.self), for: indexPath) as! MXSceneSelectIconCell
        cell.backgroundColor = UIColor.clear
        cell.iconView.image = nil
        cell.iconView.backgroundColor = .clear
        cell.bgView.layer.cornerRadius = 16.0
        cell.bgView.layer.borderWidth = 2
        cell.bgView.layer.borderColor = UIColor.clear.cgColor
        cell.iconView.pin.width(24).height(24).center()
        cell.iconView.layer.cornerRadius = 12
        if indexPath.row == 0 {
            cell.bgView.layer.borderColor = UIColor(hex: "30B5FF").cgColor
            cell.iconView.backgroundColor = UIColor(hex: "30B5FF")
            cell.bgView.backgroundColor = (self.currentPercent == 100 ? .clear : UIColor(hex: "30B5FF"))
        } else if indexPath.row == 1 {
            cell.bgView.layer.borderColor = UIColor(hex: "F5B958").cgColor
            cell.iconView.backgroundColor = UIColor(hex: "F5B958")
            cell.bgView.backgroundColor = (self.currentPercent == 0 ? .clear : UIColor(hex: "F5B958"))
        } else if indexPath.row == 2 {
            cell.bgView.layer.borderColor = UIColor(hex: "FCE9C9").cgColor
            cell.iconView.backgroundColor = UIColor(hex: "FCE9C9")
            cell.bgView.backgroundColor = (self.currentPercent == 50 ? .clear : UIColor(hex: "FCE9C9"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.currentPercent = 100
        } else if indexPath.row == 1 {
            self.currentPercent = 0
        } else if indexPath.row == 2 {
            self.currentPercent = 50
        }
    }
}


