import UIKit

@IBDesignable
class AudioImageView: UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var cornerCircle: Bool = false {
        didSet {
            layer.cornerRadius = cornerCircle ? self.frame.size.height / 2 : 0
            layer.masksToBounds = cornerCircle
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var tintColorImage: UIColor = UIColor.clear {
        didSet {
            if self.image != nil {
                self.image = self.image!.withRenderingMode(.alwaysTemplate)
                self.tintColor = tintColorImage
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero
    @IBInspectable var isShadow: Bool = false {
        didSet {
            if isShadow {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.16
                layer.shadowRadius = 4.0
                layer.shadowOffset = shadowOffset
                layer.masksToBounds = false
                //layer.shouldRasterize = true
            }
            setNeedsDisplay()
        }
    }
}







