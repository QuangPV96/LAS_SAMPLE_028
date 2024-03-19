import UIKit

class GenreItemCell: BaseCollectionCell {
    
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        let radio: CGFloat = 110.0 / 55.0
        return .init(width: width, height: width / radio)
    }
    
    // MARK: - properties
    let bgImage: UIImageView = {
        let view = UIImageView(image: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.gilroyMedium(of: 12)
        view.numberOfLines = 2
        view.lineBreakMode = .byWordWrapping
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
        contentView.addSubview(bgImage)
        contentView.addSubview(titleLabel)
        
        bgImage.layoutEdges()
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
    }
    
    // MARK: - public
    var genre: GenreObject! {
        didSet {
            bgImage.image = genre.imageThumbnail
            titleLabel.text = genre.title
        }
    }
    
    // MARK: - event
    
}
