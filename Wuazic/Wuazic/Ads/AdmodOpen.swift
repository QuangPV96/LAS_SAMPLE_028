import UIKit
import GoogleMobileAds
import AppTrackingTransparency

class AdmodOpen: NSObject, GADFullScreenContentDelegate {
    
    var appOpenAd: GADAppOpenAd?
    var loadTime: Date?
    static let shared = AdmodOpen()
    
    override init() {
    }
    
    // private
    private func wasLoadTimeLessThanNHoursAgo(_ hours: Int) -> Bool {
        if self.loadTime == nil {
            return true
        }
        
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTime!)
        let secondsPerHour: TimeInterval = 3600.0
        let intervalInHours: TimeInterval = timeIntervalBetweenNowAndLoadTime / secondsPerHour
        return Int(intervalInHours) < hours
    }
    
    
    func loadAdmobOpen() {
        requestAppOpenAd()
    }
    
    // public
    func requestAppOpenAd() {
        self.appOpenAd = nil;
        GADAppOpenAd.load(withAdUnitID: DataCommonModel.shared.admob_appopen, request: GADRequest()) { (ad, error) in
            if ad != nil {
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
            }
        }
    }
    
    func tryToPresentAd() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                DispatchQueue.main.async {
                    if self.appOpenAd != nil {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                        guard let window = windowScene.windows.first else { return }
                        let rootController = window.rootViewController
                        self.appOpenAd?.present(fromRootViewController: rootController!)
                    } else {
                        self.loadAdmobOpen()
                    }
                }
            })
        } else {
            if self.appOpenAd != nil {
                if #available(iOS 13.0, *) {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                    guard let window = windowScene.windows.first else { return }
                    let rootController = window.rootViewController
                    self.appOpenAd?.present(fromRootViewController: rootController!)
                } else {
                    guard let appDelegate = UIApplication.shared.delegate else { return }
                    guard let window = appDelegate.window else { return }
                    let rootController = window!.rootViewController
                    self.appOpenAd?.present(fromRootViewController: rootController!)
                }
            } else {
                loadAdmobOpen()
            }
        }
    }
    
    // GADFullScreenContentDelegate
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        loadAdmobOpen()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadAdmobOpen()
    }
}
