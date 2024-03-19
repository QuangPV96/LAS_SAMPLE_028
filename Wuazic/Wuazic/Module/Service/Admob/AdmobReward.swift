//
//  AdmobReward.swift
//  SwiftyAds
//
//  Created by MinhNH on 26/04/2023.
//

import UIKit
import GoogleMobileAds

class AdmobReward: NSObject {
    
    // MARK: - properties
    private var _rewardedAd: GADRewardedAd?
    
    // MARK: - initial
    override init() {
        super.init()
    }
    
    // MARK: private
    
    // MARK: -
    var canShowAds: Bool {
        if DataCommonModel.shared.admob_reward.isEmpty {
            LogService.shared.show("Admob: Reward ID is empty")
            return false
        }
        
        //        if !DataCommonModel.shared.isAvailable(.admob, .reward) {
        //            LogService.shared.show("Admob: Not available Reward ads type")
        //            return false
        //        }
        
        return true
    }
    
    var isReady: Bool {
        return _rewardedAd != nil
    }
    
    // MARK: - public
    func preloadAd(completion: @escaping (_ success: Bool) -> Void) {
        self._rewardedAd = nil
        
        guard canShowAds else {
            completion(false)
            return
        }
        
        let id = DataCommonModel.shared.admob_reward
        GADRewardedAd.load(withAdUnitID: id, request: GADRequest()) { ad, error in
            if ad != nil {
                self._rewardedAd = ad
                self._rewardedAd?.fullScreenContentDelegate = self
                completion(true)
            }
            else if error != nil {
                self._rewardedAd = nil
                LogService.shared.show(error!.localizedDescription)
                completion(false)
            }
        }
    }
    
    func tryToPresentDidEarnReward(with handler: @escaping () -> Void) {
        guard isReady else { return }
        
        guard let rootController = UIWindow.keyWindow?.topMost else { return }
        
        if let presented = rootController.presentedViewController {
            if presented != UIWindow.keyWindow?.mainTabbar?.playerMain {
                LogService.shared.show("Admob present: Top most is GADFullScreenAdViewController")
            }
            else {
                _rewardedAd?.present(fromRootViewController: presented, userDidEarnRewardHandler: handler)
            }
        }
        else {
            _rewardedAd?.present(fromRootViewController: rootController, userDidEarnRewardHandler: handler)
        }
    }
}

extension AdmobReward: GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        LogService.shared.show(error.localizedDescription)
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
}
