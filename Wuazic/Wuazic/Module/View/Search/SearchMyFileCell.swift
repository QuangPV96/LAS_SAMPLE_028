//
//  SearchMyFileCell.swift
//  SwiftyAds
//
//  Created by MinhNH on 11/04/2023.
//

import UIKit

class SearchMyFileCell: BaseCollectionCell {
    
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
        view.registerItem(cell: SearchTrackItemCell.self)
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
        
        NotificationCenter.default.addObserver(forName: .searchClearData, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            
            self.tracks.removeAll()
            self.listCollectionView.reloadData()
        }
    }
    
    // MARK: - public
    // MARK: - event
    
}

extension SearchMyFileCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SearchTrackItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.track = tracks[indexPath.row]
        cell.onOption = onOption
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelected?(tracks[indexPath.row], tracks)
    }
}

extension SearchMyFileCell: UICollectionViewDelegateFlowLayout {
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
        return SearchTrackItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
