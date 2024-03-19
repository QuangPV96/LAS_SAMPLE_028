import UIKit
import AppLovinSDK

public class AppLovinNativeAdCell: UICollectionViewCell {
    
    // MARK: - properties
    lazy var nativeView: AppLovinNativeAdView = {
        let view = AppLovinNativeAdView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public var nativeAd: Any? = nil {
        didSet { nativeView.nativeAdView = nativeAd as? MANativeAdView }
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        nativeView.backgroundColor = NativeAdStyle.mainBackground
        contentView.addSubview(nativeView)
        
        // auto layout
        nativeView.leftAnchor.constraint(equalTo: leftAnchor, constant: NativeAdStyle.paddingHorizontal).isActive = true
        nativeView.rightAnchor.constraint(equalTo: rightAnchor, constant: -NativeAdStyle.paddingHorizontal).isActive = true
        nativeView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        nativeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: - helper
    public static var height: CGFloat {
        return AppLovinNativeAdView.height
    }
    
    public class func size(_ width: CGFloat = 0) -> CGSize {
        if width == 0 {
            return CGSize(width: UIScreen.main.bounds.size.width, height: AppLovinNativeAdView.height)
        }
        return CGSize(width: width, height: AppLovinNativeAdView.height)
    }
}
