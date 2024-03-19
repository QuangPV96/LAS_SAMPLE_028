import UIKit

class BaseView: UIView {
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
    }
    
}
