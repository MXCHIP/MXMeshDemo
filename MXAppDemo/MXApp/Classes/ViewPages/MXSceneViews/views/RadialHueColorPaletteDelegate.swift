


import FlexColorPicker
import CoreGraphics

class RadialHueColorPaletteDelegate: ColorPaletteDelegate {

    private(set) var diameter: CGFloat = 0
    private(set) var radius: CGFloat = 0
    private(set) var midX: CGFloat = 0
    private(set) var midY: CGFloat = 0
    private(set) var ceiledDiameter: Int = 0
    
    var radialHuePaletteStripWidth: CGFloat = 40

    var size: CGSize = .zero {
        didSet {
            let diameter = min(size.width, size.height)
            self.diameter = diameter
            self.radius = diameter / 2
            self.midX = diameter / 2 + min(0, (size.width - diameter) / 2)
            self.midY = diameter / 2 + min(0, (size.height - diameter) / 2)
            self.ceiledDiameter = Int(ceil(diameter))
            self.radialHuePaletteStripWidth = self.radius*0.4
        }
    }

    var indicatorDistance: CGFloat {
        return radius - radialHuePaletteStripWidth / 2
    }

    private func hue(at point: CGPoint) -> CGFloat {
        let dy = (point.y - midY) / radius
        let dx = (point.x - midX) / radius
        let distance = sqrt(dx * dx + dy * dy)
        if distance <= 0 {
            return 0
        }
        let hue = acos(dx / distance) / CGFloat.pi / 2
        return dy < 0 ? 1 - hue : hue
    }

    func modifiedColor(from color: HSBColor, with point: CGPoint) -> HSBColor {
        return color.withHue(hue(at: point))
    }

    func foregroundImage() -> UIImage {
        var imageData = [UInt8](repeating: 255, count: (4 * ceiledDiameter * ceiledDiameter))
        for i in 0 ..< ceiledDiameter{
            for j in 0 ..< ceiledDiameter {
                let index = 4 * (i * ceiledDiameter + j)
                let hue = self.hue(at: CGPoint(x: j, y: i)) 
                let (r, g, b) = rgbFrom(hue: hue, saturation: 1, brightness: 1)
                imageData[index] = colorComponentToUInt8(r)
                imageData[index + 1] = colorComponentToUInt8(g)
                imageData[index + 2] = colorComponentToUInt8(b)
                imageData[index + 3] = 255
            }
        }

        guard let image = UIImage(rgbaBytes: imageData, width: ceiledDiameter, height: ceiledDiameter) else {
            return UIImage()
        }

        
        let imageRect = CGRect(x: 0,y: 0, width: diameter, height: diameter)
        let holeRect = CGRect(x: radialHuePaletteStripWidth, y: radialHuePaletteStripWidth, width: diameter - 2 * radialHuePaletteStripWidth, height: diameter - 2 * radialHuePaletteStripWidth)
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(UIBezierPath(ovalIn: imageRect).cgPath)
        context?.addPath(UIBezierPath(ovalIn: holeRect).cgPath)
        context?.clip(using: .evenOdd)
        image.draw(in: imageRect)
        defer {
            UIGraphicsEndImageContext()
        }
        if let clippedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return clippedImage
        }
        return UIImage()
    }

    func backgroundImage() -> UIImage? {
        return nil
    }

    func closestValidPoint(to point: CGPoint) -> CGPoint {
        let distance = point.distanceTo(x: midX, y: midY)
        let x = midX + indicatorDistance * ((point.x - midX) / distance)
        let y = midY + indicatorDistance * ((point.y - midY) / distance)
        return CGPoint(x: x, y: y)
    }

    func positionAndAlpha(for color: HSBColor) -> (position: CGPoint, foregroundImageAlpha: CGFloat) {
        let (hue, _, _) = color.asTupleNoAlpha()
        let x = radius + radius * cos(hue * 2 * CGFloat.pi)
        let y = radius + radius * sin(hue * 2 * CGFloat.pi)
        return (closestValidPoint(to: CGPoint(x: x, y: y)), 1)
    }

    func supportedContentMode(for contentMode: UIView.ContentMode) -> UIView.ContentMode {
        switch contentMode {
        case .redraw, .scaleToFill, .scaleAspectFill: return .scaleAspectFit
        default: return contentMode
        }
    }
}

extension CGPoint {
    func distanceTo(x: CGFloat, y: CGFloat) -> CGFloat {
        let dx = self.x - x
        let dy = self.y - y
        return sqrt(dx * dx + dy * dy)
    }

    func distance(to point: CGPoint) -> CGFloat {
        return distanceTo(x: point.x, y: point.y)
    }
}
