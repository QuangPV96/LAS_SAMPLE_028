import UIKit

class FeatTrendCell: BaseCollectionCell {
    // MARK: - override from supper view
    override class func size(width: CGFloat = 0) -> CGSize {
        return .init(width: width, height: 242)
    }
    
    // MARK: - properties
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: FeatTrendItemCell.self)
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
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.reloadData()
        
        setupAnimateLoadingView()
    }
    
    // MARK: - public
    var data: [TrackObject] = [] {
        didSet {
            if data.count > 0 {
                loadingView.stopAnimating()
                loadingView.isHidden = true
                
                listCollectionView.reloadData()
            }
        }
    }
    
    var onPlay: ((TrackObject) -> Void)?
    var onDaolod: ((TrackObject) -> Void)?
    
    // MARK: - event
    
}

extension FeatTrendCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeatTrendItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.tag = indexPath.row + 1
        cell.track = data[indexPath.row]
        cell.onPlay = { [weak self] track in
            guard let self = self else { return }
            
            self.onPlay?(track)
        }
        cell.onDaolod = { [weak self] track in
            guard let self = self else { return }
            
            self.onDaolod?(track)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onPlay?(data[indexPath.row])
    }
    
}

extension FeatTrendCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FeatTrendItemCell.size(height: collectionView.size.height)
    }
}
