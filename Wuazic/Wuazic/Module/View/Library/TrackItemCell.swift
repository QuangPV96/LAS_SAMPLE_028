import UIKit
import SDWebImage

class TrackItemCell: BaseCollectionCell {
    
    var onOption: ((TrackObject) -> Void)?
    var track: TrackObject? {
        didSet {
            titleLabel.text = track?.title
            subtitleLabel.text = track?.subtitle
            imageView.sd_setImage(with: track?.thumbnailURL, placeholderImage: Thumbnail.track)
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
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        
        optionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        optionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        optionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -10).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    // MARK: - public
    // MARK: - event
    @objc func optionClick() {
        if let tr = track {
            onOption?(tr)
        }
    }
}
