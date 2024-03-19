import UIKit

class FeatRecommendCell: BaseCollectionCell {
    
    // MARK: - properties
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroyBold(of: 20)
        view.textColor = .white
        view.text = "Recommend For You"
        return view
    }()

    fileprivate let seeMoreButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("More", for: .normal)
        view.setTitleColor(.init(rgb: 0x00D1EE), for: .normal)
        view.titleLabel?.font = UIFont.gilroyMedium(of: 14)
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
        view.isScrollEnabled = false
        view.registerItem(cell: FeatRecommendItemCell.self)
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(seeMoreButton)
        contentView.addSubview(listCollectionView)
        
        seeMoreButton.addTarget(self, action: #selector(moreClick), for: .touchUpInside)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        //
        seeMoreButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        seeMoreButton.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        seeMoreButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        seeMoreButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: seeMoreButton.leftAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        listCollectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        listCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
    }
    
    // MARK: - public
    var data: [TrackObject] = [] {
        didSet { listCollectionView.reloadData() }
    }
    
    var onDaolod: ((TrackObject) -> Void)?
    var onOption: ((TrackObject) -> Void)?
    var onPlay: ((TrackObject) -> Void)?
    var onMore: (([TrackObject]) -> Void)?
    
    // MARK: - event
    @objc func moreClick() {
        onMore?(data)
    }
    
}

extension FeatRecommendCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(data.count, kMaxItemDisplay)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeatRecommendItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.track = data[indexPath.row]
        cell.onPlay = onPlay
        cell.onOption = onOption
        cell.onDaolod = onDaolod
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onPlay?(data[indexPath.row])
    }
    
}

extension FeatRecommendCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = FeatRecommendItemCell.size(width: collectionView.size.width)
        return size
    }
}
