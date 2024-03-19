//
//  SearchSuggestCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 23/04/2023.
//

import UIKit

class SearchSuggestCell: BaseCollectionCell {
    
    var term: String? {
        didSet { titleLabel.text = term }
    }
    
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 45)
    }
    
    // MARK: - properties
    let iconImage: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "ic-suggestion"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.font = UIFont.gilroyMedium(of: 16)
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
        contentView.addSubview(iconImage)
        contentView.addSubview(titleLabel)
        
        iconImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        iconImage.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        iconImage.widthAnchor.constraint(equalTo: iconImage.heightAnchor, multiplier: 1).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    // MARK: - public
    // MARK: - event
    
}
