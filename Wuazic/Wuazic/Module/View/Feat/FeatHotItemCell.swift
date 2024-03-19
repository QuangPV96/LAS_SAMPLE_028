import UIKit
import SDWebImage

class FeatHotItemCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 78)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(daolodButton)
        contentView.addSubview(optionButton)
        contentView.addSubview(loadingView)
        
        daolodButton.addTarget(self, action: #selector(daolodClick), for: .touchUpInside)
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 78).isActive = true
        
        optionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        optionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        optionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        daolodButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        daolodButton.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -5).isActive = true
        daolodButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        daolodButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        
        loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -5).isActive = true
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
    var track: TrackObject! {
        didSet {
            titleLabel.text = track.title
            subtitleLabel.text = track.subtitle
            daolodButton.isSelected = track.type == .offline
            imageView.sd_setImage(with: track.thumbnailURL, placeholderImage: Thumbnail.mainplayer)
            updateState(track)
        }
    }
    
    var onDaolod: ((TrackObject) -> Void)?
    var onOption: ((TrackObject) -> Void)?
    
    // MARK: - event
    @objc func daolodClick() {
        if track == nil { return }
        if DaoladService.shared.getState(track) != .none { return }
        
        onDaolod?(track)
    }
    
    @objc func optionClick() {
        onOption?(track)
    }
    
}
