import UIKit

class OptionItemTableCell: BaseTableCell {
    
    // MARK: - properties
    let iconImage: UIImageView = {
        let view = UIImageView(image: Thumbnail.track)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.font = UIFont.gilroyMedium(of: 16)
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
        contentView.addSubview(iconImage)
        contentView.addSubview(titleLabel)
        
        iconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        iconImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImage.widthAnchor.constraint(equalTo: iconImage.heightAnchor, multiplier: 1).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    // MARK: - public
    
    // MARK: - event
    
}
