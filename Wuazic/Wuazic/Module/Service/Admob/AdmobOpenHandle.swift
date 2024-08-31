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
            return false
        }
        
        if DataCommonModel.shared.admob_appopen.isEmpty {
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.admob, .open) {
            return false
        }
        
        return true
    }
    
    var isReady: Bool {
        return validateLoadTime()
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
                
                self._openAd = ad
                self._openAd?.fullScreenContentDelegate = self
                self._loadTime = Date()
                completion?(true)
            }
            else if error != nil {
                self._openAd = nil
                completion?(false)
            }
        }
    }
    
    @objc public func tryToPresent(completion: ((_ success: Bool) -> Void)?) {
        let loadView = PALoadingView()
        loadView.setMessage("Loading ads...")
        loadView.show()
        self.preloadAd { success in
            loadView.dismiss()
            if success {
                guard let window = UIWindow.keyWindow,
                      let rootController = window.topMost else {
                    completion?(false)
                    return
                }
                
                if let presented = rootController.presentedViewController {
                    self._openAd?.present(fromRootViewController: presented)
                    completion?(true)
                    return
                }
                
                self._openAd?.present(fromRootViewController: rootController)
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
}

extension AdmobOpenHandle: GADFullScreenContentDelegate {
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {

    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
    }
}
