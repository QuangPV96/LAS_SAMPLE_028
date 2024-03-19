import UIKit

class PlaylistDetailNoDataCell: BaseTableCell {
    
    static var height: CGFloat {
        return 350
    }
    
    // MARK: - properties
    fileprivate let imageNoDataView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "ic-playlist-nodata"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroySemiBold(of: 16)
        view.textColor = .white
        view.text = "No Data"
        view.textAlignment = .center
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
        
        contentView.addSubview(imageNoDataView)
        contentView.addSubview(titleLabel)
        
        imageNoDataView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageNoDataView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageNoDataView.widthAnchor.constraint(equalToConstant: 86).isActive = true
        imageNoDataView.heightAnchor.constraint(equalToConstant: 86).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageNoDataView.bottomAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
}
