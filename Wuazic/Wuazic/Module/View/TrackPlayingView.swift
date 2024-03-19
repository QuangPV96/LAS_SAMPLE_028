import UIKit

class TrackPlayingView: BaseView {
    
    var onSelected: ((TrackObject) -> Void)?
    var track: TrackObject? {
        didSet { listCollectionView.reloadData() }
    }
    var tracks: [TrackObject] = [] {
        didSet { listCollectionView.reloadData() }
    }
    
    fileprivate let height: CGFloat = 600
    
    // MARK: - properties
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x242526)
        return view
    }()
    
    fileprivate let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x1B1C1D)
        return view
    }()
    
    fileprivate let lineHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x00D1EE)
        return view
    }()
    
    fileprivate let titleHeader: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Next tracks"
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 18)
        return view
    }()
    
    fileprivate let closeButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Close", for: .normal)
        view.setTitleColor(UIColor(rgb: 0x00D1EE), for: .normal)
        view.titleLabel?.font = UIFont.gilroyMedium(of: 16)
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
        view.registerItem(cell: TrackPlayingItemCell.self)
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
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        headerView.addSubview(titleHeader)
        headerView.addSubview(closeButton)
        headerView.addSubview(lineHeaderView)
        
        addSubview(containerView)
        addSubview(headerView)
        addSubview(listCollectionView)
        
        containerView.layoutEdges()
        
        headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 63).isActive = true
        
        listCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        listCollectionView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        titleHeader.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        titleHeader.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        titleHeader.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -20).isActive = true
        titleHeader.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        lineHeaderView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -1).isActive = true
        lineHeaderView.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        lineHeaderView.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        lineHeaderView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    private func scrollToItemActive() {
        // scroll to item playing
        if let tr = track, let i = tracks.firstIndex(where: { $0.trackId == tr.trackId }) {
            listCollectionView.scrollToItem(at: IndexPath(row: i, section: 0), at: .centeredVertically, animated: true)
        }
    }
    
    // MARK: - public
    func show() {
        guard let kWindow = UIWindow.keyWindow else { return }
        
        if let i = tracks.firstIndex(where: { $0.id == track?.id }) {
            titleHeader.text = "Next tracks (\(i+1)/\(tracks.count))"
        }
        
        listCollectionView.reloadData()
        
        let paView = UIView(frame: kWindow.bounds)
        paView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        paView.alpha = 0
        paView.addSubview(self)
        kWindow.addSubview(paView)
        
        // update frame
        self.frame = CGRect(x: 0, y: kWindow.size.height, width: kWindow.size.width, height: self.height)
        
        // animate
        UIView.animate(withDuration: 0.3) {
            paView.alpha = 1
            self.frame = CGRect(x: 0, y: kWindow.size.height - self.height, width: kWindow.size.width, height: self.height)
        } completion: { _ in
            self.scrollToItemActive()
        }
    }
    
    func close() {
        guard let paView = self.superview else { return }
        
        UIView.animate(withDuration: 0.3) {
            paView.alpha = 0
            self.frame = CGRect(x: 0, y: paView.size.height, width: paView.size.width, height: self.height)
        } completion: { _ in
            self.removeFromSuperview()
            paView.removeFromSuperview()
        }
    }
    
    // MARK: - event
    
    @objc func closeClick() {
        close()
    }
}

extension TrackPlayingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let playinsg = tracks[indexPath.row].trackId == track?.trackId
        let cell: TrackPlayingItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.track = tracks[indexPath.row]
        cell.setState(with: playinsg)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        close()
        onSelected?(tracks[indexPath.row])
    }
}

extension TrackPlayingView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: kPadding, left: kPadding, bottom: 0, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TrackPlayingItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
