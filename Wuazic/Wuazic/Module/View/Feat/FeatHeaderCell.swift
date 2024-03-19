//
//  FeatHeaderCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 10/04/2023.
//

import UIKit

class FeatHeaderCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 50)
    }
    
    // MARK: - properties
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "musixo"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
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
        
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 137).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 37).isActive = true
    }
    
    // MARK: - public
    // MARK: - event
    
}
