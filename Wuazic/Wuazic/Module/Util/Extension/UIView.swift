//
//  UIView.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit

extension UIView {
    var origin: CGPoint {
        return frame.origin
    }
    
    var size: CGSize {
        return frame.size
    }
    
    func layoutEdges(withPadding top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) {
        guard let sp = superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: sp.topAnchor, constant: top).isActive = true
        self.leftAnchor.constraint(equalTo: sp.leftAnchor, constant: left).isActive = true
        self.rightAnchor.constraint(equalTo: sp.rightAnchor, constant: -right).isActive = true
        self.bottomAnchor.constraint(equalTo: sp.bottomAnchor, constant: -bottom).isActive = true
    }
    
    func layoutSafeAreaEdges(withPadding top: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0) {
        guard let sp = superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: sp.safeAreaLayoutGuide.topAnchor, constant: top).isActive = true
        self.leftAnchor.constraint(equalTo: sp.safeAreaLayoutGuide.leftAnchor, constant: left).isActive = true
        self.rightAnchor.constraint(equalTo: sp.safeAreaLayoutGuide.rightAnchor, constant: -right).isActive = true
        self.bottomAnchor.constraint(equalTo: sp.safeAreaLayoutGuide.bottomAnchor, constant: -bottom).isActive = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
