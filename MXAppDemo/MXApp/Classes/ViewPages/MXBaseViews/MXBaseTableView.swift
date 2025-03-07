
import Foundation
import UIKit

class MXBaseTableView: UITableView,UIGestureRecognizerDelegate {
    
    public var canSimultaneously = false
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.backgroundColor = UIColor.clear
        if #available(iOS 15.0, *) {
            self.sectionHeaderTopPadding = 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.emptyView?.pin.all()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return canSimultaneously
    }
}

class MXCollectionView: UICollectionView {
    
    public var emptyHeight: CGFloat = 0
    var _headerView : UIView?
    public var headerView: UIView? {
        get {
            return _headerView
        }
        set {
            _headerView?.removeFromSuperview()
            _headerView = newValue
            if _headerView != nil {
                self.addSubview(_headerView!)
            }
            let headerView_h = _headerView?.frame.height ?? 0
            let footerView_h = _footerView?.frame.height ?? 0
            
            self.scrollIndicatorInsets = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            
            self.contentInset = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            self.layoutSubviews()
        }
    }
    
    var _footerView: UIView?
    public var footerView: UIView? {
        get {
            return _footerView
        }
        set {
            _footerView?.removeFromSuperview()
            _footerView = newValue
            if _footerView != nil {
                self.addSubview(_footerView!)
            }
            let headerView_h = _headerView?.frame.height ?? 0
            let footerView_h = _footerView?.frame.height ?? 0
            
            self.scrollIndicatorInsets = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            
            self.contentInset = UIEdgeInsets.init(top: headerView_h, left: 0, bottom: footerView_h, right: 0)
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h = self.frame.size.height
        let content_h = self.contentSize.height
        let headerView_h = _headerView?.frame.height ?? 0
        let footerView_h = _footerView?.frame.height ?? 0
        
        
        
        
        _headerView?.pin.left().right().top(-headerView_h).height(headerView_h)
        _footerView?.pin.left().right().bottom(-(content_h-h+footerView_h)).height(footerView_h)
        self.emptyView?.pin.left().right().top().height(self.frame.size.height-headerView_h-footerView_h)
        if self.emptyHeight > 0 {
            self.emptyView?.pin.left().right().top().height(self.emptyHeight)
        }
        if let empty_view = self.emptyView, content_h == 0 {
            _footerView?.pin.left().right().height(footerView_h).below(of: empty_view).marginTop(0)
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}

class MXHeadersFlowLayout: UICollectionViewFlowLayout {
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
        
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect)
            else { return nil }
        
        
        var newLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        let sectionsToAdd = NSMutableIndexSet()
        
        
        for layoutAttributesSet in layoutAttributes {
            
            if layoutAttributesSet.representedElementCategory == .cell {
                
                newLayoutAttributes.append(layoutAttributesSet)
            } else if layoutAttributesSet.representedElementCategory == .supplementaryView {
                
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
            }
        }
        
        
        for section in sectionsToAdd {
            let indexPath = IndexPath(item: 0, section: section)
            
            
            if let headerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                                                                                    UICollectionView.elementKindSectionHeader, at: indexPath) {
                newLayoutAttributes.append(headerAttributes)
            }
            
            
            if let footerAttributes = self.layoutAttributesForSupplementaryView(ofKind:
                                                                                    UICollectionView.elementKindSectionFooter, at: indexPath) {
                newLayoutAttributes.append(footerAttributes)
            }
        }
        
        return newLayoutAttributes
    }
    
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind:
            elementKind, at: indexPath) else { return nil }
        
        
        if elementKind != UICollectionView.elementKindSectionHeader {
            return layoutAttributes
        }
        
        
        guard let boundaries = boundaries(forSection: indexPath.section)
            else { return layoutAttributes }
        guard let collectionView = collectionView else { return layoutAttributes }
        
        
        let contentOffsetY = collectionView.contentOffset.y
        
        var frameForSupplementaryView = layoutAttributes.frame
        
        
        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height
        
        
        if contentOffsetY < minimum {
            frameForSupplementaryView.origin.y = minimum
        }
        
        else if contentOffsetY > maximum {
            frameForSupplementaryView.origin.y = maximum
        }
        
        
        else {
            frameForSupplementaryView.origin.y = contentOffsetY
        }
        
        
        layoutAttributes.frame = frameForSupplementaryView
        return layoutAttributes
    }
    
    
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))
        
        
        guard let collectionView = collectionView else { return result }
        
        
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        
        guard numberOfItems > 0 else { return result }
        
        
        let first = IndexPath(item: 0, section: section)
        let last = IndexPath(item: (numberOfItems - 1), section: section)
        if let firstItem = layoutAttributesForItem(at: first),
            let lastItem = layoutAttributesForItem(at: last) {
            
            result.minimum = firstItem.frame.minY
            result.maximum = lastItem.frame.maxY
            
            
            result.minimum -= headerReferenceSize.height
            result.maximum -= headerReferenceSize.height
            
            
            result.minimum -= sectionInset.top
            result.maximum += (sectionInset.top + sectionInset.bottom)
        }
        
        
        return result
    }
}

class MaxCellSpacingLayout: UICollectionViewFlowLayout {
    
    
    public var maximumInteritemSpacing: CGFloat = 0.0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        if attributes?.count == 0 {
            return attributes
        }
        
        let firstCellOriginX = attributes?.first?.frame.origin.x
        
        if let count = attributes?.count {
            
            for i in 1..<count {
                let currentLayoutAttributes = attributes![i]
                let previousLayoutAttributes = attributes![i-1]
                
                if currentLayoutAttributes.frame.origin.x == firstCellOriginX {
                    continue
                }
                
                let previousOriginMaxX = previousLayoutAttributes.frame.maxX
                if currentLayoutAttributes.frame.origin.x - previousOriginMaxX > maximumInteritemSpacing {
                    var frame = currentLayoutAttributes.frame
                    frame.origin.x = previousOriginMaxX + maximumInteritemSpacing
                    currentLayoutAttributes.frame = frame
                }
            }
            
        }
        
        return attributes
        
    }
    
}


extension UICollectionView {
    
    public class func initializeMethod(){
        let originalSelector = #selector(UICollectionView.reloadData)
        let swizzledSelector = #selector(UICollectionView.mx_reloadData)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func mx_reloadData() {
        DispatchQueue.main.async {
            self.mx_reloadData()
        }
    }
}

extension UITableView {
    
    public class func initializeMethod(){
        let originalSelector = #selector(UITableView.reloadData)
        let swizzledSelector = #selector(UITableView.mx_reloadData)

        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        
        let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    @objc func mx_reloadData() {
        DispatchQueue.main.async {
            self.mx_reloadData()
        }
    }
}
