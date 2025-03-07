
import UIKit

extension MXCollectionViewRoundFlowLayout{
    
    
    
    func groupLayoutAttributesForElementsByYLineWithLayoutAttributesAttrs(_ layoutAttributesAttrs:Array<UICollectionViewLayoutAttributes>) -> Array<Array<UICollectionViewLayoutAttributes>> {
        
        var allDict = Dictionary<CGFloat,NSMutableArray>();
        
        for (_,attr) in layoutAttributesAttrs.enumerated() {
            
            let dictArr = allDict[attr.frame.midY]
            if dictArr != nil {
                dictArr?.add(attr.copy())
            }else{
                let arr = NSMutableArray.init(object: attr.copy());
                allDict[attr.frame.midY] = arr
            }
        }
        return (allDict as NSDictionary).allValues as! Array<Array<UICollectionViewLayoutAttributes>>;
    }
    
    
    
    func groupLayoutAttributesForElementsByXLineWithLayoutAttributesAttrs(_ layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>) -> Array<Array<UICollectionViewLayoutAttributes>> {
        
        var allDict = Dictionary<CGFloat,NSMutableArray>();
        for (_,attr) in layoutAttributesAttrs.enumerated() {
            let dictArr = allDict[attr.frame.origin.x]
            if dictArr != nil {
                dictArr?.add(attr.copy())
            }else{
                let arr = NSMutableArray.init(object: attr.copy());
                allDict[attr.frame.origin.x] = arr
            }
        }
        return (allDict as NSDictionary).allValues as! Array<Array<UICollectionViewLayoutAttributes>>;
    }
    
    func evaluatedAllCellSettingFrameWithLayoutAttributesAttrs(_ layoutAttributesAttrs:Array<Array<UICollectionViewLayoutAttributes>> ,  toChangeAttributesAttrsList:inout Array<UICollectionViewLayoutAttributes> ,cellAlignmentType alignmentType : MXCollectionViewRoundFlowLayoutSwiftAlignmentType) -> Array<UICollectionViewLayoutAttributes> {

        toChangeAttributesAttrsList.removeAll()
        for calculateAttributesAttrsArr in layoutAttributesAttrs {
            switch alignmentType {
            case .Left:
                self.evaluatedCellSettingFrameByLeftWithWithMXCollectionLayout(self, layoutAttributesAttrs: calculateAttributesAttrsArr);
                break
            case .Center:
                self.evaluatedCellSettingFrameByCenterWithWithMXCollectionLayout(self,layoutAttributesAttrs:calculateAttributesAttrsArr);
                break;
            case .Right:
                var reversedArray = Array.init(calculateAttributesAttrsArr);
                reversedArray.reverse();
                self.evaluatedCellSettingFrameByRightWithWithMXCollectionLayout(self, layoutAttributesAttrs: reversedArray);
                break;
            case .RightAndStartR:
                self.evaluatedCellSettingFrameByRightWithWithMXCollectionLayout(self, layoutAttributesAttrs: calculateAttributesAttrsArr);
                break;
            default:
                break;
            }
            toChangeAttributesAttrsList += calculateAttributesAttrsArr;
        }
        return toChangeAttributesAttrsList;
    }
}

extension MXCollectionViewRoundFlowLayout{
    
    
    
    
    
    func evaluatedCellSettingFrameByLeftWithWithMXCollectionLayout(_ layout:MXCollectionViewRoundFlowLayout, layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>){
        
        var pAttr:UICollectionViewLayoutAttributes? = nil;
        for attr in layoutAttributesAttrs {
            if attr.representedElementKind != nil {
                
                continue;
            }
            
            var frame = attr.frame;
            if layout.scrollDirection == .vertical {
                
                if pAttr != nil {
                    frame.origin.x = pAttr!.frame.origin.x + pAttr!.frame.size.width + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.x = MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).left;
                }
            }else{
                
                if pAttr != nil {
                    frame.origin.y = pAttr!.frame.origin.y + pAttr!.frame.size.height + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.y = MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).top;
                }
            }
            attr.frame = frame;
            pAttr = attr;
        }
    }
}

extension MXCollectionViewRoundFlowLayout{
    func evaluatedCellSettingFrameByCenterWithWithMXCollectionLayout(_ layout:MXCollectionViewRoundFlowLayout, layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>){
        
        var pAttr : UICollectionViewLayoutAttributes? = nil;
        
        var useWidth : CGFloat = 0.0;
        let theSection = layoutAttributesAttrs.first!.indexPath.section;
        for attr in layoutAttributesAttrs{
            useWidth += attr.bounds.size.width;
        }
        
        let firstLeft = (layout.collectionView!.bounds.size.width - useWidth - (MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: theSection) * CGFloat(layoutAttributesAttrs.count)))/2.0;
        
        for attr in layoutAttributesAttrs{
            if attr.representedElementKind != nil {
                
                continue;
            }
            
            var frame = attr.frame;
            if layout.scrollDirection == .vertical {
                
                if pAttr != nil {
                    frame.origin.x = pAttr!.frame.origin.x + pAttr!.frame.size.width + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.x = firstLeft;
                }
            }else{
                
                if pAttr != nil {
                    frame.origin.y = pAttr!.frame.origin.y + pAttr!.frame.size.height + MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section);
                }else{
                    frame.origin.y = MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).top;
                }
            }
            attr.frame = frame;
            pAttr = attr;
        }
    }
}


extension MXCollectionViewRoundFlowLayout{
    
    
    
    
    
    func evaluatedCellSettingFrameByRightWithWithMXCollectionLayout(_ layout:MXCollectionViewRoundFlowLayout, layoutAttributesAttrs : Array<UICollectionViewLayoutAttributes>){
        
        var pAttr:UICollectionViewLayoutAttributes? = nil;
        for attr in layoutAttributesAttrs {
            if attr.representedElementKind != nil {
                
                continue;
            }
            
            var frame = attr.frame;
            if layout.scrollDirection == .vertical {
                
                if pAttr != nil {
                    frame.origin.x = pAttr!.frame.origin.x - MXCollectionViewFlowLayoutUtils.evaluatedMinimumInteritemSpacingForSectionWithCollectionLayout(layout, atIndex: attr.indexPath.section) - frame.size.width;
                }else{
                    frame.origin.x = layout.collectionView!.bounds.size.width -  MXCollectionViewFlowLayoutUtils.evaluatedSectionInsetForItemWithCollectionLayout(layout, atIndex: attr.indexPath.section).right - frame.size.width;
                }
            }else{
                
            }
            attr.frame = frame;
            pAttr = attr;
        }
    }
}
