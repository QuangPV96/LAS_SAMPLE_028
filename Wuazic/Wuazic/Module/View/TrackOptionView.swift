//
//  TrackOptionView.swift
//  SwiftyAds
//
//  Created by MinhNH on 11/04/2023.
//

import UIKit
import SDWebImage

enum TrackOption {
    case donwlaod, favourite, addToPlaylist, share, delete, deleteFromPlaylist
    
    func info() -> (String, String, String) {
        switch self {
        case .donwlaod: return ("ic-donwlaod", "ic-donwlaod-active", "Download")
        case .favourite: return ("ic-like", "ic-liked", "Favourite")
        case .addToPlaylist: return ("ic-addtoplaylist", "", "Add to playlist")
        case .share: return ("ic-share", "", "Share track with friends")
        case .delete: return ("ic-delete-from-playlist", "", "Delete track")
        case .deleteFromPlaylist: return ("ic-delete-from-playlist", "", "Delete from playlist")
        }
    }
}

enum TrackStyle {
    /// style has delete track
    case style1
    /// style has delete from playlist, delete track
    case style2
    /// style hasn't delete
    case style3
    
    func options() -> [TrackOption] {
        switch self {
        case .style1:
            return [.donwlaod, .favourite, .addToPlaylist, .share, .delete]
        case .style2:
            return [.donwlaod, .favourite, .addToPlaylist, .share, .deleteFromPlaylist, .delete]
        case .style3:
            return [.donwlaod, .favourite, .addToPlaylist, .share]
        }
    }
}

class TrackOptionView: BaseView {
    
    var style: TrackStyle = .style1
    var options: [TrackOption] {
        var op = style.options()
        if let tr = self.track, DaoladService.shared.getState(tr) != .none {
            op.removeAll(where: { $0 == .donwlaod })
        }
        return op
    }
    
    let heightItem: CGFloat = 60
    
    var onSelected: ((TrackOption) -> Void)?
    var track: TrackObject? {
        didSet {
            titleTrackLabel.text = track?.title
            imageView.sd_setImage(with: track?.thumbnailURL, placeholderImage: Thumbnail.track)
        }
    }
    
    // MARK: - properties
    fileprivate var heightTableConstraint: NSLayoutConstraint?
    
    fileprivate let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    fileprivate let imageView: UIImageView = {
        let view = UIImageView(image: Thumbnail.track)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let titleTrackLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 18)
        view.numberOfLines = 2
        return view
    }()
    
    fileprivate let closeButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("CLOSE", for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.setTitleColor(UIColor(rgb: 0x00D1EE), for: .highlighted)
        view.setTitleColor(UIColor(rgb: 0x00D1EE), for: .selected)
        view.titleLabel?.font = UIFont.gilroyBold(of: 18)
        return view
    }()
    
    fileprivate let lineCloseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate let listTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.registerItem(cell: OptionItemTableCell.self)
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
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        
        addSubview(blurEffectView)
        addSubview(imageView)
        addSubview(titleTrackLabel)
        addSubview(lineCloseView)
        addSubview(closeButton)
        addSubview(listTableView)
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        
        blurEffectView.layoutEdges()
        
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 140).isActive = true
        
        titleTrackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        titleTrackLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleTrackLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        titleTrackLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        listTableView.topAnchor.constraint(equalTo: titleTrackLabel.bottomAnchor, constant: 32).isActive = true
        listTableView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        listTableView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        heightTableConstraint = listTableView.heightAnchor.constraint(equalToConstant: heightItem * CGFloat(options.count))
        heightTableConstraint?.isActive = true
        
        closeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lineCloseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lineCloseView.widthAnchor.constraint(equalTo: closeButton.widthAnchor).isActive = true
        lineCloseView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        lineCloseView.bottomAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: -2).isActive = true
    }
    
    // MARK: - public
    func show() {
        guard let kWindow = UIWindow.keyWindow else { return }
        
        kWindow.addSubview(self)
        self.alpha = 0
        self.frame = kWindow.bounds
        self.listTableView.reloadData()
        self.heightTableConstraint?.constant = heightItem * CGFloat(options.count)
        
        // animate
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { _ in
            
        }
    }
    
    func close() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - event
    
    @objc func closeClick() {
        close()
    }
    
}

extension TrackOptionView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = options[indexPath.row].info()
        let cell: OptionItemTableCell = tableView.dequeueReusableCell()
        cell.titleLabel.text = data.2
        cell.iconImage.image = UIImage(imgName: data.0)
        
        if options[indexPath.row] == .favourite, let tr = track,
           let _ = DBService.shared.realm?.objects(TrackFavouriteObject.self).first(where: { $0.trackId == tr.trackId })
        {
            cell.iconImage.image = UIImage(imgName: data.1)
        }
        else {
            cell.iconImage.image = UIImage(imgName: data.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        onSelected?(options[indexPath.row])
        close()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightItem
    }
}
