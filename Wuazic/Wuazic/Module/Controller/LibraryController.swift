import UIKit

enum TabEnum {
    case tracks, playlist, offline, favourite, artist
    
    func title() -> String {
        switch self {
        case .tracks: return "Tracks"
        case .playlist: return "Playlist"
        case .offline: return "Offline"
        case .favourite: return "Favourite"
        case .artist: return "Artist"
        }
    }
}

class LibraryController: BaseController {
    
    fileprivate var heightPlayerMini: CGFloat = 0
    
    // MARK: - property
    fileprivate let tabs: [TabEnum] = [.playlist, .artist, .offline, .favourite]
    fileprivate var selectedIndex: Int = 0
    
    fileprivate let bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "bg-library"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let titleHeaderLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.text = "Your Library"
        view.font = UIFont.gilroyBold(of: 30)
        return view
    }()
    
    fileprivate let lineRedView: UIView = {
        let view = UIView(frame: .init(x: kPadding, y: 38, width: 52.33, height: 2))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x00D1EE)
        return view
    }()
    
    fileprivate let tabCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: TabItemCell.self)
        return view
    }()
    
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.registerItem(cell: PlaylistCell.self)
        view.registerItem(cell: LibraryArtistCell.self)
        view.registerItem(cell: TrackCell.self)
        return view
    }()
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
        
        // Do any additional setup after loading the view.
        view.addSubview(bgImageView)
        view.addSubview(titleHeaderLabel)
        view.addSubview(tabCollectionView)
        view.addSubview(listCollectionView)
        
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionView.addSubview(lineRedView)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        bgImageView.layoutEdges()
        
        titleHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleHeaderLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: kPadding).isActive = true
        titleHeaderLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -kPadding).isActive = true
        titleHeaderLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        tabCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tabCollectionView.topAnchor.constraint(equalTo: titleHeaderLabel.bottomAnchor, constant: 0).isActive = true
        tabCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tabCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        listCollectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        listCollectionView.topAnchor.constraint(equalTo: tabCollectionView.bottomAnchor, constant: 10).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tabCollectionView.reloadData()
        listCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.animateTabSelected()
        })
        
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listCollectionView.reloadData()
    }
    
    // MARK: - private
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .willShowPlayerMini, object: nil, queue: .main) { [weak self] sender in
            self?.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .didHidePlayerMini, object: nil, queue: .main) { [weak self] sender in
            self?.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .databaseChanged, object: nil, queue: .main) { [weak self] sender in
            self?.listCollectionView.reloadData()
        }
    }
    
    fileprivate func animateTabSelected(_ animated: Bool = true) {
        var cells: [TabItemCell] = []
        for c in tabCollectionView.subviews {
            if let tab = c as? TabItemCell {
                cells.append(tab)
            }
        }
        
        if selectedIndex >= 0 && selectedIndex < cells.count {
            let cell = cells[selectedIndex]
            let newFrame = CGRect(x: cell.origin.x, y: tabCollectionView.size.height - 2, width: cell.size.width, height: 2)
            UIView.animate(withDuration: animated ? 0.2 : 0) {
                self.lineRedView.frame = newFrame
            }
        }
    }
    
    fileprivate func createPlaylist(_ p: PlaylistObject? = nil) {
        let makePlaylist = CreatePlaylistView()
        makePlaylist.onCreated = { [weak self] _ in
            self?.listCollectionView.reloadData()
        }
        makePlaylist.onUpdated = { [weak self] _ in
            self?.listCollectionView.reloadData()
        }
        makePlaylist.playlist = p   // for rename
        makePlaylist.show()
    }
    
    fileprivate func playlistDetail(_ p: PlaylistObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            if p.type == .manually {
                let detail = PlaylistDetailController()
                detail.id = p.id
                self.navigationController?.pushViewController(detail, animated: true)
            }
            else {
                let detail = PlaylistOnlDetailController()
                detail.playlist = p
                detail.autoBackWhenDeletePlaylist = true
                self.navigationController?.pushViewController(detail, animated: true)
            }
        }
    }
    
    fileprivate func artistDetail(_ artist: ArtistObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let detail = ArtistDetailController()
            detail.autoBackWhenDeletePlaylist = true
            detail.artist = artist
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    fileprivate func addOrRemoveFavourite(_ playlist: PlaylistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if let plNeedRemove = DBService.shared.findPlaylistOnDb(playlist.playlistId) {
            try? realm.write({
                realm.delete(plNeedRemove)
                
                self.navigationController?.popViewController(animated: true)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted the playlist")
            })
        }
        else {
            let plAdd = PlaylistObject()
            plAdd.title = playlist.title
            plAdd.artist = playlist.artist
            plAdd.playlistThumbnailUrl = playlist.playlistThumbnailUrl
            plAdd.playlistId = playlist.playlistId
            
            try? realm.write({
                realm.add(plAdd)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added the playlist")
            })
        }
    }
    
    fileprivate func delete(_ p: PlaylistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        try? realm.write({
            realm.delete(p)
            self.listCollectionView.reloadData()
            SwiftMessagesHelper.shared.showSuccess(title: "Notification", body: "Deleted the playlist")
        })
    }
    
    fileprivate func openFavouriteTrackOption(_ track: TrackObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.openTrackOption(track, style: .style2)
        }
    }
    
    fileprivate func openPlaylistOption(_ playlist: PlaylistObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let optionView = PlaylistOptionView()
            optionView.playlist = playlist
            optionView.options = playlist.type == .online ? [.favourite, .share] : [.addTrack, .rename, .delete]
            optionView.onSelected = { [weak self] op in
                switch op {
                case .addTrack:
                    let addTrack = AddTrackController()
                    addTrack.id = playlist.id
                    addTrack.modalPresentationStyle = .fullScreen
                    self?.present(addTrack, animated: true)
                    
                case .rename:
                    self?.createPlaylist(playlist)
                    
                case .delete:
                    self?.delete(playlist)
                    
                case .favourite:
                    self?.addOrRemoveFavourite(playlist)
                    
                case .share:
                    self?.sharePlaylistForFriends(playlist)
                }
            }
            optionView.show()
        }
    }
    
    fileprivate func openArtistOption(_ ar: ArtistObject) {
        let optionView = ArtistOptionView()
        optionView.artist = ar
        optionView.onSelected = { [weak self] op in
            switch op {
            case .favourite:
                guard let realm = DBService.shared.realm else { return }
                
                if let arNeedRemove = DBService.shared.findArtistOnDb(ar.browseId) {
                    try? realm.write({
                        realm.delete(arNeedRemove)
                        
                        self?.navigationController?.popViewController(animated: true)
                        
                        NotificationCenter.default.post(name: .databaseChanged, object: nil)
                        
                        SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted the artist")
                    })
                }
                else {
                    let arAdd = ArtistObject()
                    arAdd.title = ar.title
                    arAdd.subscribers = ar.subscribers
                    arAdd.browseId = ar.browseId
                    arAdd.image = ar.image
                    
                    try? realm.write({
                        realm.add(arAdd)
                        
                        NotificationCenter.default.post(name: .databaseChanged, object: nil)
                        
                        SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added the artist")
                    })
                }
                
            case .share:
                self?.shareArtistForFriends(ar)
            }
        }
        optionView.show()
    }
    
    // MARK: - public
    // MARK: - event
    
}

extension LibraryController: UICollectionViewDelegate, UICollectionViewDataSource {
    func presentTrackOption(_ track: TrackObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.openTrackOption(track, style: .style1)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tabCollectionView {
            let cell: TabItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.setTab(tabs[indexPath.row], tabSelected: tabs[selectedIndex])
            return cell
        }
        else {
            switch tabs[indexPath.row] {
            case .tracks:
                let cell: TrackCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.loadTracks()
                cell.heightPlayerMini = heightPlayerMini
                cell.onSelected = { track, tracks in
                    UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
                }
                cell.onOption = { [weak self] track in
                    self?.presentTrackOption(track)
                }
                return cell
            case .playlist:
                let cell: PlaylistCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.loadPlaylists()
                cell.heightPlayerMini = heightPlayerMini
                cell.onCreatePlaylist = { [weak self] in
                    self?.createPlaylist()
                }
                cell.onSelected = { [weak self] playlist in
                    self?.playlistDetail(playlist)
                }
                cell.onOption = { [weak self] playlist in
                    self?.openPlaylistOption(playlist)
                }
                return cell
            case .artist:
                let cell: LibraryArtistCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.loadArtists()
                cell.heightPlayerMini = heightPlayerMini
                cell.onSelected = { [weak self] artist in
                    self?.artistDetail(artist)
                }
                cell.onOption = { [weak self] artist in
                    self?.openArtistOption(artist)
                }
                return cell
            case .offline:
                let cell: TrackCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.loadOfflineTracks()
                cell.heightPlayerMini = heightPlayerMini
                cell.onSelected = { track, tracks in
                    UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
                }
                cell.onOption = { [weak self] track in
                    self?.presentTrackOption(track)
                }
                return cell
            case .favourite:
                let cell: TrackCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.loadFavouriteTracks()
                cell.heightPlayerMini = heightPlayerMini
                cell.onSelected = { track, tracks in
                    UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
                }
                cell.onOption = { [weak self] track in
                    self?.openFavouriteTrackOption(track)
                }
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tabCollectionView {
            selectedIndex = indexPath.row
            tabCollectionView.reloadData()
            listCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            animateTabSelected()
        }
        else {
            
        }
    }
}

extension LibraryController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == tabCollectionView {
            return .init(top: 0, left: kPadding, bottom: 0, right: kPadding)
        }
        else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == tabCollectionView ? 0 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == tabCollectionView ? 20 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tabCollectionView {
            return TabItemCell.textSize(text: tabs[indexPath.row].title(), height: collectionView.size.height)
        }
        else {
            return collectionView.size
        }
    }
}

extension LibraryController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tabCollectionView {
            // don't nothing
        }
        else if scrollView == listCollectionView {
            let currentPage = Int(scrollView.contentOffset.x / scrollView.size.width)
            self.selectedIndex = currentPage
            self.tabCollectionView.reloadData()
            self.animateTabSelected()
        }
    }
}
