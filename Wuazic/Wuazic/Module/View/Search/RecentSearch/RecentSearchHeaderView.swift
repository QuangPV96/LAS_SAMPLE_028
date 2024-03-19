import UIKit

class RecentSearchHeaderView: UICollectionReusableView {
    
    var onClearAll: (() -> Void)?
    
    // MARK: - properties
    let titleHeader: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Recent search"
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 16)
        return view
    }()
    
    let clearAllButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-clear-all"), for: .normal)
        return view
    }()
    
    // MARK: - initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    // MARK: - private
    private func drawUIs() {
        clearAllButton.addTarget(self, action: #selector(clearAllClick), for: .touchUpInside)
        
        addSubview(titleHeader)
        addSubview(clearAllButton)
        
        clearAllButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        clearAllButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -kPadding).isActive = true
        clearAllButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        clearAllButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        titleHeader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleHeader.leftAnchor.constraint(equalTo: leftAnchor, constant: kPadding).isActive = true
        titleHeader.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        titleHeader.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func clearAllClick() {
        onClearAll?()
    }
    
}
