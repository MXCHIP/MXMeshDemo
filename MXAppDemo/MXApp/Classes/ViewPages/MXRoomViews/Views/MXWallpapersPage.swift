
import Foundation
import UIKit

class MXWallpapersPage: MXBaseViewController {
    
    let dataSources = ["AEF0FE", "ACD9D2", "C5F0DD", "F2CE9C", "F0C8B1", "E8DBC8", "DFE7F2", "D2CFFE", "ABB8E6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavView()
        initSubviews()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func initNavView() -> Void {
        self.title = localized(key: "房间壁纸")
    }
    
    func initSubviews() -> Void {
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = AppUIConfiguration.backgroundColor.level1.FFFFFF
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MXWallpapersViewCell.self, forCellWithReuseIdentifier: "MXWallpapersViewCell")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.pin.all()
    }
        
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
}

class MXWallpapersViewCell: UICollectionViewCell {
    
    func updateCell(with color: UIColor) -> Void {
        gradientLayer.colors = [color.cgColor, color.withAlphaComponent(0.0).cgColor]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() -> Void {
        
        self.contentView.layer.addSublayer(gradientLayer)
        gradientLayer.pin.all()
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint  = CGPoint.init(x: 0, y: 1.0)
        gradientLayer.cornerRadius = 8
        gradientLayer.masksToBounds = true
    }
    
    let gradientLayer = CAGradientLayer()
}

extension MXWallpapersPage: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.dataSources.count > indexPath.row {
            let color = self.dataSources[indexPath.row]
            let url = "https://com.mxchip.bta/page/home/room/wallpaperPreview"
            let params = ["color": color]
            MXURLRouter.open(url: url, params: params)
        }
    }
    
}

extension MXWallpapersPage: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MXWallpapersViewCell", for: indexPath) as! MXWallpapersViewCell
        if self.dataSources.count > indexPath.row {
            let color = self.dataSources[indexPath.row]
            cell.updateCell(with: UIColor(hex: color))
        }
        return cell
    }
    
}

extension MXWallpapersPage: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (screenWidth - 16 * 2 - 10 * 2) / 3 - 1
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension MXWallpapersPage: MXURLRouterDelegate {
    
    static func controller(withParams params: Dictionary<String, Any>) -> AnyObject {
        
        let vc = MXWallpapersPage()
        return vc
    }
    
}
