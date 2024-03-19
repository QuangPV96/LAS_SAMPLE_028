import UIKit
import AppLovinSDK

public class AppLovinNativeAdTableCell: UITableViewCell {
    
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
    
}
