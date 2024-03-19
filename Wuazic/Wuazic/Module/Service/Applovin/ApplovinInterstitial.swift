import UIKit
import AppLovinSDK

class ApplovinInterstitial: BaseInterstitial {
    
    // MARK: - properties
    private var _interstitialAd: MAInterstitialAd?
    private var _loadHandler: ((_ success: Bool) -> Void)?
    private var _closeHandler: (() -> Void)?
    
    // MARK: - initial
    public override init() {
        super.init()
    }
    
    // MARK: -
    override var canShowAds: Bool {
        if DataCommonModel.shared.applovin_inter.isEmpty {
            LogService.shared.show("Applovin: Interstitial ID is empty")
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.applovin, .interstitial) {
            LogService.shared.show("Applovin: Not available interstitial ads type")
            return false
        }
        
        return true
    }
    
    override var isReady: Bool {
        return _interstitialAd != nil && _interstitialAd!.isReady
    }
    
    // MARK: -
    override func preloadAd(completion: @escaping (_ success: Bool) -> Void) {
        self._loadHandler = nil
        self._interstitialAd = nil
        
        guard canShowAds else {
            completion(false)
            return
        }
        
        self._loadHandler = completion
        
        _interstitialAd = MAInterstitialAd(adUnitIdentifier: DataCommonModel.shared.applovin_inter)
        _interstitialAd?.delegate = self
        _interstitialAd?.revenueDelegate = self
        _interstitialAd?.load()
    }
    
    override func tryToPresent(with closeHandler: @escaping () -> Void) {
        self._closeHandler = nil
        
        guard isReady else {
            closeHandler()
            return
        }
        
        self._closeHandler = closeHandler
        self._interstitialAd?.show()
    }
    
    
}

extension ApplovinInterstitial: MAAdRevenueDelegate, MAAdViewAdDelegate {
    public func didPayRevenue(for ad: MAAd) {
        
    }
    
    public func didLoad(_ ad: MAAd) {
        if let handler = self._loadHandler {
            handler(true)
            self._loadHandler = nil
        }
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        if let handler = self._loadHandler {
            handler(false)
            self._loadHandler = nil
        }
    }
    
    public func didExpand(_ ad: MAAd) {
        
    }
    
    public func didCollapse(_ ad: MAAd) {
        
    }
    
    public func didDisplay(_ ad: MAAd) {
        
    }
    
    public func didHide(_ ad: MAAd) {
        if let handler = self._closeHandler {
            handler()
            self._closeHandler = nil
        }
    }
    
    public func didClick(_ ad: MAAd) {
        
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        LogService.shared.show(error.message)
        if let handler = self._closeHandler {
            handler()
            self._closeHandler = nil
        }
    }
}
