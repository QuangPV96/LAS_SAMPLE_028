import UIKit
import GoogleMobileAds

class AdmobNative: NSObject {
    
    // MARK: - properties
    private var _numberOfAds: Int = 0
    private (set) var _nativeAds: [GADNativeAd] = []
    private var _adLoader: GADAdLoader?
    
    fileprivate var _nativeDidReceive: ((_ natives: [GADNativeAd]) -> Void)!
    fileprivate var _nativeDidFail: ((_ error: Error?) -> Void)!
    
    // MARK: - initial
    init(numberOfAds: Int,
         nativeDidReceive: @escaping ((_ natives: [GADNativeAd]) -> Void),
         nativeDidFail: @escaping ((_ error: Error?) -> Void))
    {
        self._numberOfAds = numberOfAds
        self._nativeDidReceive = nativeDidReceive
        self._nativeDidFail = nativeDidFail
        self._nativeAds.removeAll()
    }
    
    // MARK: -
    var canShowAds: Bool {
        if DataCommonModel.shared.admob_small_native.isEmpty {
            LogService.shared.show("Admob: Native ID is empty")
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.admob, .native) {
            LogService.shared.show("Admob: Not available native ads type")
            return false
        }
        
        if _adLoader != nil {
            LogService.shared.show("Admob: AdLoader has loaded")
            return false
        }
        
        if _numberOfAds <= 0 {
            LogService.shared.show("Admob: Number of ads must > 0")
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
        
        let muiltiOption = GADMultipleAdsAdLoaderOptions()
        muiltiOption.numberOfAds = _numberOfAds
        
        let id = DataCommonModel.shared.admob_small_native
        _adLoader = GADAdLoader(adUnitID: id, rootViewController: controller, adTypes: [.native], options: [muiltiOption])
        _adLoader?.delegate = self
        _adLoader?.load(GADRequest())
    }
}

extension AdmobNative: GADNativeAdLoaderDelegate {
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        _nativeDidReceive(_nativeAds)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        _nativeAds.append(nativeAd)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        LogService.shared.show(error.localizedDescription)
        _nativeDidFail(error)
    }
}
