import UIKit

class SearchArtistCell: BaseCollectionCell {
    
    private var _heightPlayerMini: CGFloat = 0
    var heightPlayerMini: CGFloat {
        set {
            if _heightPlayerMini != newValue {
                listCollectionView.cr.endLoadingMore()
                listCollectionView.reloadData()
            }
            _heightPlayerMini = newValue
        }
        get {
            return _heightPlayerMini
        }
    }
    
    private var _artists: [ArtistObject] = []
    var artists: [ArtistObject] {
        set {
            if _artists.count != newValue.count {
                listCollectionView.cr.endLoadingMore()
                listCollectionView.reloadData()
            }
            _artists = newValue
        }
        get {
            return _artists
        }
    }
    
    var onSelected: ((ArtistObject) -> Void)?
    var onOption: ((ArtistObject) -> Void)?
    var onLoadMore: (() -> Void)?
    
    // MARK: - properties
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: SearchArtistItemCell.self)
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
        contentView.addSubview(listCollectionView)
        
        listCollectionView.layoutEdges()
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        listCollectionView.cr.addFootRefresh { [weak self] in
            guard let self = self else { return }
            
            self.onLoadMore?()
        }
        
        NotificationCenter.default.addObserver(forName: .searchClearData, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            
            self.artists.removeAll()
        }
    }
    
    // MARK: - public
    
    // MARK: - event
    
}

extension SearchArtistCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SearchArtistItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.artist = artists[indexPath.row]
        cell.onOption = onOption
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelected?(artists[indexPath.row])
    }
}

extension SearchArtistCell: UICollectionViewDelegateFlowLayout {
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
        return SearchArtistItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
