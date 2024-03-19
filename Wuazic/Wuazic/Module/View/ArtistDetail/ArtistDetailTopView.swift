import UIKit
import SDWebImage

// don't understand why this view use for tableHeaderView gives error
class ArtistDetailTopView: BaseView {
    
    static let height: CGFloat = 230
    
    var artist: ArtistObject? {
        didSet {
            artistNameLabel.text = artist?.title
            subInfoLabel.text = artist?.subscribers
            imageView.sd_setImage(with: artist?.thumbnailURL, placeholderImage: Thumbnail.playlist, context: nil)
        }
    }
    
    // MARK: - properties
    fileprivate let imageContainerView: UIImageView = {
        let view = UIImageView(image: Thumbnail.artist)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: Thumbnail.playlist)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let artistNameLabel: UILabel = {
       let view = UILabel()
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 24)
        return view
    }()
    
    fileprivate let subInfoLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.gilroy(of: 16)
        view.textColor = .init(rgb: 0x00D1EE)
        view.textAlignment = .center
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrameForImageView()
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        
        addSubview(imageContainerView)
        addSubview(artistNameLabel)
        addSubview(subInfoLabel)
        
        imageContainerView.addSubview(imageView)
    }
    
    private func updateFrameForImageView() {
        let ratio: CGFloat = 248.0 / 200.0
        let h: CGFloat = 150.0
        var f = CGRect(x: 0, y: 0, width: h * ratio, height: h)
        f.origin.x = frame.size.width > f.size.width ? (frame.size.width - f.size.width) / 2 : 0
        f.origin.y = 0
        
        imageContainerView.frame = f
        imageView.frame = .init(x: 0, y: 0, width: f.size.height, height: f.size.height)
        
        artistNameLabel.frame = .init(x: 20,
                                      y: imageContainerView.origin.y + imageContainerView.size.height + 15,
                                      width: frame.size.width - 40,
                                      height: 40)
        
        subInfoLabel.frame = .init(x: 20, y: artistNameLabel.origin.y + artistNameLabel.size.height, width: frame.size.width - 40, height: 20)
    }
    
    // MARK: - public
    
    
}
