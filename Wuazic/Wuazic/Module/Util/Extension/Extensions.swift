//
//  Extensions.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import Foundation
import UIKit

extension Notification.Name {
    static let willShowPlayerMini = Notification.Name("willShowPlayerMini")
    static let didHidePlayerMini = Notification.Name("didHidePlayerMini")
    static let databaseChanged = Notification.Name("databaseChanged")
    static let searchClearData = Notification.Name("searchClearData")
    static let updateState = Notification.Name("updateState")
    static let isConnected = Notification.Name("isConnected")
}

extension UIDevice {
    var isiPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

extension Double {
    func timeFormat() -> String {
        let countTimeFormat = "%02d:%02d"
        let countTimeFormatWithHour = "%02d:%02d:%02d"
        let secondsPerHour = 3600
        let secondsPerMinute = 60
        
        var tmpTime = Int(self)
        let hours = tmpTime / secondsPerHour
        tmpTime -= hours * secondsPerHour
        let minutes = tmpTime / secondsPerMinute
        tmpTime -= minutes * secondsPerMinute
        let seconds = tmpTime
        if hours <= 0 {
            return String(format: countTimeFormat, minutes, seconds)
        } else {
            return String(format: countTimeFormatWithHour, hours, minutes, seconds)
        }
    }
}

extension Array {
    mutating func shuffle() {
        if self.count > 0 {
            for i in 0..<(count - 1) {
                let j = Int(arc4random_uniform(UInt32(count - i))) + i
                self.swapAt(i, j)
            }
        }
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}

extension Dictionary {
    func jsonString() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        throw NSError.make(code: 1002, userInfo: ["message": "Data cannot be converted to .utf8 string"])
    }
    
    func toData() throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: self)
        return data
    }
}

extension UIImage {
    convenience init?(imgName name: String) {
        self.init(named: name, in: Bundle.current, compatibleWith: nil)
    }
}

extension Bundle {
    static var current: Bundle {
        class __ { }
        return Bundle(for: __.self)
    }
}

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
