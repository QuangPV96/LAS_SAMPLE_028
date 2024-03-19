import UIKit
import SDWebImage

class ArtistItemCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 99)
    }
    
    // MARK: - properties
    fileprivate let imageContainerView: UIImageView = {
        let view = UIImageView(image: Thumbnail.artist)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
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
    
    fileprivate let subInfoLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyMedium(of: 14)
        view.textColor = .init(rgb: 0x747474)
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
        contentView.addSubview(imageContainerView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subInfoLabel)
        
        imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageContainerView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageContainerView.widthAnchor.constraint(equalToConstant: 123).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: 99).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 99).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 99).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageContainerView.rightAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        subInfoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subInfoLabel.leftAnchor.constraint(equalTo: imageContainerView.rightAnchor, constant: 15).isActive = true
        subInfoLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        subInfoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    // MARK: - public
    var artist: ArtistObject! {
        didSet {
            titleLabel.text = artist.title
            subInfoLabel.text = artist.subscribers
            imageView.sd_setImage(with: artist.thumbnailURL, placeholderImage: Thumbnail.newest)
        }
    }
    
    // MARK: - event
    
}
