import UIKit

class ArtistDetailVideoCell: BaseTableCell {
    
    static var height: CGFloat {
        return 160
    }
    
    var onPlay: ((TrackObject, [TrackObject]) -> Void)?
    var data: [TrackObject] = [] {
        didSet {
            listCollectionView.reloadData()
        }
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
        view.registerItem(cell: ArtistDetailVideoItemCell.self)
        return view
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
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        contentView.addSubview(listCollectionView)
        
        listCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        listCollectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    
}

extension ArtistDetailVideoCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ArtistDetailVideoItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.track = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPlay?(data[indexPath.row], data)
    }
}

extension ArtistDetailVideoCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ArtistDetailVideoItemCell.size(width: 0)
    }
}
