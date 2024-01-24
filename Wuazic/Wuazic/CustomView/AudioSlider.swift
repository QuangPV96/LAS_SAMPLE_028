import UIKit
class AudioSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 4
    
    @IBInspectable var audioThumbRadius: CGFloat = 16
    private lazy var audioThumbView: UIView = {
        let audioThumb = UIView()
        audioThumb.backgroundColor = UIColor(hex: 0xC6FCAA)
        audioThumb.layer.borderWidth = 0.4
        audioThumb.layer.borderColor = UIColor(hex: 0xC6FCAA).cgColor
        return audioThumb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = audioThumbImage(radius: audioThumbRadius)
        setThumbImage(thumb, for: .normal)
        setThumbImage(thumb, for: .highlighted)
    }
    
    private func audioThumbImage(radius: CGFloat) -> UIImage {
        audioThumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        audioThumbView.layer.cornerRadius = radius / 2

        let renderer = UIGraphicsImageRenderer(bounds: audioThumbView.bounds)
        return renderer.image { rendererContext in
            audioThumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
}
