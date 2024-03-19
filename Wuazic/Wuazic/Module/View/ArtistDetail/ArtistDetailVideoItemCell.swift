//
//  ArtistDetailVideoItemCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 17/04/2023.
//

import UIKit
import SDWebImage

class ArtistDetailVideoItemCell: BaseCollectionCell {
    
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: 160, height: 150)
    }
    
    var track: TrackObject? {
        didSet {
            titleLabel.text = track?.title
            subtitleLabel.text = track?.subtitle
            imageTrackView.sd_setImage(with: track?.thumbnailURL, placeholderImage: Thumbnail.mainplayer)
        }
    }
    
    // MARK: - properties
    fileprivate let imageTrackView: UIImageView = {
        let view = UIImageView(image: Thumbnail.track)
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
        view.font = UIFont.gilroyMedium(of: 16)
        view.textColor = .white
        view.numberOfLines = 1
        return view
    }()
    
    fileprivate let subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroy(of: 12)
        view.textColor = .init(rgb: 0x8B8B8B)
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
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(imageTrackView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        imageTrackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageTrackView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageTrackView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageTrackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: imageTrackView.bottomAnchor, constant: 5).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor).isActive = true
        
        subtitleLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    
}
