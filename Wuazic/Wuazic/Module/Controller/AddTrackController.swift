//
//  AddTrackController.swift
//  SwiftyAds
//
//  Created by MinhNH on 22/04/2023.
//

import UIKit

class AddTrackController: BaseController {
    
    var id: String = ""
    
    fileprivate var tracks: [TrackObject] = []
    fileprivate var tracksSelected: [TrackObject] = []
    
    // MARK: - property
    fileprivate let bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "bg-playlist-detail"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.text = ""
        view.font = UIFont.gilroyBold(of: 18)
        return view
    }()
    
    fileprivate let backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-back"), for: .normal)
        return view
    }()
    
    fileprivate let saveButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Save", for: .normal)
        view.setTitleColor(UIColor(rgb: 0x00D1EE), for: .normal)
        view.titleLabel?.font = UIFont.gilroyMedium(of: 16)
        return view
    }()
    
    fileprivate let selectAllButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Select All", for: .normal)
        view.setTitle("Unselect All", for: .selected)
        view.setTitleColor(UIColor(rgb: 0x00D1EE), for: .normal)
        view.titleLabel?.font = UIFont.gilroyMedium(of: 16)
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor(rgb: 0x00D1EE).cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: AddTrackItemCell.self)
        return view
    }()
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUIs()
        reloadData()
    }
    
    // MARK: - private
    private func setupUIs() {
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveClick), for: .touchUpInside)
        selectAllButton.addTarget(self, action: #selector(selectAllClick), for: .touchUpInside)
        
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(saveButton)
        
        view.addSubview(bgImageView)
        view.addSubview(headerView)
        view.addSubview(listCollectionView)
        view.addSubview(selectAllButton)
        
        bgImageView.layoutEdges()
        
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1).isActive = true
        
        saveButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: backButton.rightAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: saveButton.leftAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        listCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        listCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: selectAllButton.topAnchor, constant: -10).isActive = true
        
        selectAllButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        selectAllButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        selectAllButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func reloadData() {
        guard let realm = DBService.shared.realm,
              let playlistUpdate = realm.objects(PlaylistObject.self).first(where: { $0.id == self.id })
        else {
            return
        }
        
        self.titleLabel.text = "Added tracks to playlist"
        
        let tracksInPlaylist = Array(playlistUpdate.tracks).map({ $0.id })
        self.tracks = realm.objects(TrackObject.self).filter { track in
            return tracksInPlaylist.contains(track.id) == false
        }
        self.listCollectionView.reloadData()
    }
    
    fileprivate func check(_ track: TrackObject) {
        if let i = tracksSelected.firstIndex(where: { tr in return tr.trackId == track.trackId }) {
            tracksSelected.remove(at: i)
        }
        else {
            tracksSelected.append(track)
        }
        
        if self.tracksSelected.count != self.tracks.count {
            self.selectAllButton.setTitle("Select All", for: .normal)
        }
        else {
            self.selectAllButton.setTitle("Unselect All", for: .normal)
        }
        
        listCollectionView.reloadData()
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func backClick() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.dismiss(animated: true)
        }
    }
    
    @objc func saveClick() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            if self.tracksSelected.isEmpty {
                SwiftMessagesHelper.shared.showWarning(title: "Warning", body: "You haven't selected any tracks yet")
                return
            }
            
            guard let realm = DBService.shared.realm,
                  let playlistUpdate = realm.objects(PlaylistObject.self).first(where: { $0.id == self.id })
            else {
                return
            }
            
            try? realm.write({
                playlistUpdate.tracks.append(objectsIn: self.tracksSelected)
            })
            
            NotificationCenter.default.post(name: .databaseChanged, object: nil)
            
            SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added tracks to playlist")
            
            dismiss(animated: true)
        }
    }
    
    @objc func selectAllClick() {
        if self.tracksSelected.count == self.tracks.count {
            // unselect all
            self.tracksSelected.removeAll()
            self.listCollectionView.reloadData()
            self.selectAllButton.setTitle("Select All", for: .normal)
        }
        else {
            // select all
            self.tracksSelected.removeAll()
            self.tracksSelected += self.tracks
            self.listCollectionView.reloadData()
            self.selectAllButton.setTitle("Unselect All", for: .normal)
        }
    }
    
}

extension AddTrackController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AddTrackItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.track = tracks[indexPath.row]
        cell.trackSelected = tracksSelected.contains(where: { track in
            return track.trackId == tracks[indexPath.row].trackId
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.check(tracks[indexPath.row])
    }
}

extension AddTrackController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: kPadding, bottom: 0, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = AddTrackItemCell.size(width: collectionView.size.width - 2 * kPadding)
        return size
    }
}


class AddTrackItemCell: BaseCollectionCell {
    
    var trackSelected: Bool = false {
        didSet {
            checkImage.image = trackSelected ? UIImage(imgName: "ic_check") : UIImage(imgName: "ic_uncheck")
        }
    }
    
    var track: TrackObject? {
        didSet {
            titleLabel.text = track?.title
            subtitleLabel.text = track?.subtitle
            imageView.sd_setImage(with: track?.thumbnailURL, placeholderImage: Thumbnail.track, context: nil)
        }
    }
    
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 72)
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
    
    fileprivate let checkImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
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
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(checkImage)
        
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        
        checkImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        checkImage.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        checkImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        titleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: checkImage.leftAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        subtitleLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: checkImage.leftAnchor, constant: -10).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    // MARK: - public
    // MARK: - event
    
}
