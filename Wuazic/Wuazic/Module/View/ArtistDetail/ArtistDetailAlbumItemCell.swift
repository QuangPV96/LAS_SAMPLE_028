//
//  ArtistDetailAlbumItemCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 24/04/2023.
//

import UIKit
import SDWebImage

class ArtistDetailAlbumItemCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(height: CGFloat = 0) -> CGSize {
        return .init(width: 99, height: 135)
    }
    
    // MARK: - properties
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
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
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
    var playlist: PlaylistObject! {
        didSet {
            titleLabel.text = playlist.title
            imageView.sd_setImage(with: playlist.trackThumbnailUrl, placeholderImage: Thumbnail.playlist)
        }
    }
    
    // MARK: - event
    
}
