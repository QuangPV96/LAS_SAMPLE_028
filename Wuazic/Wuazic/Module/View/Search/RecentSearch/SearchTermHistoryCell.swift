//
//  SearchTermHistoryCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 23/04/2023.
//

import UIKit

class SearchTermHistoryCell: BaseCollectionCell {
    
    var term: String? {
        didSet { titleLabel.text = term }
    }
    
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 45)
    }
    
    // MARK: - properties
    fileprivate let dotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(rgb: 0xEB0038)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroy(of: 16)
        view.textColor = .white
        view.numberOfLines = 2
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
        contentView.addSubview(dotView)
        contentView.addSubview(titleLabel)
        
        dotView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        dotView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        dotView.widthAnchor.constraint(equalToConstant: 5).isActive = true
        dotView.widthAnchor.constraint(equalTo: dotView.heightAnchor, multiplier: 1).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: dotView.rightAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    // MARK: - public
    // MARK: - event
    
}
