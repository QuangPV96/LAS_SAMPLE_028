//
//  BaseNavigationController.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit

class BaseNavigationController: UINavigationController {

    // MARK: - property
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - private
    // MARK: - public
    // MARK: - event
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let fromVC = self.topViewController
        let toVC = viewController
        let action = "push-navigation"
        
        super.pushViewController(viewController, animated: animated)
        var from = ""
        if fromVC != nil {
            from = NSStringFromClass(fromVC!.classForCoder)
        }
        let event = ["screen-from" : from,
                     "screen-to" : NSStringFromClass(toVC.classForCoder),
                     "action" : action]
        NetworksService.shared.postEvent(event: event)
        
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let fromVC = self.topViewController
        let toVC = super.popViewController(animated: animated)
        let action = "pop-navigation"
        var from = ""
        if fromVC != nil {
            from = NSStringFromClass(fromVC!.classForCoder)
        }
        
        var to = ""
        if toVC != nil {
            to = NSStringFromClass(toVC!.classForCoder)
        }
        
        let event = ["screen-from" : from,
                     "screen-to" : to,
                     "action" : action]
        NetworksService.shared.postEvent(event: event)
        return toVC
    }
}
