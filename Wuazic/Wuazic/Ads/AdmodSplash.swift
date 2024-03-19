import UIKit
import GoogleMobileAds

class AdmodSplash: NSObject {
    fileprivate var interstitial: GADInterstitialAd?
    var actionClose: (() ->())?
    
    static let shared = AdmodSplash()
    
    override init() {
        
    }
    
    private func createAndLoadInterstitial() {
        GADInterstitialAd.load(withAdUnitID:DataCommonModel.shared.admob_inter_splash,
                               request: GADRequest(),
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                                self.interstitial?.fullScreenContentDelegate = self
                               })
    }
    
    func initialAds() {
        GADMobileAds.sharedInstance().start { (status) in
            self.loadAdmobInterstitial()
        }
    }

    func loadAdmobInterstitial() {
        interstitial = nil
        createAndLoadInterstitial()
    }
    
    func showAdmobInterstitial() -> Bool {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return false}
            guard let window = windowScene.windows.first else { return false}
            let rootController = window.rootViewController
            if interstitial != nil && rootController != nil {
                interstitial!.present(fromRootViewController: rootController!)
                return true
            }
        } else {
            // iOS12 or earlier
            guard let appDelegate = UIApplication.shared.delegate else { return false}
            guard let window = appDelegate.window else { return false}
            let rootController = window!.rootViewController
            if interstitial != nil && rootController != nil {
                interstitial!.present(fromRootViewController: rootController!)
                return true
            }
        }
        
        
        return false
    }
    
    func userClickedButton(actionClose: @escaping (() ->())) {
        self.actionClose = actionClose
        if !showAdmobInterstitial() {
            if self.actionClose != nil {
                self.actionClose!()
            }
            loadAdmobInterstitial()
            self.actionClose = nil
        }
    }
}

extension AdmodSplash: GADFullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if self.actionClose != nil {
            self.actionClose!()
        }
        loadAdmobInterstitial()
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if self.actionClose != nil {
            self.actionClose!()
            self.actionClose = nil
        }
    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
    }
}
