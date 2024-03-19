//
//  IdfaService.swift
//  Anime9Main
//
//  Created by Quynh Nguyen on 10/11/2023.
//

import UIKit
import AppTrackingTransparency
import AdSupport

class IdfaService: NSObject {
    private var obse: Any?
    
    static let shared = IdfaService()
    
    func requestTracking(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            if UIApplication.shared.applicationState == .active {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    DispatchQueue.main.async { completion() }
                }
            }
            else {
                obse = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main, using: { [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    ATTrackingManager.requestTrackingAuthorization { _ in
                        DispatchQueue.main.async { completion() }
                    }
                    
                    self.obse.flatMap {
                        NotificationCenter.default.removeObserver($0)
                    }
                })
            }
        }
        else {
            completion()
        }
    }
    
    var requestedIDFA: Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus != .notDetermined
        }
        else {
            return true
        }
    }
    
    var uuid: String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
}
