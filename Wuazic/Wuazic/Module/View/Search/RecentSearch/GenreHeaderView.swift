//
//  GenreHeaderView.swift
//  SwiftyAds
//
//  Created by MinhNH on 23/04/2023.
//

import UIKit

class GenreHeaderView: UICollectionReusableView {
    
    // MARK: - properties
    fileprivate let titleHeader: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Genres"
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 16)
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
        addSubview(titleHeader)
        
        titleHeader.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleHeader.leftAnchor.constraint(equalTo: leftAnchor, constant: kPadding).isActive = true
        titleHeader.rightAnchor.constraint(equalTo: rightAnchor, constant: -kPadding).isActive = true
        titleHeader.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    // MARK: - public
    
}
