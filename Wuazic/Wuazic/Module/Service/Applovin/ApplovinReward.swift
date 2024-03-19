//
//  ApplovinReward.swift
//  SwiftyAds
//
//  Created by MinhNH on 26/04/2023.
//

import UIKit
import AppLovinSDK

class ApplovinReward: NSObject {
    
    // MARK: - properties
    private var _rewardedAd: MARewardedAd?
    private var _loadHandler: ((_ success: Bool) -> Void)?
    private var _didEarnHandler: (() -> Void)?
    
    // MARK:
    var canShowAds: Bool {
        if DataCommonModel.shared.applovin_reward.isEmpty {
            LogService.shared.show("Applovin: Reward ID is empty")
            return false
        }
        
//        if !DataCommonModel.shared.isAvailable(.applovin, .reward) {
//            LogService.shared.show("Applovin: Not available Reward ads type")
//            return false
//        }
        
        return true
    }
    
    var isReady: Bool {
        return _rewardedAd != nil && _rewardedAd!.isReady
    }
    
    // MARK: - initial
    override init() {
        super.init()
    }
    
    // MARK: - public
    func preloadAd(completion: @escaping (_ isSuccess: Bool) -> Void) {
        self._loadHandler = nil
        self._rewardedAd = nil
        
        guard canShowAds else {
            completion(false)
            return
        }
        
        self._loadHandler = completion
        
        _rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: DataCommonModel.shared.applovin_reward)
        _rewardedAd?.delegate = self
        _rewardedAd?.revenueDelegate = self
        _rewardedAd?.load()
    }
    
    func tryToPresentDidEarnReward(with handler: @escaping () -> Void) {
        self._didEarnHandler = nil
        
        guard isReady else { return }
        
        self._didEarnHandler = handler
        self._rewardedAd?.show()
    }
    
}

extension ApplovinReward: MARewardedAdDelegate, MAAdRevenueDelegate {
    public func didStartRewardedVideo(for ad: MAAd) {
        
    }
    
    public func didCompleteRewardedVideo(for ad: MAAd) {
        
    }
    
    public func didRewardUser(for ad: MAAd, with reward: MAReward) {
        if let handler = self._didEarnHandler {
            handler()
            self._didEarnHandler = nil
        }
    }
    
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
    
    public func didDisplay(_ ad: MAAd) {
        
    }
    
    public func didHide(_ ad: MAAd) {
        
    }
    
    public func didClick(_ ad: MAAd) {
        
    }
    
    public func didFail(toDisplay ad: MAAd, withError error: MAError) {
        
    }
}
