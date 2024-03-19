import UIKit
import AppLovinSDK

class ApplovinNative: NSObject {
    
    // MARK: - properties
    private (set) var _nativeAds: MAAd?
    private (set) var _nativeAdView: UIView?
    private (set) var _adLoader: MANativeAdLoader?
    
    fileprivate var _nativeDidReceive: ((_ nativeAdView: MANativeAdView, _ nativeAd: MAAd) -> Void)!
    fileprivate var _nativeDidFail: ((_ error: Error?) -> Void)!
    
    // MARK: - initial
    public init(nativeDidReceive: @escaping ((_ nativeAdView: MANativeAdView, _ nativeAd: MAAd) -> Void),
                nativeDidFail: @escaping ((_ error: Error?) -> Void))
    {
        self._nativeDidReceive = nativeDidReceive
        self._nativeDidFail = nativeDidFail
    }
    
    // MARK: -
    var canShowAds: Bool {
        if DataCommonModel.shared.applovin_small_native.isEmpty {
            LogService.shared.show("Applovin: native small ID is empty")
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.applovin, .native) {
            LogService.shared.show("Applovin: Not available native small ads type")
            return false
        }
        
        if _adLoader != nil {
            LogService.shared.show("Applovin: AdLoader has loaded")
            return false
        }
        
        return true
    }
    
    // MARK: public
    func preloadAd(controller: UIViewController) {
        guard canShowAds else {
            _nativeDidFail(nil)
            return
        }
        
        _adLoader = MANativeAdLoader(adUnitIdentifier: DataCommonModel.shared.applovin_small_native)
        _adLoader?.nativeAdDelegate = self
        _adLoader?.loadAd()
    }
}

extension ApplovinNative: MANativeAdDelegate {
    public func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        guard let adView = nativeAdView else {
            _nativeDidFail(NSError.make(code: 1003, userInfo: ["message": "Ad view is nil"]))
            return
        }
        
        // Clean up any pre-existing native ad to prevent memory leaks
        if let currentNativeAd = _nativeAds {
            _adLoader?.destroy(currentNativeAd)
        }
        
        // Save ad for cleanup
        _nativeAds = ad
        _nativeAdView = adView
        
        _nativeDidReceive(adView, ad)
    }
    
    public func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        LogService.shared.show(error.message)
        _nativeDidFail(NSError.make(code: -1, userInfo: ["message": error.message]))
    }
    
    public func didClickNativeAd(_ ad: MAAd) {
        LogService.shared.show("[Applovin] did click native ad")
    }
}
