import UIKit
import AppLovinSDK

public class AppLovinNativeAdView: UIView {
    
    public var nativeAdView: MANativeAdView? {
        didSet {
            guard let nativeAdView = nativeAdView else { return }
            
            nativeAdView.titleLabel?.textColor = NativeAdStyle.titleColor
            nativeAdView.titleLabel?.font = NativeAdStyle.titleFont
            
            nativeAdView.advertiserLabel?.textColor = NativeAdStyle.advertiserColor
            nativeAdView.advertiserLabel?.font = NativeAdStyle.advertiserFont
            
            nativeAdView.callToActionButton?.setTitleColor(NativeAdStyle.callActionColor, for: .normal)
            nativeAdView.callToActionButton?.backgroundColor = NativeAdStyle.callActionBackground
            nativeAdView.callToActionButton?.titleLabel?.font = NativeAdStyle.callActionFont
            
            nativeAdView.callToActionButton?.layer.cornerRadius = NativeAdStyle.callActionCornerRadius
            nativeAdView.callToActionButton?.clipsToBounds = true
            
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            nativeAdView.backgroundColor = NativeAdStyle.mainBackground
            
            self.addSubview(nativeAdView)
            
            // Set ad view to span width and height of container and center the ad
            self.addConstraint(NSLayoutConstraint(item: nativeAdView,
                                                                   attribute: .width,
                                                                   relatedBy: .equal,
                                                                   toItem: self,
                                                                   attribute: .width,
                                                                   multiplier: 1,
                                                                   constant: 0))
            self.addConstraint(NSLayoutConstraint(item: nativeAdView,
                                                                   attribute: .height,
                                                                   relatedBy: .equal,
                                                                   toItem: self,
                                                                   attribute: .height,
                                                                   multiplier: 1,
                                                                   constant: 0))
            self.addConstraint(NSLayoutConstraint(item: nativeAdView,
                                                                   attribute: .centerX,
                                                                   relatedBy: .equal,
                                                                   toItem: self,
                                                                   attribute: .centerX,
                                                                   multiplier: 1,
                                                                   constant: 0))
            self.addConstraint(NSLayoutConstraint(item: nativeAdView,
                                                                   attribute: .centerY,
                                                                   relatedBy: .equal,
                                                                   toItem: self,
                                                                   attribute: .centerY,
                                                                   multiplier: 1,
                                                                   constant: 0))
        }
    }
    
    
    // MARK: override from supper
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = NativeAdStyle.cornerRadius
        clipsToBounds = true
        
    }
    
    // MARK: helper
    public static var height: CGFloat {
        return 120
    }
}
