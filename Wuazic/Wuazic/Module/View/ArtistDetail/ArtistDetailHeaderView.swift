//
//  ArtistDetailHeaderView.swift
//  SwiftyAds
//
//  Created by MinhNH on 17/04/2023.
//

import UIKit

class ArtistDetailHeaderView: BaseView {
    
    static var height: CGFloat {
        return 70
    }
    
    var onShuffle: ((ArtistObject) -> Void)?
    var onPlay: ((ArtistObject) -> Void)?
    var onFavourite: ((ArtistObject) -> Void)?
    var artist: ArtistObject! {
        didSet {
            favouriteButton.isSelected = DBService.shared.existsArtistOnDb(artist.browseId)
        }
    }
    
    // MARK: - properties
    fileprivate let shuffleButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-artist-shuffle"), for: .normal)
        return view
    }()
    
    fileprivate let playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-artist-play"), for: .normal)
        return view
    }()
    
    fileprivate let favouriteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-artist-like"), for: .normal)
        view.setImage(UIImage(imgName: "ic-artist-liked"), for: .selected)
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
        //backgroundColor = .init(rgb: 0x0E0D0D)
        
        shuffleButton.addTarget(self, action: #selector(shuffleClick), for: .touchUpInside)
        favouriteButton.addTarget(self, action: #selector(favouriteClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        
        addSubview(shuffleButton)
        addSubview(playButton)
        addSubview(favouriteButton)
        
        playButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 126).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        shuffleButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        shuffleButton.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -20).isActive = true
        shuffleButton.widthAnchor.constraint(equalToConstant: 46).isActive = true
        shuffleButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        favouriteButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        favouriteButton.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 20).isActive = true
        favouriteButton.widthAnchor.constraint(equalToConstant: 46).isActive = true
        favouriteButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func shuffleClick() {
        onShuffle?(artist)
    }
    
    @objc func favouriteClick() {
        onFavourite?(artist)
    }
    
    @objc func playClick() {
        onPlay?(artist)
    }
    
}
