import UIKit

class LibraryArtistCell: BaseCollectionCell {
    
    fileprivate var artists: [ArtistObject] = []
    var onSelected: ((ArtistObject) -> Void)?
    var onOption: ((ArtistObject) -> Void)?
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
        view.registerItem(cell: LibraryArtistItemCell.self)
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
    func loadArtists() {
        guard let realm = DBService.shared.realm else { return }
        
        self.artists = realm.objects(ArtistObject.self).toArray()
        self.listCollectionView.reloadData()
    }
    
    // MARK: - event
    
}

extension LibraryArtistCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artists.count == 0 ? 1 : artists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if artists.count == 0 {
            let cell: LibraryNoDataCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        }
        else {
            let cell: LibraryArtistItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.artist = artists[indexPath.row]
            cell.onOption = onOption
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if artists.count > 0 {
            onSelected?(artists[indexPath.row])
        }
    }
}

extension LibraryArtistCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: kPadding, bottom: self.heightPlayerMini, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if artists.count == 0 {
            return .init(width: collectionView.size.width - 2 * kPadding, height: collectionView.size.height)
        }
        return LibraryArtistItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
