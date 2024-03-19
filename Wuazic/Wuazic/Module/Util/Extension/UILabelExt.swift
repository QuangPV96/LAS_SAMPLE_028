//
//  UILabelExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit

extension UILabel {
    func addTextOutline(usingColor outlineColor: UIColor, outlineWidth: CGFloat) {
        class OutlinedText: UILabel {
            var outlineWidth: CGFloat = 0
            var outlineColor: UIColor = .clear
            
            override public func drawText(in rect: CGRect) {
                let shadowOffset = self.shadowOffset
                let textColor = self.textColor
                
                let c = UIGraphicsGetCurrentContext()
                c?.setLineWidth(outlineWidth)
                c?.setLineJoin(.round)
                c?.setTextDrawingMode(.stroke)
                self.textAlignment = .center
                self.textColor = outlineColor
                super.drawText(in:rect)
                
                c?.setTextDrawingMode(.fill)
                self.textColor = textColor
                self.shadowOffset = CGSize(width: 0, height: 0)
                super.drawText(in:rect)
                
                self.shadowOffset = shadowOffset
            }
        }
        
        let textOutline = OutlinedText()
        let outlineTag = 9999
        
        if let prevTextOutline = viewWithTag(outlineTag) {
            prevTextOutline.removeFromSuperview()
        }
        
        textOutline.outlineColor = outlineColor
        textOutline.outlineWidth = outlineWidth
        textOutline.textColor = textColor
        textOutline.font = font
        textOutline.text = text
        textOutline.tag = outlineTag
        
        sizeToFit()
        addSubview(textOutline)
        textOutline.frame = CGRect(x: -(outlineWidth / 2), y: -(outlineWidth / 2),
                                   width: bounds.width + outlineWidth,
                                   height: bounds.height + outlineWidth)
    }
}
