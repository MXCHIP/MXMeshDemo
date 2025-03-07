
import Foundation

extension UIView {

    
    
    
    
    
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    
    
    func drawDottedLine(_ rect: CGRect, _ radius: CGFloat, _ color: UIColor) {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        layer.position = CGPoint(x: rect.midX, y: rect.midY)
        layer.path = UIBezierPath(rect: layer.bounds).cgPath
        layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: radius).cgPath
        layer.lineWidth = 1/UIScreen.main.scale
        
        layer.lineDashPattern = [NSNumber(value: 5), NSNumber(value: 5)]
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = color.cgColor
        
        self.layer.addSublayer(layer)
    }
}

enum RoundType {
    case top
    case none
    case bottom
    case both
}

extension UIView {

    func round(with type: RoundType, radius: CGFloat = 2.0) {
        var corners: UIRectCorner

        switch type {
        case .top:
            corners = [.topLeft, .topRight]
        case .none:
            corners = []
        case .bottom:
            corners = [.bottomLeft, .bottomRight]
        case .both:
            corners = [.allCorners]
        }

        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    func round(with type: RoundType, rect: CGRect, radius: CGFloat = 2.0) {
        var corners: UIRectCorner

        switch type {
        case .top:
            corners = [.topLeft, .topRight]
        case .none:
            corners = []
        case .bottom:
            corners = [.bottomLeft, .bottomRight]
        case .both:
            corners = [.allCorners]
        }

        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    func round(with corners: UIRectCorner, rect: CGRect, radius: CGFloat = 2.0) {
        DispatchQueue.main.async {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
    
    
    func removeRound() -> Void {
        self.layer.mask = nil
    }

}

extension UIView {
    func getColor(at point: CGPoint) -> UIColor{
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        context.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context)
        let color = UIColor(red:   CGFloat(pixel[3])/255.0,
                            green: CGFloat(pixel[2])/255.0,
                            blue:  CGFloat(pixel[1])/255.0,
                            alpha: CGFloat(pixel[0])/255.0)
        pixel.deallocate()
        return color
    }
}
