import UIKit

class PlaylistItemCell: BaseCollectionCell {
    
    var onOption: ((PlaylistObject) -> Void)?
    var playlist: PlaylistObject? {
        didSet {
            titleLabel.text = playlist?.title
            subtitleLabel.text = playlist?.detail
            imageView.sd_setImage(with: playlist?.trackLastThumbnailUrl, placeholderImage: Thumbnail.track, context: nil)
        }
    }
    
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 72)
    }
    
    // MARK: - properties
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: Thumbnail.playlist)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyBold(of: 16)
        view.textColor = .white
        return view
    }()
    
    fileprivate let subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroy(of: 13)
        view.textColor = .init(rgb: 0x8B8B8B)
        return view
    }()
    
    fileprivate let optionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-option"), for: .normal)
        return view
    }()
    
    // MARK: - initital
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
        contentView.backgroundColor = .clear
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(optionButton)
        
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        
        optionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        optionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        optionButton.heightAnchor.constraint(equalTo: optionButton.widthAnchor, multiplier: 1).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -5).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 15).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -5).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    // MARK: - public
    func disableButtonOption() {
        optionButton.isHidden = true
    }
    
    // MARK: - event
    @objc func optionClick() {
        if let p = playlist {
            onOption?(p)
        }
    }
    
}
