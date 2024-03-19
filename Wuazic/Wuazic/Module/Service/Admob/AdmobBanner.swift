import UIKit
import GoogleMobileAds

public enum AdmobBannerPosition {
    case top
    case bottom
}

public class AdmobBanner: NSObject {
    private var _bannerView: GADBannerView!
    private var _loadHandler: ((_ size: CGSize, _ isSuccess: Bool) -> Void)?
    
    public init(loadHandler: ((_ size: CGSize, _ isSuccess: Bool) -> Void)?) {
        super.init()
        self._loadHandler = loadHandler
    }
    
    private func canShowAds() -> Bool {
        if !AdmobHandle.shared.isReady {
            LogService.shared.show("Admob is not ready yet")
            return false
        }
        
        if DataCommonModel.shared.admob_banner.isEmpty {
            LogService.shared.show("Admob: Banner ID is empty")
            return false
        }
        
        return true
    }
    
    private func getFullWidthAdaptiveAdSize(_ view: UIView) -> GADAdSize {
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return view.frame.inset(by: view.safeAreaInsets)
            } else {
                return view.frame
            }
        }()
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(frame.size.width)
    }
    
    public func addToViewIfNeed(parent: UIView,
                                controller: UIViewController,
                                backgroundColor: UIColor = .white,
                                position: AdmobBannerPosition = .bottom,
                                padding: CGFloat = 0)
    {
        if !canShowAds() || _bannerView != nil {
            _loadHandler?(.zero, false)
            return
        }
        
        _bannerView = GADBannerView(adSize: getFullWidthAdaptiveAdSize(parent))
        _bannerView.translatesAutoresizingMaskIntoConstraints = false
        _bannerView.backgroundColor = backgroundColor
        _bannerView.adUnitID = DataCommonModel.shared.admob_banner
        _bannerView.rootViewController = controller
        _bannerView.delegate = self
        _bannerView.load(GADRequest())
        parent.addSubview(_bannerView)
        
        switch position {
        case .top:
            parent.addConstraints(
                [NSLayoutConstraint(item: _bannerView as Any,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: parent.safeAreaLayoutGuide,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: padding),
                 NSLayoutConstraint(item: _bannerView as Any,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: parent,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        case .bottom:
            parent.addConstraints(
                [NSLayoutConstraint(item: _bannerView as Any,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: parent.safeAreaLayoutGuide,
                                    attribute: .bottom,
                                    multiplier: 1,
                                    constant: -padding),
                 NSLayoutConstraint(item: _bannerView as Any,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: parent,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        }
    }
    
    public func removeFromSuperView() {
        if _bannerView != nil {
            _bannerView.removeFromSuperview()
        }
    }
}

extension AdmobBanner: GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ _bannerView: GADBannerView) {
        if let handler = _loadHandler {
            handler(_bannerView.frame.size, true)
        }
    }
    
    public func bannerView(_ _bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        removeFromSuperView()
        
        if let handler = _loadHandler {
            handler(.zero, false)
        }
    }
    
}
