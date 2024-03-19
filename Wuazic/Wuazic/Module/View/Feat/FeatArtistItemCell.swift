import UIKit
import SDWebImage

class FeatArtistItemCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(height: CGFloat = 0) -> CGSize {
        return .init(width: 123, height: 135)
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
        view.font = UIFont.gilroySemiBold(of: 14)
        view.textColor = .white
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
        
        imageContainerView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageContainerView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageContainerView.heightAnchor.constraint(equalToConstant: 99).isActive = true
        
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 99).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 99).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    // MARK: - public
    var artist: ArtistObject! {
        didSet {
            titleLabel.text = artist.title
            imageView.sd_setImage(with: artist.thumbnailURL, placeholderImage: Thumbnail.artist)
        }
    }
    
    // MARK: - event
    
}
