import UIKit

class AdsInterstitialHandle: NSObject {
    
    // MARK: - properties
    private var _admobHandle = AdmobInterstitial()
    private var _applovinHandle = ApplovinInterstitial()
    private var _index: Int = 0
    private var _loadingAd: Bool = false
    private var _service: BaseInterstitial?
    
    public var loadingAd: Bool {
        return _loadingAd
    }
    
    // MARK: - initial
    static let shared = AdsInterstitialHandle()
    
    // [IMPORTANT] only reset after did show
    func resetService() {
        self._service = nil
    }
    
    // use re-call for some ads applovin, unity hasn't loaded yet
    func preloadIfNeed() {
        if _service == nil && !_loadingAd {
            preload { }
        }
    }
    
    func preload(resetIndex: Bool = true, completion: @escaping () -> Void) {
        if resetIndex {
            self._index = 0
            self._loadingAd = true
            self._service = nil
        }
        
        let adsesActive = DataCommonModel.shared.adsAvailableFor(.interstitial)
        if _index >= adsesActive.count {
            self._loadingAd = false
            self._service = nil
            completion()
            return
        }
        
        let ads = adsesActive[_index]
        _index += 1
        
        switch ads.name {
        case .admob:
            _admobHandle.preloadAd { success in
                if success {
                    self._loadingAd = false
                    self._service = self._admobHandle
                    completion()
                } else {
                    self.preload(resetIndex: false, completion: completion)
                }
            }
        case .applovin:
            _applovinHandle.preloadAd { success in
                if success {
                    self._loadingAd = false
                    self._service = self._applovinHandle
                    
                    completion()
                } else {
                    self.preload(resetIndex: false, completion: completion)
                }
            }
        }
    }
    
    func tryToPresent(_ block: @escaping () -> Void) {
        let loadView = PALoadingView()
        loadView.setMessage("Loading ads...")
        
        if DataCommonModel.shared.adsAvailableFor(.interstitial).count > 0 {
            loadView.show()
        }
        
        self.preload {
            loadView.dismiss()
            
            if let s = self._service {
                s.tryToPresent {
                    block()
                }
            } else {
                block()
            }
        }
    }
}
