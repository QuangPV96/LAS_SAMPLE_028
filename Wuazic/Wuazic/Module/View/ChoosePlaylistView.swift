import UIKit
import RealmSwift

class ChoosePlaylistView: BaseView {
    
    fileprivate var playlists: [PlaylistObject] = []
    private let height: CGFloat = 600
    
    var onSelected: ((PlaylistObject) -> Void)?
    var onCreateNew: (() -> Void)?
    
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
        view.text = "Add to playlist"
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
    
    fileprivate let createNewButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-create-new-pl"), for: .normal)
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
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        headerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        createNewButton.addTarget(self, action: #selector(createNewClick), for: .touchUpInside)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        headerView.addSubview(titleHeader)
        headerView.addSubview(closeButton)
        headerView.addSubview(lineHeaderView)
        
        addSubview(containerView)
        addSubview(headerView)
        addSubview(createNewButton)
        addSubview(listCollectionView)
        
        containerView.layoutEdges()
        
        headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 63).isActive = true
        
        createNewButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        createNewButton.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 15).isActive = true
        createNewButton.widthAnchor.constraint(equalToConstant: 223).isActive = true
        createNewButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        listCollectionView.topAnchor.constraint(equalTo: createNewButton.bottomAnchor, constant: 15).isActive = true
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
    
    private func loadPlaylists() {
        guard let realm = DBService.shared.realm else { return }
        
        self.playlists = realm.objects(PlaylistObject.self).toArray().filter({ $0.playlistId == nil })
        self.listCollectionView.reloadData()
    }
    
    // MARK: - public
    func show() {
        guard let kWindow = UIWindow.keyWindow else { return }
        
        self.loadPlaylists()
        
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
    
    @objc func createNewClick() {
        onCreateNew?()
        close()
    }
}

extension ChoosePlaylistView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PlaylistItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.playlist = playlists[indexPath.row]
        cell.onOption = nil
        cell.disableButtonOption()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelected?(playlists[indexPath.row])
        close()
    }
}

extension ChoosePlaylistView: UICollectionViewDelegateFlowLayout {
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
        return PlaylistItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
