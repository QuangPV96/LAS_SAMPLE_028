import UIKit

class PlaylistDetailTrackItemCell: BaseTableCell {
    
    static var height: CGFloat {
        return 72 + 16
    }
    
    var onOption: ((TrackObject) -> Void)?
    var track: TrackObject? {
        didSet {
            titleLabel.text = track?.title
            subtitleLabel.text = track?.subtitle
            imageTrackView.sd_setImage(with: track?.thumbnailURL, placeholderImage: Thumbnail.track)
        }
    }
    
    // MARK: - properties
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let imageTrackView: UIImageView = {
        let view = UIImageView(image: Thumbnail.playlist)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .init(rgb: 0x3E3F40)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroySemiBold(of: 16)
        view.textColor = .white
        view.numberOfLines = 2
        return view
    }()
    
    fileprivate let subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyMedium(of: 13)
        view.textColor = .init(rgb: 0x747474)
        return view
    }()
    
    fileprivate let optionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-option"), for: .normal)
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(imageTrackView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(optionButton)
        
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        
        containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15).isActive = true
        containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        imageTrackView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        imageTrackView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageTrackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        imageTrackView.widthAnchor.constraint(equalTo: imageTrackView.heightAnchor, multiplier: 1).isActive = true
        
        optionButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        optionButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        optionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: imageTrackView.rightAnchor, constant: 10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo: imageTrackView.rightAnchor, constant: 10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -10).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func optionClick() {
        if let tr = track {
            onOption?(tr)
        }
    }
    
}
