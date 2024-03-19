//
//  AdmobNativeAdView.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit
import GoogleMobileAds

public class AdmobNativeAdView: GADNativeAdView {
    // MARK: outlet
    @IBOutlet weak var adBadge: UILabel!
    @IBOutlet weak var advertiser: UILabel!
    
    // MARK: properties
    public override var nativeAd: GADNativeAd? {
        didSet {
            guard let ad = nativeAd else { return }
            
            (headlineView as? UILabel)?.text = ad.headline ?? ""
            
            if (ad.store ?? "").count > 0 && (ad.advertiser ?? "").count == 0 {
                advertiser.text = ad.store!
            }
            else if (ad.store ?? "").count == 0 && (ad.advertiser ?? "").count > 0 {
                advertiser.text = ad.advertiser!
            }
            else {
                advertiser.text = ad.advertiser ?? ""
            }
            
            (callToActionView as? UIButton)?.setTitle(ad.callToAction ?? "", for: .normal)
            callToActionView?.isUserInteractionEnabled = false
            callToActionView?.layer.cornerRadius = NativeAdStyle.callActionCornerRadius
            callToActionView?.clipsToBounds = true
            
            mediaView?.mediaContent = ad.mediaContent
        }
    }
    
    // MARK: override from supper
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = NativeAdStyle.cornerRadius
        clipsToBounds = true
        (headlineView as? UILabel)?.textColor = NativeAdStyle.titleColor
        (headlineView as? UILabel)?.font = NativeAdStyle.titleFont
        (headlineView as? UILabel)?.numberOfLines = 2
        
        advertiser.textColor = NativeAdStyle.advertiserColor
        advertiser.font = NativeAdStyle.advertiserFont
        advertiser.numberOfLines = 1
        
        (callToActionView as? UIButton)?.setTitleColor(NativeAdStyle.callActionColor, for: .normal)
        (callToActionView as? UIButton)?.backgroundColor = NativeAdStyle.callActionBackground
        (callToActionView as? UIButton)?.titleLabel?.font = NativeAdStyle.callActionFont
        
        //
        adBadge.layer.borderColor = adBadge.textColor.cgColor
        adBadge.layer.borderWidth = 1.0
        adBadge.layer.cornerRadius = 3.0
        adBadge.clipsToBounds = true
    }
    
    // MARK: helper
    public static var height: CGFloat {
        return 120
    }
}
