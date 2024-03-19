//
//  PlayerMiniView.swift
//  SwiftyAds
//
//  Created by MinhNH on 12/04/2023.
//

import UIKit
import SDWebImage

class PlayerMiniView: BaseView {
    
    static let height: CGFloat = 60
    
    var onClick: (() -> Void)?
    var onPlayOrPause: (() -> Void)?
    var playinsg: Bool = false {
        didSet {
            playButton.isSelected = playinsg
        }
    }
    var track: TrackObject? {
        didSet {
            titleTrackLabel.text = track?.title
            subtitleTrackLabel.text = track?.subtitle
            thumbnailImage.sd_setImage(with: track?.thumbnailURL, placeholderImage: Thumbnail.track, context: nil)
        }
    }
    
    var isPresenting: Bool = false
    
    // MARK: - properties
    fileprivate let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    fileprivate let playerLayerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(rgb: 0x8B8B8B)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let titleTrackLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 14)
        return view
    }()
    
    fileprivate let subtitleTrackLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .init(rgb: 0x3D3E3E)
        view.font = UIFont.gilroyMedium(of: 12)
        return view
    }()
    
    fileprivate let playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-mini-play"), for: .normal)
        view.setImage(UIImage(imgName: "ic-mini-pause"), for: .selected)
        return view
    }()
    
    fileprivate let waveContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
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
        
        playerLayerView.layer.cornerRadius = playerLayerView.size.width / 2
        thumbnailImage.layer.cornerRadius = thumbnailImage.size.width / 2
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        layer.cornerRadius = PlayerMiniView.height / 2
        clipsToBounds = true
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick)))
        
        thumbnailImage.image = UIImage(imgName: "mock-hot")
        
        playButton.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        
        addSubview(blurEffectView)
        addSubview(playerLayerView)
        addSubview(waveContainerView)
        addSubview(titleTrackLabel)
        addSubview(subtitleTrackLabel)
        addSubview(playButton)
        
        playerLayerView.addSubview(thumbnailImage)
        thumbnailImage.layoutEdges()
        
        blurEffectView.layoutEdges()
        
        playerLayerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playerLayerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        playerLayerView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playerLayerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        titleTrackLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        titleTrackLabel.leftAnchor.constraint(equalTo: playerLayerView.rightAnchor, constant: 10).isActive = true
        titleTrackLabel.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -10).isActive = true
        titleTrackLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        subtitleTrackLabel.topAnchor.constraint(equalTo: titleTrackLabel.bottomAnchor).isActive = true
        subtitleTrackLabel.leftAnchor.constraint(equalTo: titleTrackLabel.leftAnchor).isActive = true
        subtitleTrackLabel.rightAnchor.constraint(equalTo: titleTrackLabel.rightAnchor).isActive = true
        subtitleTrackLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        waveContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        waveContainerView.leftAnchor.constraint(equalTo: titleTrackLabel.leftAnchor).isActive = true
        waveContainerView.rightAnchor.constraint(equalTo: titleTrackLabel.rightAnchor).isActive = true
        waveContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func playClick() {
        onPlayOrPause?()
    }
    
    @objc func viewClick() {
        onClick?()
    }
    
}
