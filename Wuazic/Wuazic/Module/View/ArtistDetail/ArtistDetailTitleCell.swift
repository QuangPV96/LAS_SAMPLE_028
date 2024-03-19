import UIKit

class ArtistDetailTitleCell: BaseTableCell {
    
    static var height: CGFloat {
        return 30
    }
    
    var onMore: (() -> Void)?
    
    var enableMore: Bool = false {
        didSet {
            seeMoreButton.isHidden = !enableMore
        }
    }
    var text: String? {
        didSet {
            titleItemLabel.text = text
        }
    }
    
    // MARK: - properties
    fileprivate let titleItemLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyBold(of: 18)
        view.textColor = .white
        return view
    }()
    
    fileprivate let seeMoreButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("More", for: .normal)
        view.setTitleColor(.init(rgb: 0x00D1EE), for: .normal)
        view.titleLabel?.font = UIFont.gilroyMedium(of: 14)
        view.isHidden = true
        return view
    }()
    
    // MARK: - initial
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    // MARK: - private
    private func drawUIs() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        seeMoreButton.addTarget(self, action: #selector(moreClick), for: .touchUpInside)
        
        contentView.addSubview(titleItemLabel)
        contentView.addSubview(seeMoreButton)
        
        titleItemLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        titleItemLabel.rightAnchor.constraint(equalTo: seeMoreButton.leftAnchor, constant: 15).isActive = true
        titleItemLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        titleItemLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        seeMoreButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seeMoreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        seeMoreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        seeMoreButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func moreClick() {
        onMore?()
    }
    
}
