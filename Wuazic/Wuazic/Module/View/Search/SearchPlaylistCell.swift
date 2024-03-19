//
//  SearchPlaylistCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 11/04/2023.
//

import UIKit

class SearchPlaylistCell: BaseCollectionCell {
    
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
    
    private var _playlists: [PlaylistObject] = []
    var playlists: [PlaylistObject] {
        set {
            if _playlists.count != newValue.count {
                listCollectionView.cr.endLoadingMore()
                listCollectionView.reloadData()
            }
            _playlists = newValue
        }
        get {
            return _playlists
        }
    }
    
    var onSelected: ((PlaylistObject) -> Void)?
    var onOption: ((PlaylistObject) -> Void)?
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
        view.registerItem(cell: SearchPlaylistItemCell.self)
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
            
            self.playlists.removeAll()
        }
    }
    
    // MARK: - public
    
    // MARK: - event
    
}

extension SearchPlaylistCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pl = playlists[indexPath.row]
        let cell: SearchPlaylistItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.playlist = pl
        cell.onOption = onOption
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelected?(playlists[indexPath.row])
    }
}

extension SearchPlaylistCell: UICollectionViewDelegateFlowLayout {
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
        return SearchPlaylistItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
