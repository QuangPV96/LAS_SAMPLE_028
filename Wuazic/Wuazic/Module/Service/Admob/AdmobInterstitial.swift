//
//  AdmobInterstitial.swift
//  SwiftyAds
//
//  Created by MinhNH on 26/04/2023.
//

import UIKit
import GoogleMobileAds

class AdmobInterstitial: BaseInterstitial {
    
    // MARK: - properties
    private var _interstitial: GADInterstitialAd?
    private var _closeHandler: (() -> Void)?
    
    // MARK: - initial
    override init() {
        super.init()
    }
    
    // MARK: - override from supper
    override var canShowAds: Bool {
        if DataCommonModel.shared.admob_inter.isEmpty {
            LogService.shared.show("Admob: Interstitial ID is empty")
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.admob, .interstitial) {
            LogService.shared.show("Admob: Not available interstitial ads type")
            return false
        }
        
        return true
    }
    
    override var isReady: Bool {
        return _interstitial != nil
    }
    
    override func preloadAd(completion: @escaping (Bool) -> Void) {
        self._interstitial = nil
        
        guard canShowAds else {
            completion(false)
            return
        }
        
        let id = DataCommonModel.shared.admob_inter
        GADInterstitialAd.load(withAdUnitID: id, request: GADRequest()) { ad, error in
            if ad != nil {
                self._interstitial = ad
                self._interstitial?.fullScreenContentDelegate = self
                completion(true)
            }
            else {
                self._interstitial = nil
                if error != nil {
                    LogService.shared.show(error!.localizedDescription)
                }
                completion(false)
            }
        }
    }
    
    override func tryToPresent(with closeHandler: @escaping () -> Void) {
        self._closeHandler = nil
        
        guard isReady else {
            closeHandler()
            return
        }
        
        guard let rootController = UIWindow.keyWindow?.topMost else {
            closeHandler()
            return
        }
        
        if let presented = rootController.presentedViewController {
            if presented != UIWindow.keyWindow?.mainTabbar?.playerMain {
                LogService.shared.show("Admob present: Top most is GADFullScreenAdViewController")
            }
            else {
                self._closeHandler = closeHandler
                self._interstitial?.present(fromRootViewController: presented)
            }
        }
        else {
            self._closeHandler = closeHandler
            self._interstitial?.present(fromRootViewController: rootController)
        }
    }
}

extension AdmobInterstitial: GADFullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if let handler = self._closeHandler {
            handler()
            self._closeHandler = nil
        }
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        LogService.shared.show(error.localizedDescription)
        if let handler = self._closeHandler {
            handler()
            self._closeHandler = nil
        }
    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
}
