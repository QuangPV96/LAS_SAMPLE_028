//
//  TabItemCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 11/04/2023.
//

import UIKit

class TabItemCell: BaseCollectionCell {
    
    // MARK: - properties
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroySemiBold(of: 16)
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
        contentView.addSubview(titleLabel)
        
        titleLabel.layoutEdges()
    }
    
    // MARK: - public
    func setTab(_ tab: TabEnum, tabSelected: TabEnum) {
        titleLabel.text = tab.title()
        titleLabel.textColor = tab == tabSelected ? UIColor.white : UIColor(rgb: 0x6E737A)
    }
    
    func setTabSearch(_ tab: TabSearchEnum, tabSelected: TabSearchEnum) {
        titleLabel.text = tab.title()
        titleLabel.textColor = tab == tabSelected ? UIColor.white : UIColor(rgb: 0x6E737A)
    }
    
    class func textSize(text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = UIFont.gilroySemiBold(of: 16)
        label.text = text
        label.sizeToFit()
        return .init(width: label.frame.size.width, height: height)
    }
    
    // MARK: - event
    
}
