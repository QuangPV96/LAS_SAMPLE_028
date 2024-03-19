import UIKit

class BaseCollectionCell: UICollectionViewCell {
    
    lazy var loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let view = UIActivityIndicatorView(style: .medium)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.color = .white
            return view
        }
        else {
            let view = UIActivityIndicatorView(style: .white)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
    }()
    
    func setupAnimateLoadingView() {
        contentView.addSubview(loadingView)
        loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        loadingView.startAnimating()
    }
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
    }
    
    class func size(width: CGFloat = 0) -> CGSize {
        return .zero
    }
    
    class func size(height: CGFloat = 0) -> CGSize {
        return .zero
    }
}
