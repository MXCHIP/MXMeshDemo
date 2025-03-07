
import UIKit

class MXCollectionReusableView: UICollectionReusableView {
    
    var myCacheAttr : MXCollectionViewRoundLayoutAttributes = {
        return MXCollectionViewRoundLayoutAttributes.init();
    }()
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let attr = layoutAttributes as! MXCollectionViewRoundLayoutAttributes
        myCacheAttr = attr;
        self.toChangeCollectionReusableViewRoundInfo(myCacheAttr);
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection);
        self.toChangeCollectionReusableViewRoundInfo(myCacheAttr);
    }
    
    func toChangeCollectionReusableViewRoundInfo(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        let attr = layoutAttributes as! MXCollectionViewRoundLayoutAttributes
        if (attr.myConfigModel != nil) {
            let model = attr.myConfigModel!;
            let view = self;
            
            if #available(iOS 13.0, *) {
                view.layer.backgroundColor = model.backgroundColor?.resolvedColor(with: self.traitCollection).cgColor
            } else {
                
                view.layer.backgroundColor = model.backgroundColor?.cgColor;
            };
            
            if #available(iOS 13.0, *) {
                view.layer.shadowColor = model.shadowColor?.resolvedColor(with: self.traitCollection).cgColor
            } else {
                
                view.layer.shadowColor = model.shadowColor?.cgColor;
            };
            view.layer.shadowOffset = model.shadowOffset ?? CGSize.init(width: 0, height: 0);
            view.layer.shadowOpacity = model.shadowOpacity;
            view.layer.shadowRadius = model.shadowRadius;
            view.layer.cornerRadius = model.cornerRadius;
            view.layer.borderWidth = model.borderWidth;
            
            if #available(iOS 13.0, *) {
                view.layer.borderColor = model.borderColor?.resolvedColor(with: self.traitCollection).cgColor
            } else {
                
                view.layer.borderColor = model.borderColor?.cgColor;
            };
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event?.type == UIEvent.EventType.touches {
            self.decorationViewUserDidSelectEvent();
        }
    }
    
    func decorationViewUserDidSelectEvent() {
        guard let collectionView = self.superview else {
            return;
        }
        
        if collectionView.isKind(of: UICollectionView.self) {
            let myCollectionView = collectionView as! UICollectionView;
            let delegate = myCollectionView.delegate as! MXCollectionViewDelegateRoundFlowLayout;
            if delegate.responds(to: #selector(delegate.collectionView(collectionView:didSelectDecorationViewAtIndexPath:))) {
                delegate .collectionView?(collectionView: myCollectionView, didSelectDecorationViewAtIndexPath: myCacheAttr.indexPath);
            }
        }
    }
}

class MXCollectionViewRoundLayoutAttributes: UICollectionViewLayoutAttributes {
    var borderEdgeInsets : UIEdgeInsets?
    var myConfigModel : MXCollectionViewRoundConfigModel?
}

extension MXCollectionViewRoundFlowLayout{
    public static let MXCollectionViewRoundSectionSwift: String = "com.MXCollectionViewRoundSectionSwift"
}

@objc public protocol MXCollectionViewDelegateRoundFlowLayout : UICollectionViewDelegateFlowLayout{
    
    
    
    
    
    func collectionView(_ collectionView : UICollectionView, layout collectionViewLayout : UICollectionViewLayout , configModelForSectionAtIndex section : Int ) -> MXCollectionViewRoundConfigModel;
    
    
    
    
    
    @objc optional func collectionView(_ collectionView : UICollectionView , layout collectionViewLayout:UICollectionViewLayout,borderEdgeInsertsForSectionAtIndex section : Int) -> UIEdgeInsets;
    
    
    
    
    
    
    @objc optional func collectionView(collectionView:UICollectionView ,layout:UICollectionViewLayout , isCalculateHeaderViewIndex section : NSInteger) -> Bool;
    
    
    
    
    
    
    @objc optional func collectionView(collectionView:UICollectionView , layout:UICollectionViewLayout , isCalculateFooterViewIndex section : NSInteger) -> Bool;
    
    
    
    
    
    
    @objc optional func collectionView(collectionView:UICollectionView , layout:UICollectionViewLayout , isCanCalculateWhenRowEmptyWithSection section : NSInteger) -> Bool;
    
    
    
    
    
    
    @objc optional func collectionView(collectionView:UICollectionView , didSelectDecorationViewAtIndexPath indexPath:IndexPath);
}

@objcMembers
open class MXCollectionViewRoundFlowLayout: UICollectionViewFlowLayout {
    
    
    open var collectionCellAlignmentType : MXCollectionViewRoundFlowLayoutSwiftAlignmentType = .System;

    
    open var isRoundEnabled : Bool = true;
    
    open var isCalculateHeader : Bool = false    
    open var isCalculateFooter : Bool = false    
    
    
    open var isCalculateTypeOpenIrregularitiesCell : Bool = false
    
    
    
    
    
    
    
    open var isCanCalculateWhenRowEmpty : Bool = false
    
    
    var decorationViewAttrs : [UICollectionViewLayoutAttributes] = {
        let arr = NSMutableArray.init(capacity: 0)
        return arr as! [UICollectionViewLayoutAttributes]
    }()
}

extension MXCollectionViewRoundFlowLayout{
    
    override public func prepare() {
        super.prepare()
        
        if !self.isRoundEnabled {
            
            return;
        }
        
        guard let sections = collectionView?.numberOfSections else { return };
        let delegate = collectionView?.delegate as! MXCollectionViewDelegateRoundFlowLayout
        
        
        if delegate.responds(to: #selector(delegate.collectionView(_:layout:configModelForSectionAtIndex:))) {
            
        }else{
            return;
        }
        
        
        self.register(MXCollectionReusableView.self, forDecorationViewOfKind: MXCollectionViewRoundFlowLayout.MXCollectionViewRoundSectionSwift)
        decorationViewAttrs.removeAll()
        
        for section in 0..<sections {
            let numberOfItems = collectionView?.numberOfItems(inSection: section);
            
            var firstFrame = CGRect.null;
            if numberOfItems != nil && numberOfItems! > 0  {
                let firstAttr = layoutAttributesForItem(at: IndexPath.init(row: 0, section: section))
                firstFrame = firstAttr!.frame;
            } else if delegate.responds(to: #selector(delegate.collectionView(collectionView:layout:isCanCalculateWhenRowEmptyWithSection:))) {
                
                if !delegate.collectionView!(collectionView: self.collectionView!, layout: self, isCanCalculateWhenRowEmptyWithSection: section) {
                    continue;
                }
            }else if(!isCanCalculateWhenRowEmpty) {
                
                continue;
            }
                        
            
            var isCalculateHeaderView = false;
            if delegate.responds(to: #selector(delegate.collectionView(collectionView:layout:isCalculateHeaderViewIndex:))) {
                isCalculateHeaderView = delegate.collectionView!(collectionView: self.collectionView!, layout: self, isCalculateHeaderViewIndex: section);
            }else{
                isCalculateHeaderView = self.isCalculateHeader;
            }
            
            if isCalculateHeaderView {
                
                let headerAttr = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(row: 0, section: section))
                if headerAttr != nil &&
                    (headerAttr?.frame.size.width != 0 ||
                     headerAttr?.frame.size.height != 0) {
                    firstFrame = headerAttr!.frame;
                }else{
                    var rect = firstFrame;
                    if !rect.isNull {
                        if isCalculateTypeOpenIrregularitiesCell {
                            rect = MXCollectionViewFlowLayoutUtils.calculateIrregularitiesCellByMinTopFrameWithLayout(self, section: section, numberOfItems: numberOfItems!, defaultFrame: rect);
                        }
                        
                        firstFrame = self.scrollDirection == .vertical ?
                            CGRect.init(x: rect.origin.x,
                                        y: rect.origin.y,
                                        width: collectionView!.bounds.size.width,
                                        height: rect.size.height):
                            CGRect.init(x: rect.origin.x,
                                        y: rect.origin.y,
                                        width: rect.size.width,
                                        height: collectionView!.bounds.size.height);
                    }
                }
            }else{
                
                if isCalculateTypeOpenIrregularitiesCell {
                    if !firstFrame.isNull {
                        firstFrame = MXCollectionViewFlowLayoutUtils.calculateIrregularitiesCellByMinTopFrameWithLayout(self, section: section, numberOfItems: numberOfItems!, defaultFrame: firstFrame);
                    }
                }
            }
            
            var lastFrame = CGRect.null;
            if numberOfItems != nil && numberOfItems! > 0  {
                let lastAttr = layoutAttributesForItem(at: IndexPath.init(row:(numberOfItems! - 1), section: section))
                lastFrame = lastAttr!.frame;
            }
            
            
            var isCalculateFooterView = false;
            if delegate.responds(to: #selector(delegate.collectionView(collectionView:layout:isCalculateFooterViewIndex:))) {
                isCalculateFooterView = delegate.collectionView!(collectionView: self.collectionView!, layout: self, isCalculateFooterViewIndex: section);
            }else{
                isCalculateFooterView = self.isCalculateFooter;
            }
            
            if isCalculateFooterView {
                
                let footerAttr = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath.init(row: 0, section: section))
                if footerAttr != nil &&
                    (footerAttr?.frame.size.width != 0 ||
                     footerAttr?.frame.size.height != 0) {
                    lastFrame = footerAttr!.frame;
                }else{
                    var rect = lastFrame;
                    if !rect.isNull {
                        if self.isCalculateTypeOpenIrregularitiesCell {
                            rect = MXCollectionViewFlowLayoutUtils.calculateIrregularitiesCellByMaxBottomFrameWithLayout(self, section: section, numberOfItems: numberOfItems!, defaultFrame: rect);
                        }
                        lastFrame = self.scrollDirection == .vertical ?
                            CGRect.init(x: rect.origin.x,
                                        y: rect.origin.y,
                                        width: collectionView!.bounds.size.width,
                                        height: rect.size.height):
                            CGRect.init(x: rect.origin.x,
                                        y: rect.origin.y,
                                        width: rect.size.width,
                                        height: collectionView!.bounds.size.height)
                    }
                }
            }else{
                
                if self.isCalculateTypeOpenIrregularitiesCell {
                    if !lastFrame.isNull {
                        lastFrame = MXCollectionViewFlowLayoutUtils.calculateIrregularitiesCellByMaxBottomFrameWithLayout(self, section: section, numberOfItems: numberOfItems!, defaultFrame: lastFrame);
                    }
                }
            }
            
            
            var sectionInset = self.sectionInset
            if (delegate.responds(to: #selector(delegate.collectionView(_:layout:insetForSectionAt:)))) {
                let inset = delegate.collectionView!(self.collectionView!, layout: self, insetForSectionAt: section)
                if inset != sectionInset {
                    sectionInset = inset
                }
            }
            
            var userCustomSectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
            if delegate.responds(to: #selector(delegate.collectionView(_:layout:borderEdgeInsertsForSectionAtIndex:))) {
                
                userCustomSectionInset = delegate.collectionView!(self.collectionView!, layout: self, borderEdgeInsertsForSectionAtIndex: section)
            }
            
            var sectionFrame = CGRect.null;
            if !firstFrame.isNull && !lastFrame.isNull {
                sectionFrame = firstFrame.union(lastFrame);
            }else if(!firstFrame.isNull) {
                sectionFrame = firstFrame.union(firstFrame);
            }else if(!lastFrame.isNull) {
                sectionFrame = lastFrame.union(lastFrame);
            }
                
            if sectionFrame.isNull {
                continue;
            }
            
            if !isCalculateHeaderView && !isCalculateFooterView{
                
                sectionFrame = self.calculateDefaultFrameWithSectionFrame(sectionFrame, sectionInset: sectionInset)
            }else{
                if (isCalculateHeaderView && !isCalculateFooterView) {
                    
                    let headerAttr = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(row: 0, section: section))
                    
                    if headerAttr != nil &&
                        (headerAttr?.frame.size.width != 0 || headerAttr?.frame.size.height != 0){
                        if self.scrollDirection == UICollectionView.ScrollDirection.horizontal {
                            
                            sectionFrame.size.width += sectionInset.right
                            
                            
                            if #available(iOS 11.0, *) {
                                sectionFrame.size.height = self.collectionView!.frame.size.height - self.collectionView!.adjustedContentInset.top
                            }else{
                                sectionFrame.size.height = self.collectionView!.frame.size.height - abs(self.collectionView!.contentOffset.y);
                            }
                        }else{
                            
                            sectionFrame.size.height += sectionInset.bottom;
                        }
                    }else{
                        sectionFrame = self.calculateDefaultFrameWithSectionFrame(sectionFrame, sectionInset: sectionInset)
                    }
                }else if(!isCalculateHeaderView && isCalculateFooterView){
                    
                    let footerAttr = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath.init(row: 0, section: section))
                    if footerAttr != nil &&
                        (footerAttr?.frame.size.width != 0 || footerAttr?.frame.size.height != 0) {
                        if self.scrollDirection == UICollectionView.ScrollDirection.horizontal {
                            
                            
                            sectionFrame.origin.x -= sectionInset.left;
                            sectionFrame.size.width += sectionInset.left;
                            
                            
                            if #available(iOS 11.0, *) {
                                sectionFrame.size.height = self.collectionView!.frame.size.height - self.collectionView!.adjustedContentInset.top
                            }else{
                                sectionFrame.size.height = self.collectionView!.frame.size.height - abs(self.collectionView!.contentOffset.y);
                            }
                        }else{
                            
                            
                            sectionFrame.origin.y -= sectionInset.top
                            sectionFrame.size.width = self.collectionView!.frame.size.width
                            sectionFrame.size.height += sectionInset.top
                        }
                    }else{
                        sectionFrame = self.calculateDefaultFrameWithSectionFrame(sectionFrame, sectionInset: sectionInset);
                    }
                }else{
                    
                    let headerAttr = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath.init(row: 0, section: section))
                    
                    
                    let footerAttr = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath.init(row: 0, section: section))
                    
                    if headerAttr != nil &&
                        footerAttr != nil &&
                        (headerAttr?.frame.size.width != 0 || headerAttr?.frame.size.height != 0) &&
                        (footerAttr?.frame.size.width != 0 || footerAttr?.frame.size.height != 0){
                        
                    }else{
                        sectionFrame = self.calculateDefaultFrameWithSectionFrame(sectionFrame, sectionInset: sectionInset);
                    }
                }
            }
            
            sectionFrame.origin.x += userCustomSectionInset.left;
            sectionFrame.origin.y += userCustomSectionInset.top;
            if self.scrollDirection == UICollectionView.ScrollDirection.horizontal {
                sectionFrame.size.width -= (userCustomSectionInset.left + userCustomSectionInset.right);
                sectionFrame.size.height -= (userCustomSectionInset.top + userCustomSectionInset.bottom);
            }else{
                sectionFrame.size.width -= (userCustomSectionInset.left + userCustomSectionInset.right);
                sectionFrame.size.height -= (userCustomSectionInset.top + userCustomSectionInset.bottom);
            }
            
            
            let attr = MXCollectionViewRoundLayoutAttributes.init(forDecorationViewOfKind:MXCollectionViewRoundFlowLayout.MXCollectionViewRoundSectionSwift, with: IndexPath.init(row: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            attr.borderEdgeInsets = userCustomSectionInset
            if delegate.responds(to: #selector(delegate.collectionView(_:layout:configModelForSectionAtIndex:))) {
                attr.myConfigModel = delegate.collectionView(self.collectionView!, layout: self, configModelForSectionAtIndex: section)
            }
            self.decorationViewAttrs.append(attr)
            
        }
    }
}

extension MXCollectionViewRoundFlowLayout{
    func calculateDefaultFrameWithSectionFrame(_ frame:CGRect ,sectionInset:UIEdgeInsets) -> CGRect{
        var sectionFrame = frame;
        sectionFrame.origin.x -= sectionInset.left;
        sectionFrame.origin.y -= sectionInset.top;
        if (self.scrollDirection == UICollectionView.ScrollDirection.horizontal) {
            sectionFrame.size.width += sectionInset.left + sectionInset.right;
            
            if #available(iOS 11, *) {
                sectionFrame.size.height = self.collectionView!.frame.size.height - self.collectionView!.adjustedContentInset.top;
            } else {
                sectionFrame.size.height = self.collectionView!.frame.size.height - abs(self.collectionView!.contentOffset.y);
            }
        }else{
            sectionFrame.origin.x = 0 ;
            sectionFrame.size.width = self.collectionView!.frame.size.width;
            sectionFrame.size.height += sectionInset.top + sectionInset.bottom;
        }
        return sectionFrame;
    }
}


public extension MXCollectionViewRoundFlowLayout{
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect) ?? []
        
        
        if self.collectionCellAlignmentType != .System
        && self.scrollDirection == .vertical{
            
            let formatGroudAttr = self.groupLayoutAttributesForElementsByYLineWithLayoutAttributesAttrs(attrs); 
            
            _ = self.evaluatedAllCellSettingFrameWithLayoutAttributesAttrs(formatGroudAttr, toChangeAttributesAttrsList: &attrs, cellAlignmentType: self.collectionCellAlignmentType)
        }
        
        for attr in self.decorationViewAttrs {
            attrs.append(attr);
        }
        return attrs
    }
}
