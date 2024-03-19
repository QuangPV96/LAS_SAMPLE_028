//
//  SearchController.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit

enum TabSearchEnum {
    case music, video, playlist, artist, album, myfile
    
    func title() -> String {
        switch self {
        case .music: return "Music"
        case .video: return "Video"
        case .playlist: return "Playlist"
        case .artist: return "Artist"
        case .album: return "Album"
        case .myfile: return "My file"
        }
    }
}

class SearchController: BaseController {
    
    fileprivate var heightPlayerMini: CGFloat = 0
    fileprivate let tabs: [TabSearchEnum] = [.music, .video, .artist, .playlist, .album]
    fileprivate var selectedIndex: Int = 0
    
    fileprivate var musicToken: String?
    fileprivate var musics: [TrackObject] = []
    fileprivate var musicCell: SearchMusicCell?
    
    fileprivate var videoToken: String?
    fileprivate var videos: [TrackObject] = []
    fileprivate var videoCell: SearchVideoCell?
    
    fileprivate var playlistToken: String?
    fileprivate var playlists: [PlaylistObject] = []
    fileprivate var playlistCell: SearchPlaylistCell?
    
    fileprivate var albumToken: String?
    fileprivate var albums: [PlaylistObject] = []
    fileprivate var albumCell: SearchAlbumCell?
    
    fileprivate var artistToken: String?
    fileprivate var artists: [ArtistObject] = []
    fileprivate var artistCell: SearchArtistCell?
    
    fileprivate var myfile: [TrackObject] = []
    
    fileprivate var terms: [String] = []
    fileprivate var keyboardShowing: Bool = false
    
    // MARK: - property
    fileprivate let bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "bg-search"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let titleHeaderLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.text = "Search"
        view.font = UIFont.gilroyBold(of: 30)
        return view
    }()
    
    fileprivate let searchContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let iconSearch: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "ic-search"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    fileprivate let searchTextField: MuTextField = {
        let view = MuTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroy(of: 16)
        view.textColor = .white
        view.clearButtonMode = .whileEditing
        view.returnKeyType = .search
        view.attributedPlaceholder = NSAttributedString(
            string: "Search here...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5),
                         NSAttributedString.Key.font: UIFont.gilroy(of: 16) as Any]
        )
        return view
    }()
    
    var heightNative : NSLayoutConstraint?

    fileprivate let searchResultContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let lineRedView: UIView = {
        let view = UIView(frame: .init(x: kPadding, y: 38, width: 46.6, height: 2))
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
        view.registerItem(cell: SearchMusicCell.self)
        view.registerItem(cell: SearchVideoCell.self)
        view.registerItem(cell: SearchPlaylistCell.self)
        view.registerItem(cell: SearchAlbumCell.self)
        view.registerItem(cell: SearchArtistCell.self)
        view.registerItem(cell: SearchMyFileCell.self)
        return view
    }()
    
    fileprivate let recentSearchContainerView: RecentSearchView = {
        let view = RecentSearchView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate var recentSearchBottomConstraint: NSLayoutConstraint?
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
        recentSearchContainerView.heightPlayerMini = heightPlayerMini
        
        // Do any additional setup after loading the view.
        setupUIs()
        setupAutolayouts()
        displaySearchContentLayout()
        setupObservers()
        setupRecentSearch()
        loadGenres()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !super.loadedNative {
            super.loadNativeAd {
                self.recentSearchContainerView.setAdView(admobAd: super.admobAd, applovinAdView: super.applovinAdView)
                self.listCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - private
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(forName: .willShowPlayerMini, object: nil, queue: .main) { [weak self] sender in
            self?.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.recentSearchContainerView.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .didHidePlayerMini, object: nil, queue: .main) { [weak self] sender in
            self?.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.recentSearchContainerView.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .databaseChanged, object: nil, queue: .main) { [weak self] sender in
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .isConnected, object: nil, queue: .main) { [weak self] sender in
            if (self?.recentSearchContainerView.genres ?? []).isEmpty {
                self?.loadGenres()
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    fileprivate func setupUIs() {
        view.addSubview(bgImageView)
        view.addSubview(titleHeaderLabel)
        view.addSubview(searchContainerView)
        view.addSubview(searchResultContainerView)
        view.addSubview(recentSearchContainerView)
        
        searchContainerView.addSubview(iconSearch)
        searchContainerView.addSubview(searchTextField)
        
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        tabCollectionView.addSubview(lineRedView)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        searchResultContainerView.addSubview(tabCollectionView)
        searchResultContainerView.addSubview(listCollectionView)
        
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldEditDidChange(_:)), for: .editingChanged)
        
        tabCollectionView.reloadData()
        listCollectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.animateTabSelected()
        })
    }
    
    fileprivate func setupAutolayouts() {
        bgImageView.layoutEdges()
        
        titleHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleHeaderLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: kPadding).isActive = true
        titleHeaderLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -kPadding).isActive = true
        titleHeaderLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        searchContainerView.topAnchor.constraint(equalTo: titleHeaderLabel.bottomAnchor, constant: 0).isActive = true
        searchContainerView.leftAnchor.constraint(equalTo: titleHeaderLabel.leftAnchor).isActive = true
        searchContainerView.rightAnchor.constraint(equalTo: titleHeaderLabel.rightAnchor).isActive = true
        searchContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        iconSearch.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor).isActive = true
        iconSearch.leftAnchor.constraint(equalTo: searchContainerView.leftAnchor, constant: 15).isActive = true
        iconSearch.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconSearch.widthAnchor.constraint(equalTo: iconSearch.heightAnchor, multiplier: 1).isActive = true
        
        searchTextField.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor).isActive = true
        searchTextField.leftAnchor.constraint(equalTo: iconSearch.rightAnchor, constant: 15).isActive = true
        searchTextField.rightAnchor.constraint(equalTo: searchContainerView.rightAnchor, constant: -5).isActive = true
        searchTextField.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        searchResultContainerView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10).isActive = true
        searchResultContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        searchResultContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        searchResultContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        tabCollectionView.leftAnchor.constraint(equalTo: searchResultContainerView.leftAnchor).isActive = true
        tabCollectionView.topAnchor.constraint(equalTo: searchResultContainerView.topAnchor).isActive = true
        tabCollectionView.rightAnchor.constraint(equalTo: searchResultContainerView.rightAnchor).isActive = true
        tabCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        listCollectionView.leftAnchor.constraint(equalTo: searchResultContainerView.leftAnchor).isActive = true
        listCollectionView.topAnchor.constraint(equalTo: tabCollectionView.bottomAnchor, constant: 15).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: searchResultContainerView.rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: searchResultContainerView.bottomAnchor).isActive = true
        
        recentSearchContainerView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20).isActive = true
        recentSearchContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        recentSearchContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        recentSearchBottomConstraint = recentSearchContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        recentSearchBottomConstraint?.isActive = true
    }
    
    fileprivate func displaySearchContentLayout() {
        searchResultContainerView.isHidden = searchTextField.textString.isEmpty
        recentSearchContainerView.isHidden = !searchTextField.textString.isEmpty
    }
    
    private func presentGenreDetail(_ genre: GenreObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let detail = GenreDetailController()
            detail.genre = genre
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    private func setupRecentSearch() {
        recentSearchContainerView.onOpenGenre = { [weak self] genre in
            self?.presentGenreDetail(genre)
        }
        recentSearchContainerView.onSearch = { [weak self] term in
            guard let self = self else { return }
            
            self.searchTextField.text = term
            let _ = self.textFieldShouldReturn(self.searchTextField)
        }
        recentSearchContainerView.setType(.history)
    }
    
    fileprivate func loadGenres() {
        NetworksService.shared.genres { [weak self] data in
            self?.recentSearchContainerView.genres = data
        }
    }
    
    fileprivate func clearAllData() {
        musicToken = nil
        musics.removeAll()
        
        videoToken = nil
        videos.removeAll()
        
        playlistToken = nil
        playlists.removeAll()
        
        artistToken = nil
        artists.removeAll()
        
        myfile.removeAll()
        listCollectionView.reloadData()
        
        NotificationCenter.default.post(name: .searchClearData, object: nil)
    }
    
    fileprivate func willSearchIfNeed() {
        let term = searchTextField.textString
        if term.isEmpty { return }
        
        switch tabs[selectedIndex] {
        case .music:
            if self.musics.count > 0 { return }
            
            let scip = AltEnum.searchSong.description()
            NetworksService.shared.searchSingle(term: term, scip: scip, continuation: musicToken) { [weak self] data, token in
                self?.musics = data
                self?.musicToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .video:
            if self.videos.count > 0 { return }
            
            let scip = AltEnum.searchVideo.description()
            NetworksService.shared.searchSingle(term: term, scip: scip, continuation: videoToken) { [weak self] data, token in
                self?.videos = data
                self?.videoToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .playlist:
            if self.playlists.count > 0 { return }
            
            NetworksService.shared.searchPlaylist(term: term, continuation: playlistToken) { [weak self] data, token in
                self?.playlists = data
                self?.playlistToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .album:
            if self.albums.count > 0 { return }
            
            NetworksService.shared.searchAlbum(term: term, continuation: albumToken) { [weak self] data, token in
                self?.albums = data
                self?.albumToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .artist:
            if self.artists.count > 0 { return }
            
            NetworksService.shared.searchArtist(term: term, continuation: playlistToken) { [weak self] data, token in
                self?.artists = data
                self?.artistToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .myfile:
            if self.myfile.count > 0 { return }
            
            guard let realm = DBService.shared.realm else { return }
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR artist CONTAINS[cd] %@ ", term, term)
            self.myfile = realm.objects(TrackObject.self).filter(predicate).toArray()
        }
    }
    
    fileprivate func searchMore() {
        let term = searchTextField.textString
        if term.isEmpty { return }
        
        switch tabs[selectedIndex] {
        case .music:
            let scip = AltEnum.searchSong.description()
            NetworksService.shared.searchSingle(term: term, scip: scip, continuation: musicToken) { [weak self] data, token in
                self?.musics += data
                self?.musicToken = token
                self?.musicCell?.tracks = self?.musics ?? []
            }
            
        case .video:
            let scip = AltEnum.searchVideo.description()
            NetworksService.shared.searchSingle(term: term, scip: scip, continuation: videoToken) { [weak self] data, token in
                self?.videos += data
                self?.videoToken = token
                self?.videoCell?.tracks = self?.videos ?? []
            }
            
        case .playlist:
            NetworksService.shared.searchPlaylist(term: term, continuation: playlistToken) { [weak self] data, token in
                self?.playlists += data
                self?.playlistToken = token
                self?.playlistCell?.playlists = self?.playlists ?? []
            }
            
        case .album:
            NetworksService.shared.searchAlbum(term: term, continuation: albumToken) { [weak self] data, token in
                self?.albums += data
                self?.albumToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .artist:
            NetworksService.shared.searchArtist(term: term, continuation: playlistToken) { [weak self] data, token in
                self?.artists += data
                self?.artistToken = token
                self?.artistCell?.artists = self?.artists ?? []
            }
            
        case .myfile:
            break
        }
    }
    
    fileprivate func beginSearch(_ term: String) {
        if term.isEmpty {
            //SwiftMessagesHelper.shared.showWarning(title: "Warning", body: "Can't search for empty term")
            return
        }
        
        switch tabs[selectedIndex] {
        case .music:
            let scip = AltEnum.searchSong.description()
            NetworksService.shared.searchSingle(term: term, scip: scip, continuation: musicToken) { [weak self] data, token in
                self?.musics = data
                self?.musicToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .video:
            let scip = AltEnum.searchVideo.description()
            NetworksService.shared.searchSingle(term: term, scip: scip, continuation: videoToken) { [weak self] data, token in
                self?.videos = data
                self?.videoToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .playlist:
            NetworksService.shared.searchPlaylist(term: term, continuation: playlistToken) { [weak self] data, token in
                self?.playlists = data
                self?.playlistToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .album:
            NetworksService.shared.searchAlbum(term: term, continuation: albumToken) { [weak self] data, token in
                self?.albums = data
                self?.albumToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .artist:
            NetworksService.shared.searchArtist(term: term, continuation: artistToken) { [weak self] data, token in
                self?.artists = data
                self?.artistToken = token
                self?.listCollectionView.reloadData()
            }
            
        case .myfile:
            guard let realm = DBService.shared.realm else { return }
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR artist CONTAINS[cd] %@ ", term, term)
            self.myfile = realm.objects(TrackObject.self).filter(predicate).toArray()
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
            UIView.animate(withDuration: animated ? 0.3 : 0) {
                self.lineRedView.frame = newFrame
            }
        }
    }
    
    fileprivate func play(with track: TrackObject) {
        guard let id = track.trackId else { return }
        
        NetworksService.shared.upNext(id: id) { data in
            var tracks: [TrackObject] = [track]
            tracks += data
            
            UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
        }
    }
    
    fileprivate func addToLibrary(width playlist: TrackObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if DBService.shared.findPlaylistOnDb(playlist.playlistId) == nil {
            let plAdd = PlaylistObject()
            plAdd.title = playlist.title
            plAdd.artist = playlist.artist
            plAdd.playlistThumbnailUrl = playlist.trackThumbnailUrl
            plAdd.playlistId = playlist.playlistId
            
            try? realm.write({
                realm.add(plAdd)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added the playlist")
            })
        }
    }
    
    fileprivate func addToLibrary(width artist: ArtistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if DBService.shared.findArtistOnDb(artist.browseId) == nil {
            let arAdd = ArtistObject()
            arAdd.title = artist.title
            arAdd.subscribers = artist.subscribers
            arAdd.image = artist.image
            arAdd.browseId = artist.browseId
            
            try? realm.write({
                realm.add(arAdd)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added the artist")
            })
        }
    }
    
    private func addOrRemoveFavourite(_ p: PlaylistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if let plNeedRemove = DBService.shared.findPlaylistOnDb(p.playlistId) {
            try? realm.write({
                realm.delete(plNeedRemove)
                
                self.navigationController?.popViewController(animated: true)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted the playlist")
            })
        }
        else {
            
            // Show reward ads o day
            
            let plAdd = PlaylistObject()
            plAdd.title = p.title
            plAdd.artist = p.artist
            plAdd.playlistThumbnailUrl = p.playlistThumbnailUrl
            plAdd.playlistId = p.playlistId
            
            try? realm.write({
                realm.add(plAdd)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added the playlist")
            })
            
        }
    }
    
    fileprivate func openOption(_ p: PlaylistObject) {
        let optionView = PlaylistOptionView()
        optionView.options = [.favourite, .share]
        optionView.playlist = p
        optionView.onSelected = { [weak self] op in
            switch op {
            case .favourite:
                self?.addOrRemoveFavourite(p)
                
            case .share:
                self?.sharePlaylistForFriends(p)
            default: break
            }
        }
        optionView.show()
    }
    
    private func addOrRemoveFavourite(artist ar: ArtistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if let arNeedRemove = DBService.shared.findArtistOnDb(ar.browseId) {
            try? realm.write({
                realm.delete(arNeedRemove)
                
                self.navigationController?.popViewController(animated: true)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted the artist")
            })
        }
        else {
            
            // Show reward ads o day
            
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
    }
    
    fileprivate func openArtistOption(_ ar: ArtistObject) {
        let optionView = ArtistOptionView()
        optionView.artist = ar
        optionView.onSelected = { [weak self] op in
            switch op {
            case .favourite:
                self?.addOrRemoveFavourite(artist: ar)
                
            case .share:
                self?.shareArtistForFriends(ar)
            }
        }
        optionView.show()
    }
    
    // MARK: - public
    // MARK: - event
    @objc func textFieldEditDidChange(_ sender: Any) {
        let term = searchTextField.textString
        
        if term.isEmpty {
            self.recentSearchContainerView.setType(.history, [])
            return
        }
        
        NetworksService.shared.suggestion(term: term) { [weak self] data in
            self?.terms = data
            self?.recentSearchContainerView.setType(.suggest, data)
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        keyboardShowing = true
        
        guard let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        recentSearchBottomConstraint?.constant = -size.height
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        keyboardShowing = false
        recentSearchBottomConstraint?.constant = 0
    }
    
}

extension SearchController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchResultContainerView.isHidden = true
        recentSearchContainerView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchResultContainerView.isHidden = false
        recentSearchContainerView.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        displaySearchContentLayout()
        clearAllData()
        beginSearch(textField.textString)
        RecentSearchService.shared.saveHistory(textField.textString)
        
        if textField.textString.isEmpty {
            recentSearchContainerView.setType(.history)
        }
        
        return true
    }
}

extension SearchController: UICollectionViewDelegate, UICollectionViewDataSource {
    func presentPlaylistDetail(_ pl: PlaylistObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let detail = PlaylistOnlDetailController()
            detail.playlist = pl
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func presentArtistDetail(_ artist: ArtistObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let detail = ArtistDetailController()
            detail.artist = artist
            self.navigationController?.pushViewController(detail, animated: true)
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
            cell.setTabSearch(tabs[indexPath.row], tabSelected: tabs[selectedIndex])
            return cell
        }
        else {
            switch tabs[indexPath.row] {
            case .music:
                if musicCell == nil {
                    musicCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                }
                
                musicCell!.heightPlayerMini = heightPlayerMini
                musicCell!.tracks = musics
                musicCell!.onSelected = { [weak self] track in
                    self?.play(with: track)
                }
                musicCell!.onOption = { [weak self] track in
                    self?.openTrackOption(track, style: .style3)
                }
                musicCell!.onLoadMore = { [weak self] in
                    self?.searchMore()
                }
                musicCell?.setAdView(admobAd: super.admobAd, applovinAdView: super.applovinAdView)
                return musicCell!
                
            case .video:
                if videoCell == nil {
                    videoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                }
                
                videoCell!.heightPlayerMini = heightPlayerMini
                videoCell!.tracks = videos
                videoCell!.onSelected = { [weak self] track in
                    self?.play(with: track)
                }
                videoCell!.onOption = { [weak self] track in
                    self?.openTrackOption(track, style: .style3)
                }
                videoCell!.onLoadMore = { [weak self] in
                    self?.searchMore()
                }
                return videoCell!
                
            case .playlist:
                if playlistCell == nil {
                    playlistCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                }
                
                playlistCell!.heightPlayerMini = heightPlayerMini
                playlistCell!.playlists = playlists
                playlistCell!.onSelected = { [weak self] pl in
                    self?.presentPlaylistDetail(pl)
                }
                playlistCell!.onOption = { [weak self] playlist in
                    self?.openOption(playlist)
                }
                playlistCell!.onLoadMore = { [weak self] in
                    self?.searchMore()
                }
                return playlistCell!
                
            case .album:
                if albumCell == nil {
                    albumCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                }
                
                albumCell!.heightPlayerMini = heightPlayerMini
                albumCell!.playlists = albums
                albumCell!.onSelected = { [weak self] pl in
                    self?.presentPlaylistDetail(pl)
                }
                albumCell!.onOption = { [weak self] playlist in
                    self?.openOption(playlist)
                }
                albumCell!.onLoadMore = { [weak self] in
                    self?.searchMore()
                }
                return albumCell!
                
            case .artist:
                if artistCell == nil {
                    artistCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                }
                
                artistCell!.heightPlayerMini = heightPlayerMini
                artistCell!.artists = artists
                artistCell!.onSelected = { [weak self] artist in
                    self?.presentArtistDetail(artist)
                }
                artistCell!.onOption = { [weak self] artist in
                    self?.openArtistOption(artist)
                }
                artistCell!.onLoadMore = { [weak self] in
                    self?.searchMore()
                }
                return artistCell!
                
            case .myfile:
                let cell: SearchMyFileCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.heightPlayerMini = heightPlayerMini
                cell.tracks = myfile
                cell.onSelected = { [weak self] track, tracks in
                    self?.play(with: track)
                }
                cell.onOption = { [weak self] track in
                    self?.openTrackOption(track, style: .style1)
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
            willSearchIfNeed()
        }
        else {
            
        }
    }
}

extension SearchController: UICollectionViewDelegateFlowLayout {
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
        return collectionView == tabCollectionView ? 30 : 0
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

extension SearchController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !searchTextField.textString.isEmpty {
            searchTextField.resignFirstResponder()
        }
        
        if scrollView == tabCollectionView {
            // don't nothing
        }
        else if scrollView == listCollectionView {
            let currentPage = Int(scrollView.contentOffset.x / scrollView.size.width)
            self.selectedIndex = currentPage
            self.tabCollectionView.reloadData()
            self.animateTabSelected()
            self.willSearchIfNeed()
        }
    }
}
