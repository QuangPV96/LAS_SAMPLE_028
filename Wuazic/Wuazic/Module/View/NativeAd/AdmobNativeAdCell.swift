//
//  AdmobNativeAdCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit
import GoogleMobileAds

public class AdmobNativeAdCell: UICollectionViewCell {
    
    // MARK: - properties
    private var nativeView: AdmobNativeAdView!
    
    public var nativeAd: Any? = nil {
        didSet { nativeView.nativeAd = nativeAd as? GADNativeAd }
    }
    
    // MARK: - initial
    public init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialViews()
    }
    
    // MARK: - private
    private func initialViews() {
        guard let nibObjects = Bundle.current.loadNibNamed("AdmobNativeAdView", owner: nil, options: nil),
              let adView = nibObjects.first as? AdmobNativeAdView else {
            return
        }
        
        backgroundColor = .clear
        self.backgroundColor = .clear
        adView.backgroundColor = NativeAdStyle.mainBackground
        nativeView = adView
        nativeView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nativeView)
        
        // auto layout
        nativeView.leftAnchor.constraint(equalTo: leftAnchor, constant: NativeAdStyle.paddingHorizontal).isActive = true
        nativeView.rightAnchor.constraint(equalTo: rightAnchor, constant: -NativeAdStyle.paddingHorizontal).isActive = true
        nativeView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        nativeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: - helper
    public static var height: CGFloat {
        return AdmobNativeAdView.height
    }
    
    public class func size(_ width: CGFloat = 0) -> CGSize {
        if width == 0 {
            return CGSize(width: UIScreen.main.bounds.size.width, height: AdmobNativeAdView.height)
        }
        return CGSize(width: width, height: AdmobNativeAdView.height)
    }
}
