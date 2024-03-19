import UIKit

class NewestDetailTrackItemCell: BaseTableCell {
    
    static var height: CGFloat {
        return 72 + 16
    }
    
    var onDaolod: ((TrackObject) -> Void)?
    var onOption: ((TrackObject) -> Void)?
    var track: TrackObject? {
        didSet {
            guard let track = track else { return }
            
            titleLabel.text = track.title
            subtitleLabel.text = track.subtitle
            imageTrackView.sd_setImage(with: track.thumbnailURL, placeholderImage: Thumbnail.track)
            updateState(track)
        }
    }
    
    // MARK: - properties
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let imageTrackView: UIImageView = {
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
    
    fileprivate let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let view = UIActivityIndicatorView(style: .medium)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.color = .white
            return view
        }
        else {
            let view = UIActivityIndicatorView(style: .white)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
    }()
    
    // MARK: - initial
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    // MARK: - private
    private func drawUIs() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(imageTrackView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(daolodButton)
        containerView.addSubview(loadingView)
        containerView.addSubview(optionButton)
        
        daolodButton.addTarget(self, action: #selector(daolodClick), for: .touchUpInside)
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        
        containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15).isActive = true
        containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -15).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        imageTrackView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        imageTrackView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageTrackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        imageTrackView.widthAnchor.constraint(equalTo: imageTrackView.heightAnchor, multiplier: 1).isActive = true
        
        optionButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        optionButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        optionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        daolodButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        daolodButton.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -10).isActive = true
        daolodButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        daolodButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        loadingView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: optionButton.leftAnchor, constant: -10).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: imageTrackView.rightAnchor, constant: 10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo: imageTrackView.rightAnchor, constant: 10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        NotificationCenter.default.addObserver(forName: .updateState, object: nil, queue: .main) { [weak self] sender in
            if let tr = sender.object as? TrackObject, tr.trackId == self?.track?.trackId {
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
    
    // MARK: - event
    @objc func optionClick() {
        if let tr = track {
            onOption?(tr)
        }
    }
    
    @objc func daolodClick() {
        if track == nil { return }
        if DaoladService.shared.getState(track!) != .none { return }
        
        onDaolod?(track!)
    }
}
