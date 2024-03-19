import UIKit
import UIKit
import GoogleMobileAds

class AdmobRewardInterstitial: NSObject {
    
    // MARK: - properties
    private var _rewardedInterAd: GADRewardedInterstitialAd?
    
    // MARK: - initial
    override init() {
        super.init()
    }
    
    // MARK: private
    
    // MARK: -
    var canShowAds: Bool {
        if DataCommonModel.shared.admob_reward_interstitial.isEmpty {
            LogService.shared.show("Admob: Reward interstitial ID is empty")
            return false
        }
        
        //        if !DataCommonModel.shared.isAvailable(.admob, .reward) {
        //            LogService.shared.show("Admob: Not available Reward interstitial ads type")
        //            return false
        //        }
        
        return true
    }
    
    var isReady: Bool {
        return _rewardedInterAd != nil
    }
    
    // MARK: - public
    func preloadAd(completion: @escaping (_ success: Bool) -> Void) {
        self._rewardedInterAd = nil
        
        guard canShowAds else {
            completion(false)
            return
        }
        
        let id = DataCommonModel.shared.admob_reward_interstitial
        GADRewardedInterstitialAd.load(withAdUnitID: id, request: GADRequest()) { ad, error in
            if ad != nil {
                self._rewardedInterAd = ad
                self._rewardedInterAd?.fullScreenContentDelegate = self
                completion(true)
            }
            else if error != nil {
                self._rewardedInterAd = nil
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
                _rewardedInterAd?.present(fromRootViewController: presented, userDidEarnRewardHandler: handler)
            }
        }
        else {
            _rewardedInterAd?.present(fromRootViewController: rootController, userDidEarnRewardHandler: handler)
        }
    }
}

extension AdmobRewardInterstitial: GADFullScreenContentDelegate {
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
