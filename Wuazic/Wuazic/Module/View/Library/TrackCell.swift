import UIKit

class TrackCell: BaseCollectionCell {
    
    var heightPlayerMini: CGFloat = 0 {
        didSet { listCollectionView.reloadData() }
    }
    var tracks: [TrackObject] = []
    var onSelected: ((TrackObject, [TrackObject]) -> Void)?
    var onOption: ((TrackObject) -> Void)?
    
    // MARK: - properties
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: TrackItemCell.self)
        view.registerItem(cell: LibraryNoDataCell.self)
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
    func loadTracks() {
        guard let realm = DBService.shared.realm else { return }
        
        self.tracks = realm.objects(TrackObject.self).toArray()
        self.listCollectionView.reloadData()
    }
    
    func loadOfflineTracks() {
        guard let realm = DBService.shared.realm else { return }
        
        self.tracks = realm.objects(TrackObject.self).toArray().filter({ $0.type == .offline })
        self.listCollectionView.reloadData()
    }
    
    func loadFavouriteTracks() {
        guard let realm = DBService.shared.realm else { return }
        
        self.tracks = realm.objects(TrackFavouriteObject.self).toArray().map({ $0.toTrack() })
        self.listCollectionView.reloadData()
    }
    
    // MARK: - event
    
}

extension TrackCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count == 0 ? 1 : tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if tracks.count == 0 {
            let cell: LibraryNoDataCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        }
        else {
            let cell: TrackItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.track = tracks[indexPath.row]
            cell.onOption = onOption
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tracks.count > 0 {
            onSelected?(tracks[indexPath.row], tracks)
        }
    }
}

extension TrackCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 5, left: kPadding, bottom: self.heightPlayerMini, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if tracks.count == 0 {
            return .init(width: collectionView.size.width - 2 * kPadding, height: collectionView.size.height)
        }
        return TrackItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
