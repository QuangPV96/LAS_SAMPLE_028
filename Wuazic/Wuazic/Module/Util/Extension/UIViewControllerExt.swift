//
//  UIViewControllerExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UIKit

extension UIStoryboard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
}

extension UIViewController {
    static func load<T>() -> T {
        let identifier = String(describing: T.self)
        return UIStoryboard.main.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    func add(_ child: UIViewController, frame: CGRect? = nil) {
            addChild(child)

            if let frame = frame {
                child.view.frame = frame
            }

            view.addSubview(child.view)
            child.didMove(toParent: self)
        }

        func remove() {
            willMove(toParent: nil)
            view.removeFromSuperview()
            removeFromParent()
        }
}
