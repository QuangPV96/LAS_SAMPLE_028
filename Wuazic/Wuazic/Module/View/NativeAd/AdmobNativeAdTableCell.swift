//
//  AdmobNativeAdTableCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit
import GoogleMobileAds

public class AdmobNativeAdTableCell: UITableViewCell {
    
    // MARK: - properties
    private var nativeView: AdmobNativeAdView!
    
    public var nativeAd: Any? = nil {
        didSet { nativeView.nativeAd = nativeAd as? GADNativeAd }
    }
    
    // MARK: - initial
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        adView.backgroundColor = NativeAdStyle.mainBackground
        nativeView = adView
        nativeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nativeView)
        
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
    
}
