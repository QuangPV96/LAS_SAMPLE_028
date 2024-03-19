//
//  UIFontExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 08/04/2023.
//

import UIKit

extension UIFont {
    class func gilroy(of fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "Jost-Regular", size: fontSize)
    }
    
    class func gilroyMedium(of fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "Jost-Medium", size: fontSize)
    }
    
    class func gilroySemiBold(of fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "Jost-SemiBold", size: fontSize)
    }
    
    class func gilroyBold(of fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "Jost-Bold", size: fontSize)
    }
    
    class func gilroyXBold(of fontSize: CGFloat) -> UIFont? {
        return UIFont(name: "Jost-Bold", size: fontSize)
    }
}
