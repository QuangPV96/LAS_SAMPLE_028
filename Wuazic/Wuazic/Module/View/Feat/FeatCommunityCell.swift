//
//  FeatCommunityCell.swift
//  Fzsounds
//
//  Created by quang on 17/08/2023.
//

import UIKit

class FeatCommunityCell: BaseCollectionCell {

    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 148)
    }
    
    fileprivate let imagBG: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "bg_community_feat")
        return view
    }()
    
    fileprivate let btnJoinNow: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "ic_join_now"), for: .normal)
        return view
    }()

    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyBold(of: 20)
        view.textColor = .white
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 2
        view.textAlignment = NSTextAlignment.center
        view.text = "Join our community to receive\nlatest update."
        return view
    }()
    
    var onCommunity: (() -> Void)?
    
    // MARK: - initital
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    private func drawUIs() {
        contentView.backgroundColor = .clear
        contentView.addSubview(imagBG)
        contentView.addSubview(titleLabel)
        contentView.addSubview(btnJoinNow)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        btnJoinNow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        btnJoinNow.widthAnchor.constraint(equalToConstant: 153).isActive = true
        btnJoinNow.heightAnchor.constraint(equalToConstant: 46).isActive = true
        btnJoinNow.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        imagBG.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imagBG.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 16).isActive = true
        imagBG.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: -16).isActive = true
        imagBG.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        btnJoinNow.addTarget(self, action: #selector(communityClick), for: .touchUpInside)
        
        let teleChannel: String = DataCommonModel.shared.extraFind("telegram_channel") ?? ""
        let teleGroup: String = DataCommonModel.shared.extraFind("telegram_group") ?? ""
        let discord: String = DataCommonModel.shared.extraFind("discord_group") ?? ""
        
        if teleChannel != "" || teleGroup != "" || discord != "" {
            imagBG.isHidden = false
            titleLabel.isHidden = false
            btnJoinNow.isHidden = false
        } else {
            imagBG.isHidden = true
            titleLabel.isHidden = true
            btnJoinNow.isHidden = true
        }
        
    }
    // MARK: - event
    @objc func communityClick() {
        onCommunity?()
    }
}
