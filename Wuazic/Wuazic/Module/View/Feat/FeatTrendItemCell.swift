//
//  FeatTrendItemCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit
import SDWebImage

class FeatTrendItemCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(height: CGFloat = 0) -> CGSize {
        return .init(width: 320, height: height)
    }
    
    // MARK: - properties
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.borderColor = UIColor(rgb: 0x979797).withAlphaComponent(0.5).cgColor
        view.layer.borderWidth = 0.1
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.backgroundColor = .init(rgb: 0x3E3F40)
        return view
    }()
    
    fileprivate let numberLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyXBold(of: 44)
        view.textColor = .clear
        return view
    }()
    
    fileprivate let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroySemiBold(of: 16)
        view.textColor = .white
        return view
    }()
    
    fileprivate let subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyMedium(of: 13)
        view.textColor = .init(rgb: 0x747474)
        return view
    }()
    
    fileprivate let playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-trend-play"), for: .normal)
        return view
    }()
    
    fileprivate let daolodButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-donwlaod"), for: .normal)
        view.setImage(UIImage(imgName: "ic-donwlaod-active"), for: .selected)
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
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - private
    private func drawUIs() {
        contentView.backgroundColor = .clear
        contentView.addSubview(imageView)
        contentView.addSubview(playButton)
        contentView.addSubview(bottomView)
        
        daolodButton.addTarget(self, action: #selector(daolodClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        
        bottomView.addSubview(numberLabel)
        bottomView.addSubview(titleLabel)
        bottomView.addSubview(subtitleLabel)
        bottomView.addSubview(daolodButton)
        bottomView.addSubview(loadingView)
        
        //
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //
        bottomView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bottomView.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        numberLabel.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor, constant: 4).isActive = true
        numberLabel.leftAnchor.constraint(equalTo: bottomView.leftAnchor).isActive = true
        numberLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 43).isActive = true
        
        daolodButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        daolodButton.rightAnchor.constraint(equalTo: bottomView.rightAnchor).isActive = true
        daolodButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        daolodButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -10).isActive = true
        
        loadingView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: bottomView.rightAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        NotificationCenter.default.addObserver(forName: .updateState, object: nil, queue: .main) { [weak self] sender in
            if let tr = sender.object as? TrackObject, tr.trackId == self?.track.trackId {
                self?.updateState(tr)
            }
        }
    }
    
    private func updateState(_ track: TrackObject) {
        switch DaoladService.shared.getState(track) {
        case .response:
            daolodButton.isHidden = false
            daolodButton.isSelected = true
            loadingView.isHidden = true
            loadingView.stopAnimating()
        case .inqueue:
            daolodButton.isHidden = true
            daolodButton.isSelected = false
            loadingView.isHidden = false
            loadingView.startAnimating()
        case .none:
            daolodButton.isHidden = false
            daolodButton.isSelected = false
            loadingView.isHidden = true
            loadingView.stopAnimating()
        }
    }
    
    // MARK: - public
    override var tag: Int {
        didSet {
            numberLabel.text = tag < 10 ? "0\(tag)" : "\(tag)"
            numberLabel.addTextOutline(usingColor: UIColor(rgb: 0x00D1EE), outlineWidth: 1.0)
        }
    }
    
    var track: TrackObject! {
        didSet {
            titleLabel.text = track.title
            subtitleLabel.text = track.subtitle
            daolodButton.isSelected = track.type == .offline
            imageView.sd_setImage(with: track.thumbnailURL, placeholderImage: Thumbnail.mainplayer)
            updateState(track)
        }
    }
    
    var onPlay: ((TrackObject) -> Void)?
    var onDaolod: ((TrackObject) -> Void)?
    
    // MARK: - event
    @objc func playClick() {
        onPlay?(track)
    }
    
    @objc func daolodClick() {
        if track == nil { return }
        if DaoladService.shared.getState(track) != .none { return }
        
        onDaolod?(track)
    }
}
