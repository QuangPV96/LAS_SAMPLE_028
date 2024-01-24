

import UIKit
import AVFoundation

extension UIView {
    func topRadius(radius: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    func bottomRadius(radius: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    func leftRadius(radius: Int) {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
}
extension UIColor {
    static func setUpGradient(v: UIView, listColor: [UIColor] , isHorizontal: Bool = true) -> UIColor {
        guard let color = UIColor.gradientColor(withSize: v.bounds.size, colors: listColor, isHorizontal: isHorizontal) else { return UIColor.clear }
        return color
    }
    static func gradientColor(withSize size: CGSize, colors: [UIColor], isHorizontal: Bool = true) -> UIColor? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors.map { $0.cgColor }
        
        if isHorizontal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            if let gradientImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return UIColor(patternImage: gradientImage)
            }
        }
        UIGraphicsEndImageContext()
        
        return nil
    }
    convenience init(hex: Int, alpha: Double = 1.0) {
        self.init(red: CGFloat((hex>>16)&0xFF)/255.0, green:CGFloat((hex>>8)&0xFF)/255.0, blue: CGFloat((hex)&0xFF)/255.0, alpha:  CGFloat(255 * alpha) / 255)
    }
}
extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension AVAsset {
  func getArtwork() -> UIImage? {
    if let metaArtwork = self.metadata.first(where: {$0.commonKey == .commonKeyArtwork}), let data = metaArtwork.value as? Data {
      let image = UIImage(data: data)
      return image
    }
     
    let imageGenerator = AVAssetImageGenerator(asset: self)
    imageGenerator.appliesPreferredTrackTransform = true
     
    let durationSeconds = CMTimeGetSeconds(self.duration)
    let time = durationSeconds > 1 ? CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)) : .zero
    var actualTime: CMTime = CMTime.zero
    do {
        let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        let image = UIImage(cgImage: imageRef)
        return image
    } catch let error as NSError {
        print("\(error.description). Time: \(actualTime)")
    }
    return nil
  }
}
