
import Foundation
import UIKit

extension UIImage {
    func mx_imageByTintColor(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)
        color.set()
        UIRectFill(rect)
        self.draw(at: CGPoint.init(x: 0, y: 0), blendMode: .destinationIn, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resize() -> UIImage? {
        let max: CGFloat = 960
        
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if self.size.width > self.size.height {
            newWidth = max
            newHeight = max / self.size.width * self.size.height
        } else {
            newHeight = max
            newWidth = max / self.size.height * self.size.width
        }
        
        return self.imageWithNewSize(size: CGSize(width: newWidth, height: newHeight))
    }
    
    public func imageWithNewSize(size: CGSize) -> UIImage? {
    
        if self.size.height > size.height {
            
            let width = size.height / self.size.height * self.size.width
            
            let newImgSize = CGSize(width: width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
            
        } else {
            
            let newImgSize = CGSize(width: size.width, height: size.height)
            
            UIGraphicsBeginImageContext(newImgSize)
            
            self.draw(in: CGRect(x: 0, y: 0, width: newImgSize.width, height: newImgSize.height))
            
            let theImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            guard let newImg = theImage else { return  nil}
            
            return newImg
        }
    
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
 
            return rotatedImage ?? self
        }
 
        return self
    }
}
