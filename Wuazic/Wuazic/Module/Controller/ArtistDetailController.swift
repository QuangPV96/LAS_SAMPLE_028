import UIKit
import SDWebImage

class ArtistDetailController: BaseController {
    
    fileprivate var songs: [TrackObject] = []
    fileprivate var videos: [TrackObject] = []
    fileprivate var featured: [PlaylistObject] = []
    fileprivate var albums: [PlaylistObject] = []
    fileprivate var headerTableView: ArtistDetailHeaderView?
    
    var autoBackWhenDeletePlaylist: Bool = false
    var artist: ArtistObject?
    
    // MARK: - property
    fileprivate let bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "bg-playlist-detail"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let statusBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-back"), for: .normal)
        return view
    }()
    
    fileprivate let artistNameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 18)
        view.alpha = 0
        return view
    }()
    
    fileprivate let subInfoLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.gilroy(of: 14)
        view.textColor = .init(rgb: 0x00D1EE)
        view.textAlignment = .center
        view.alpha = 0
        return view
    }()
    
    fileprivate let listTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.registerItem(cell: ArtistDetailTitleCell.self)
        view.registerItem(cell: ArtistDetailSongItemCell.self)
        view.registerItem(cell: ArtistDetailVideoCell.self)
        view.registerItem(cell: ArtistDetailFeaturedCell.self)
        view.registerItem(cell: ArtistDetailAlbumCell.self)
        
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        
        return view
    }()
    
    fileprivate let topView: ArtistDetailTopView = {
        let view = ArtistDetailTopView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupObservers()
        setupUIs()
        reloadData()
        updateContentInsetForListTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - private
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .willShowPlayerMini, object: nil, queue: .main) { [weak self] _ in
            self?.updateContentInsetForListTableView()
        }
        
        NotificationCenter.default.addObserver(forName: .didHidePlayerMini, object: nil, queue: .main) { [weak self] _ in
            self?.updateContentInsetForListTableView()
        }
    }
    
    private func updateContentInsetForListTableView() {
        listTableView.contentInset = .init(top: 0, left: 0, bottom: UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0, right: 0)
    }
    
    private func setupUIs() {
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        
        topView.frame = CGRect(x: 0, y: 0, width: view.size.width, height: ArtistDetailTopView.height)
        
        listTableView.tableHeaderView = topView
        listTableView.delegate = self
        listTableView.dataSource = self
        
        headerView.addSubview(backButton)
        headerView.addSubview(artistNameLabel)
        headerView.addSubview(subInfoLabel)
        
        view.addSubview(bgImageView)
        view.addSubview(statusBarView)
        view.addSubview(headerView)
        view.addSubview(listTableView)
        
        bgImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bgImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bgImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bgImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        statusBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statusBarView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        statusBarView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        statusBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1).isActive = true
        
        artistNameLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        artistNameLabel.leftAnchor.constraint(equalTo: backButton.rightAnchor).isActive = true
        artistNameLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -50).isActive = true
        artistNameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        subInfoLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor).isActive = true
        subInfoLabel.leftAnchor.constraint(equalTo: artistNameLabel.leftAnchor).isActive = true
        subInfoLabel.rightAnchor.constraint(equalTo: artistNameLabel.rightAnchor).isActive = true
        subInfoLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        listTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        listTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        listTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        listTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func reloadData() {
        guard let ar = artist else { return }
        
        topView.artist = ar
        artistNameLabel.text = ar.title
        subInfoLabel.text = ar.subscribers
        
        self.songs.removeAll()
        self.videos.removeAll()
        self.featured.removeAll()
        self.albums.removeAll()
        
        NetworksService.shared.artistDetail(artistId: ar.browseId) { [weak self] songs, videos, playlists, albums in
            self?.songs = songs
            self?.videos = videos
            self?.featured = playlists
            self?.albums = albums
            self?.listTableView.reloadData()
        }
    }
    
    fileprivate func addOrRemoveFavourite(ar: ArtistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if let arNeedRemove = DBService.shared.findArtistOnDb(ar.browseId) {
            try? realm.write({
                realm.delete(arNeedRemove)
                
                if self.autoBackWhenDeletePlaylist {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.listTableView.reloadData()
                }
                
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
                
                self.listTableView.reloadData()
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added the artist")
            })
        }
    }
    
    // MARK: - public
    // MARK: - event
    @objc func backClick() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension ArtistDetailController: UITableViewDelegate, UITableViewDataSource {
    func presentTrackOption(_ track: TrackObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.openTrackOption(track)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return songs.count == 0 ? 0 : songs.count + 1      // row 0 is text cell
        }
        else if section == 1 {
            return videos.count == 0 ? 0 : 2    // row 0 is text cell
        }
        else if section == 2 {
            return featured.count == 0 ? 0 : 2    // row 0 is text cell
        }
        else {
            return featured.count == 0 ? 0 : 2    // row 0 is text cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell: ArtistDetailTitleCell = tableView.dequeueReusableCell()
                cell.text = "Songs"
                cell.enableMore = false
                cell.onMore = {
                    
                }
                return cell
            }
            else {
                let cell: ArtistDetailSongItemCell = tableView.dequeueReusableCell()
                cell.track = songs[indexPath.row - 1]
                cell.onOption = { [weak self] track in
                    self?.presentTrackOption(track)
                }
                cell.onDaolod = { [weak self] track in
                    self?.waitcome(track)
                }
                return cell
            }
        case 1:
            if indexPath.row == 0 {
                let cell: ArtistDetailTitleCell = tableView.dequeueReusableCell()
                cell.text = "Videos"
                cell.enableMore = false
                cell.onMore = {
                    
                }
                return cell
            }
            else {
                let cell: ArtistDetailVideoCell = tableView.dequeueReusableCell()
                cell.data = videos
                cell.onPlay = { track, tracks in
                    UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
                }
                return cell
            }
        case 2:
            if indexPath.row == 0 {
                let cell: ArtistDetailTitleCell = tableView.dequeueReusableCell()
                cell.text = "Albums"
                cell.enableMore = false
                return cell
            }
            else {
                let cell: ArtistDetailAlbumCell = tableView.dequeueReusableCell()
                cell.data = albums
                cell.onSelected = { [weak self] playlist in
                    let detail = PlaylistOnlDetailController()
                    detail.playlist = playlist
                    self?.navigationController?.pushViewController(detail, animated: true)
                }
                return cell
            }
        default:
            if indexPath.row == 0 {
                let cell: ArtistDetailTitleCell = tableView.dequeueReusableCell()
                cell.text = "Featured"
                cell.enableMore = false
                return cell
            }
            else {
                let cell: ArtistDetailFeaturedCell = tableView.dequeueReusableCell()
                cell.data = featured
                cell.onSelected = { [weak self] playlist in
                    let detail = PlaylistOnlDetailController()
                    detail.playlist = playlist
                    self?.navigationController?.pushViewController(detail, animated: true)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return indexPath.row == 0 ? ArtistDetailTitleCell.height : ArtistDetailSongItemCell.height
        }
        else if indexPath.section == 1 {
            return indexPath.row == 0 ? ArtistDetailTitleCell.height : ArtistDetailVideoCell.height
        }
        else if indexPath.section == 1 {
            return indexPath.row == 0 ? ArtistDetailTitleCell.height : ArtistDetailAlbumCell.height
        }
        else {
            return indexPath.row == 0 ? ArtistDetailTitleCell.height : ArtistDetailFeaturedCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return ArtistDetailHeaderView.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let rect: CGRect = .init(x: 0, y: 0, width: tableView.size.width, height: ArtistDetailHeaderView.height)
            
            if headerTableView == nil {
                headerTableView = ArtistDetailHeaderView(frame: rect)
            }
            
            headerTableView?.frame = rect
            headerTableView?.artist = artist
            headerTableView?.onPlay = { [weak self] ar in
                self?.playList(shuffle: false)
            }
            headerTableView?.onShuffle = { [weak self] ar in
                self?.playList(shuffle: true)
            }
            headerTableView?.onFavourite = { [weak self] ar in
                self?.addOrRemoveFavourite(ar: ar)
            }
            return headerTableView!
        }
        else {
            let headerView = UIView(frame: .zero)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                // don't nothing
            }
            else {
                let so = songs[indexPath.row - 1]
                UIWindow.keyWindow?.mainTabbar?.play(with: so, tracks: songs)
            }
        default: break
        }
    }
    
    private func playList(shuffle: Bool) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            var tmpTracks = songs
            if tmpTracks.count == 0 {
                return
            }
            
            if shuffle {
                tmpTracks.shuffle()
            }
            
            UIWindow.keyWindow?.mainTabbar?.play(with: tmpTracks.first!, tracks: tmpTracks)
        }
    }
    
}

extension ArtistDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3) {
            let y = scrollView.contentOffset.y
            let isHiddenHeader = y >= ArtistDetailTopView.height - 10
            
            self.artistNameLabel.alpha = isHiddenHeader ? 1.0 : 0.0
            self.subInfoLabel.alpha = isHiddenHeader ? 1.0 : 0.0
            self.headerView.backgroundColor = isHiddenHeader ? UIColor(rgb: 0x0E0D0D) : .clear
            self.statusBarView.backgroundColor = self.headerView.backgroundColor
        }
        
        UIView.animate(withDuration: 0.3) {
            let y = scrollView.contentOffset.y
            let isHiddenHeader = y >= ArtistDetailTopView.height
            
            self.headerTableView?.backgroundColor = isHiddenHeader ? UIColor(rgb: 0x0E0D0D) : .clear
        }
    }
}
