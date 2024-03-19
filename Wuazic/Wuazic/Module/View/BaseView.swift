//
//  BaseView.swift
//  SwiftyAds
//
//  Created by MinhNH on 24/04/2023.
//

import UIKit

class BaseView: UIView {
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
    }
    
}
