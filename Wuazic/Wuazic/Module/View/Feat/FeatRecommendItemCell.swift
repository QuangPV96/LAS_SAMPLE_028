import UIKit

class FeatRecommendItemCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 0.7 * width)
    }
    
    // MARK: - properties
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: Thumbnail.playlist)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.backgroundColor = .init(rgb: 0x3E3F40)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroySemiBold(of: 16)
        view.textColor = .white
        view.numberOfLines = 2
        return view
    }()
    
    fileprivate let subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyMedium(of: 13)
        view.textColor = .init(rgb: 0x747474)
        return view
    }()
    
    fileprivate let timeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.font = UIFont.gilroyMedium(of: 13)
        view.textColor = .white
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let daolodButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-donwlaod"), for: .normal)
        view.setImage(UIImage(imgName: "ic-donwlaod-active"), for: .selected)
        return view
    }()
    
    fileprivate let optionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-option"), for: .normal)
        return view
    }()
    
    fileprivate let playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-trend-play"), for: .normal)
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
        
        daolodButton.addTarget(self, action: #selector(daolodClick), for: .touchUpInside)
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        
        imageView.addSubview(timeLabel)
        imageView.addSubview(playButton)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(daolodButton)
        contentView.addSubview(loadingView)
        contentView.addSubview(optionButton)
        
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5).isActive = true
        
        playButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -5).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        optionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        optionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        optionButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        daolodButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        daolodButton.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -5).isActive = true
        daolodButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        daolodButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        loadingView.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -5).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        subtitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
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
    var track: TrackObject! {
        didSet {
            titleLabel.text = track.title
            subtitleLabel.text = track.subtitle
            timeLabel.text = track.time
            daolodButton.isSelected = track.type == .offline
            imageView.sd_setImage(with: track.thumbnailMaxResURL, placeholderImage: Thumbnail.track)
            updateState(track)
        }
    }
    
    var onDaolod: ((TrackObject) -> Void)?
    var onOption: ((TrackObject) -> Void)?
    var onPlay: ((TrackObject) -> Void)?
    
    // MARK: - event
    @objc func daolodClick() {
        if track == nil { return }
        if DaoladService.shared.getState(track) != .none { return }
        
        onDaolod?(track)
    }
    
    @objc func optionClick() {
        onOption?(track)
    }
    
    @objc func playClick() {
        onPlay?(track)
    }
    
}
