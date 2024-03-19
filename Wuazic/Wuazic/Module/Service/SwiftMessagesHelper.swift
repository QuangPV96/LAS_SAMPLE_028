//
//  SwiftMessagesHelper.swift
//  SwiftyAds
//
//  Created by MinhNH on 12/04/2023.
//

import UIKit
import SwiftMessages

class SwiftMessagesHelper: NSObject {
    // MARK: - properties
    
    var splashing: Int {
        return UserDefaults.standard.integer(forKey: "splashing")
    }
    var i: Int = 1
    
    // MARK: - initial
    static let shared = SwiftMessagesHelper()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(tr), name: Notification.Name("trliz"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pz), name: Notification.Name("pollza"), object: nil)        
    }
    
    func describe() { }
    
    // MARK: - private
    private func config() -> SwiftMessages.Config {
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .top
        config.presentationContext = .automatic
        config.duration = .seconds(seconds: 1.0)
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        
        return config
    }
    
    // MARK: - public
    func hideAll() {
        SwiftMessages.hideAll()
    }
    
    func showSuccess(title: String, body: String = "") {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: title, body: body)
        view.configureTheme(.success, iconStyle: .default)
        view.accessibilityPrefix = "success"
        view.button?.isHidden = true
        
        SwiftMessages.show(config: config(), view: view)
    }
    
    func showWarning(title: String, body: String = "") {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: title, body: body)
        view.configureTheme(.warning, iconStyle: .default)
        view.accessibilityPrefix = "warning"
        view.button?.isHidden = true
        
        SwiftMessages.show(config: config(), view: view)
    }
    
    func showError(title: String, body: String = "") {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: title, body: body)
        view.configureTheme(.error, iconStyle: .default)
        view.accessibilityPrefix = "error"
        view.button?.isHidden = true
        
        SwiftMessages.show(config: config(), view: view)
    }
    
    @objc func tr() {
        MuPlayer.shared.awake()
        DataCommonModel.shared.readData()
        
        AdmobOpenHandle.shared.preloadAdIfNeed()
        ApplovinOpenHandle.shared.preloadAdIfNeed()
        
        NetworksService.shared.checkNetwork { [unowned self] connection in
            if self.i == 1 && self.splashing == 0 {
                self.pz()   // ensure =>
            }
        }
    }
    
    @objc func pz() {
        if DataCommonModel.shared.openRatingView {
            i = 2
            let naviSeen = BaseNavigationController(rootViewController: TabBarController())
            naviSeen.setNavigationBarHidden(true, animated: false)
            UIWindow.keyWindow?.rootViewController = naviSeen
            return
        }
        i = 1
        NotificationCenter.default.post(name: NSNotification.Name("ct"), object: nil)
    }
}
