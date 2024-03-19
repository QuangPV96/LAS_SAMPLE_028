import UIKit
import RealmSwift

class PlaylistCell: BaseCollectionCell {
    
    fileprivate var playlists: [PlaylistObject] = []
    var onCreatePlaylist: (() -> Void)?
    var onSelected: ((PlaylistObject) -> Void)?
    var onOption: ((PlaylistObject) -> Void)?
    var heightPlayerMini: CGFloat = 0 {
        didSet { listCollectionView.reloadData() }
    }
    
    // MARK: - properties
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: CreatePlaylistCell.self)
        view.registerItem(cell: PlaylistItemCell.self)
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
        contentView.addSubview(listCollectionView)
        
        listCollectionView.layoutEdges()
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
    }
    
    // MARK: - public
    func loadPlaylists() {
        guard let realm = DBService.shared.realm else { return }
        
        self.playlists = realm.objects(PlaylistObject.self).toArray()
        self.listCollectionView.reloadData()
    }
    
    // MARK: - event
    
}

extension PlaylistCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell: CreatePlaylistCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        }
        else {
            let cell: PlaylistItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.playlist = playlists[indexPath.row]
            cell.onOption = onOption
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            onCreatePlaylist?()
        }
        else {
            onSelected?(playlists[indexPath.row])
        }
    }
}

extension PlaylistCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .init(top: 5, left: kPadding, bottom: kPadding, right: kPadding)
        }
        return .init(top: 0, left: kPadding, bottom: self.heightPlayerMini, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CreatePlaylistCell.size(width: collectionView.size.width - 2 * kPadding)
        }
        else {
            return PlaylistItemCell.size(width: collectionView.size.width - 2 * kPadding)
        }
    }
}
