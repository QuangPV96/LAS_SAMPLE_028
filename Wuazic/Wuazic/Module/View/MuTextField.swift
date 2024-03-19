import UIKit

class MuTextField: UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .white
            }
        }
    }
}

extension UITextField {
    var textString: String {
        guard let val = text else { return "" }
        
        return val.trimmingCharacters(in: .whitespaces)
    }
}
