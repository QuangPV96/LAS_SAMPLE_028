//
//  AdmobOpenHandle.swift
//  SwiftyAds
//
//  Created by MinhNH on 26/04/2023.
//

import UIKit
import GoogleMobileAds

public class AdmobOpenHandle: NSObject {
    
    // MARK: - properties
    private var _openAd: GADAppOpenAd?
    private var _loadTime: Date?
    
    // MARK: - initial
    @objc public static let shared = AdmobOpenHandle()
    
    override init() {
        super.init()
    }
    
    // MARK: private
    private func validateLoadTime() -> Bool {
        guard let loadTime = self._loadTime else { return true}
        
        let now = Date()
        let intervals = now.timeIntervalSince(loadTime)
        return intervals < 4 * 60 * 60
    }
    
    // MARK: -
    var canShowAds: Bool {
        if !AdmobHandle.shared.isReady {
            LogService.shared.show("Admob is not ready yet")
            return false
        }
        
        if DataCommonModel.shared.admob_appopen.isEmpty {
            LogService.shared.show("Admob: App open ID is empty")
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.admob, .open) {
            LogService.shared.show("Admob: Not available App open ads type")
            return false
        }
        
        return true
    }
    
    var isReady: Bool {
        return _openAd != nil && validateLoadTime()
    }
    
    // MARK: - public
    public func preloadAd(completion: ((_ success: Bool) -> Void)?) {
        self._openAd = nil
        self._loadTime = nil
        
        guard canShowAds else {
            completion?(false)
            return
        }
        
        //
        let id = DataCommonModel.shared.admob_appopen
        
        GADAppOpenAd.load(withAdUnitID: id, request: GADRequest()) { ad, error in
            if ad != nil {
                LogService.shared.show("Admob: App open has loaded")
                
                self._openAd = ad
                self._openAd?.fullScreenContentDelegate = self
                self._loadTime = Date()
                completion?(true)
            }
            else if error != nil {
                self._openAd = nil
                LogService.shared.show(error!.localizedDescription)
                completion?(false)
            }
        }
    }
    
    func preloadAdIfNeed() {
        if _openAd == nil {
            self.preloadAd(completion: nil)
        }
    }
    
    @objc public func tryToPresent() -> Bool {
        guard isReady else {
            if _openAd == nil {
                self.awake()
            }
            return false
        }
        
        guard let window = UIWindow.keyWindow,
              let rootController = window.topMost else { return false }
        
        if let presented = rootController.presentedViewController {
            if presented != UIWindow.keyWindow?.mainTabbar?.playerMain {
                LogService.shared.show("Admob present: Top most is GADFullScreenAdViewController")
                return false
            }
            else {
                _openAd?.present(fromRootViewController: presented)
                return true
            }
        }
        
        _openAd?.present(fromRootViewController: rootController)
        
        return true
    }
    
    @objc public func awake() {
        self.preloadAd(completion: nil)
    }
}

extension AdmobOpenHandle: GADFullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.preloadAd(completion: nil)
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        LogService.shared.show(error.localizedDescription)
    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
}
