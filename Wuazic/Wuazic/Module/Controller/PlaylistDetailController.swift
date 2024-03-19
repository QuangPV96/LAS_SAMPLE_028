import UIKit

class PlaylistDetailController: BaseController {
    
    var id: String = ""
    fileprivate var playlist: PlaylistObject?
    fileprivate var tracks: [TrackObject] = []
    fileprivate var continuation: String? = nil
    fileprivate var headerTableView: PlaylistDetailHeaderView?
    
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
    
    fileprivate let optionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-option-white"), for: .normal)
        return view
    }()
    
    fileprivate let listTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        view.backgroundColor = .clear
        view.registerItem(cell: PlaylistDetailTrackItemCell.self)
        view.registerItem(cell: PlaylistDetailNoDataCell.self)
        view.registerItem(cell: AdmobNativeAdTableCell.self)
        view.registerItem(cell: AppLovinNativeAdTableCell.self)
        return view
    }()
    
    fileprivate let topView: PlaylistDetailTopView = {
        let view = PlaylistDetailTopView()
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
        
        if !super.loadedNative {
            super.loadNativeAd { [weak self] in
                self?.listTableView.reloadData()
            }
        }
    }
    
    // MARK: - private
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .databaseChanged, object: nil, queue: .main) { [weak self] _ in
            self?.reloadData()
        }
        
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
        view.backgroundColor = .init(rgb: 0x0E0D0D)
        
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        
        topView.frame = CGRect(x: 0, y: 0, width: view.size.width, height: PlaylistDetailTopView.height)
        
        listTableView.tableHeaderView = topView
        listTableView.delegate = self
        listTableView.dataSource = self
        
        headerView.addSubview(backButton)
        headerView.addSubview(optionButton)
        
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
        
        listTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        listTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        listTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        listTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        backButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1).isActive = true
        
        optionButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        optionButton.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        optionButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        optionButton.widthAnchor.constraint(equalTo: optionButton.heightAnchor, multiplier: 1).isActive = true
    }
    
    private func reloadData() {
        guard let realm = DBService.shared.realm,
              let playlistUpdate = realm.objects(PlaylistObject.self).first(where: { $0.id == self.id })
        else {
            return
        }
        
        playlist = playlistUpdate
        topView.trackThumbnailUrl = playlist?.trackThumbnailUrl
        listTableView.reloadData()
        
        if playlistUpdate.type == .online {
            continuation = continuation == "" ? nil : continuation
            NetworksService.shared.playlistOrAlbumDetail(browseId: playlistUpdate.playlistId ?? "", continuation: continuation) { [weak self] data, continuation in
                self?.tracks = data
                self?.continuation = continuation
                self?.listTableView.reloadData()
            }
        }
    }
    
    fileprivate func tracksOnPlaylist() -> [TrackObject] {
        guard let p = playlist else { return [] }
        
        if p.type == .manually {
            return p.tracks.map({$0})
        }
        else {
            return tracks
        }
    }
    
    private func renamePlaylist(_ p: PlaylistObject) {
        let makePlaylist = CreatePlaylistView()
        makePlaylist.onUpdated = { [weak self] _ in
            self?.listTableView.reloadData()
        }
        makePlaylist.playlist = p   // for rename
        makePlaylist.show()
    }
    
    private func delete(_ p: PlaylistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        try? realm.write({
            realm.delete(p)
            
            SwiftMessagesHelper.shared.showSuccess(title: "Notification", body: "Deleted the playlist")
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: - public
    override func deleteFromPlaylist(_ track: TrackObject) {
        guard let realm = DBService.shared.realm,
              let playlistUpdate = realm.objects(PlaylistObject.self).first(where: { $0.id == self.id }),
              let index = playlistUpdate.tracks.firstIndex(where: { $0.id == track.id })
        else {
            return
        }
        
        try? realm.write({
            playlistUpdate.tracks.remove(at: index)
            
            //
            NotificationCenter.default.post(name: .databaseChanged, object: nil)
            
            SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted from playlist")
        })
    }
    
    // MARK: - event
    @objc func backClick() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func optionClick() {
        let optionView = PlaylistOptionView()
        optionView.options = [.addTrack, .rename, .delete]
        optionView.playlist = playlist
        optionView.onSelected = { [weak self] op in
            switch op {
            case .addTrack:
                let addTrack = AddTrackController()
                addTrack.id = self?.id ?? ""
                addTrack.modalPresentationStyle = .fullScreen
                self?.present(addTrack, animated: true)
                
            case .rename:
                if let p = self?.playlist {
                    self?.renamePlaylist(p)
                }
                
            case .delete:
                if let p = self?.playlist {
                    self?.delete(p)
                }
                
            default: break
            }
        }
        optionView.show()
    }
    
}

extension PlaylistDetailController: UITableViewDelegate, UITableViewDataSource {
    private func makeCell(_ tableView: UITableView, track: TrackObject) -> UITableViewCell {
        let cell: PlaylistDetailTrackItemCell = tableView.dequeueReusableCell()
        cell.track = track
        cell.onOption = { [weak self] track in
            if let p = self?.playlist, p.type == .online {
                self?.openTrackOption(track, style: .style3)
            }
            else {
                self?.openTrackOption(track, style: .style2)
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tt = tracksOnPlaylist()
        let count = tt.count == 0 ? 1 : tt.count
        
        if super.numberOfNatives() > 0 {
            return count + 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if super.numberOfNatives() > 0 {
            switch indexPath.row {
            case 0:
                if super.admobAd != nil {
                    let cell: AdmobNativeAdTableCell = tableView.dequeueReusableCell()
                    cell.nativeAd = super.admobAd
                    return cell
                }
                else {
                    let cell: AppLovinNativeAdTableCell = tableView.dequeueReusableCell()
                    cell.nativeAd = super.applovinAdView
                    return cell
                }
            default:
                let tt = tracksOnPlaylist()
                if tt.count == 0 {
                    let cell: PlaylistDetailNoDataCell = tableView.dequeueReusableCell()
                    return cell
                }
                else {
                    return makeCell(tableView, track: tt[indexPath.row - 1])
                }
            }
        }
        else {
            let tt = tracksOnPlaylist()
            if tt.count == 0 {
                let cell: PlaylistDetailNoDataCell = tableView.dequeueReusableCell()
                return cell
            }
            else {
                return makeCell(tableView, track: tt[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if super.numberOfNatives() > 0 {
            switch indexPath.row {
            case 0:
                break
            default:
                let tt = tracksOnPlaylist()
                if tt.count > 0 {
                    let tracks = tracksOnPlaylist()
                    let track = tracks[indexPath.row - 1]
                    UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
                }
            }
        }
        else {
            let tt = tracksOnPlaylist()
            if tt.count > 0 {
                let tracks = tracksOnPlaylist()
                let track = tracks[indexPath.row]
                UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: tracks)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if super.numberOfNatives() > 0 {
            switch indexPath.row {
            case 0:
                if super.admobAd != nil {
                    return AdmobNativeAdTableCell.height
                }
                else {
                    return AppLovinNativeAdTableCell.height
                }
            default:
                let tt = tracksOnPlaylist()
                if tt.count == 0 {
                    return PlaylistDetailNoDataCell.height
                }
                else {
                    return PlaylistDetailTrackItemCell.height
                }
            }
        }
        else {
            let tt = tracksOnPlaylist()
            if tt.count == 0 {
                return PlaylistDetailNoDataCell.height
            }
            else {
                return PlaylistDetailTrackItemCell.height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlaylistDetailHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect: CGRect = .init(x: 0, y: 0, width: tableView.size.width, height: PlaylistDetailHeaderView.height)
        
        if headerTableView == nil {
            headerTableView = PlaylistDetailHeaderView(frame: rect)
        }
        
        headerTableView?.frame = rect
        headerTableView?.playlist = playlist
        headerTableView?.onShuffle = { [weak self] pl in
            self?.play(pl, shuffle: true)
        }
        headerTableView?.onPlay = { [weak self] pl in
            self?.play(pl, shuffle: false)
        }
        return headerTableView!
    }
    
    private func play(_ playlist: PlaylistObject, shuffle: Bool) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            var tracks = tracksOnPlaylist()
            if tracks.count == 0 {
                return
            }
            
            if shuffle {
                tracks.shuffle()
            }
            
            UIWindow.keyWindow?.mainTabbar?.play(with: tracks.first!, tracks: tracks)
        }
    }
    
}

extension PlaylistDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3) {
            let y = scrollView.contentOffset.y
            let isHiddenHeader = y >= PlaylistDetailTopView.height
            
            self.headerView.backgroundColor = isHiddenHeader ? UIColor(rgb: 0x0E0D0D) : .clear
            self.statusBarView.backgroundColor = self.headerView.backgroundColor
        }
        
        UIView.animate(withDuration: 0.3) {
            let y = scrollView.contentOffset.y
            let isHiddenHeader = y >= PlaylistDetailTopView.height + 25
            
            self.headerTableView?.backgroundColor = isHiddenHeader ? UIColor(rgb: 0x0E0D0D) : .clear
        }
    }
}
