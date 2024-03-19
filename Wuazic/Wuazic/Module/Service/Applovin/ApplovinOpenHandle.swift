import UIKit
import AppLovinSDK

public class ApplovinOpenHandle: NSObject {
    
    // MARK: - properties
    private var _appOpenAd: MAAppOpenAd?
    
    // MARK: - initial
    @objc public static let shared = ApplovinOpenHandle()
    
    override init() {
        super.init()
    }
    
    // MARK: - private
    
    // MARK: -
    var canShowAds: Bool {
        if !ApplovinHandle.shared.isReady {
            LogService.shared.show("Applovin is not ready yet")
            return false
        }
        
        if DataCommonModel.shared.applovin_appopen.isEmpty {
            LogService.shared.show("Applovin: App open ID is empty")
            return false
        }
        
        if !DataCommonModel.shared.isAvailable(.applovin, .open) {
            LogService.shared.show("Applovin: Not available App open ads type")
            return false
        }
        
        return true
    }
    
    var isReady: Bool {
        return _appOpenAd != nil
    }
    
    // MARK: - public
    public func preloadAd(completion: ((_ success: Bool) -> Void)?) {
        self._appOpenAd = nil
        
        guard canShowAds else {
            completion?(false)
            return
        }
        
        self._appOpenAd = MAAppOpenAd(adUnitIdentifier: DataCommonModel.shared.applovin_appopen)
        self._appOpenAd?.delegate = self
        self._appOpenAd?.load()
    }
    
    func preloadAdIfNeed() {
        if self._appOpenAd == nil {
            self.preloadAd(completion: nil)
        }
    }
    
    @discardableResult
    @objc public func tryToPresent() -> Bool {
        guard isReady else {
            if _appOpenAd == nil {
                self.awake()
            }
            return false
        }
        
        if (_appOpenAd?.isReady ?? false) {
            _appOpenAd?.show()
            return true
        }
        else {
            _appOpenAd?.load()
            return false
        }
    }
    
    @objc public func awake() {
        self.preloadAd(completion: nil)
    }
    
}

extension ApplovinOpenHandle: MAAdDelegate {
    public func didLoad(_ ad: MAAd) {
        LogService.shared.show("loaded applovin")
    }
    
    public func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        
    }
    
    public func didDisplay(_ ad: MAAd) {
        
    }
    
    public func didClick(_ ad: MAAd) {
        
    }
    
    public func didHide(_ ad: MAAd) {
        self._appOpenAd?.load()
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        self._appOpenAd?.load()
    }
}
