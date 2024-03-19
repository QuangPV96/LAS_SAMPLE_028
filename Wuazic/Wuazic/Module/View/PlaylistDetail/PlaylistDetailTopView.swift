//
//  PlaylistDetailTopView.swift
//  SwiftyAds
//
//  Created by MinhNH on 14/04/2023.
//

import UIKit
import SDWebImage

// don't understand why this view use for tableHeaderView gives error
class PlaylistDetailTopView: BaseView {
    
    static let height: CGFloat = 150
    
    var trackThumbnailUrl: URL? {
        didSet {
            imageView.sd_setImage(with: trackThumbnailUrl, placeholderImage: Thumbnail.playlist, context: nil)
        }
    }
    
    // MARK: - properties
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: Thumbnail.playlist)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
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
        addSubview(imageView)
    }
    
    private func updateFrameForImageView() {
        let width: CGFloat = 130
        var f = CGRect(x: 0, y: 0, width: width, height: width)
        f.origin.x = frame.size.width > f.size.width ? (frame.size.width - f.size.width) / 2 : 0
        f.origin.y = frame.size.height > f.size.height ? (frame.size.height - f.size.height) / 2 : 0
        
        imageView.frame = f
    }
    
    // MARK: - public
    
    
}
