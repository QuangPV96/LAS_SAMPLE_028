import UIKit

class PlaylistOnlDetailController: BaseController {
    
    var autoBackWhenDeletePlaylist: Bool = false
    var playlist: PlaylistObject?
    
    fileprivate var tracks: [TrackObject] = []
    fileprivate var continuation: String? = nil
    fileprivate var headerTableView: PlaylistOnlDetailHeaderView?
    
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
        topView.trackThumbnailUrl = playlist?.trackThumbnailUrl
        listTableView.reloadData()
        
        tracks.removeAll()
        continuation = continuation == "" ? nil : continuation
        NetworksService.shared.playlistOrAlbumDetail(browseId: playlist?.playlistId ?? "", continuation: continuation) { [weak self] data, continuation in
            self?.tracks = data
            self?.continuation = continuation
            self?.listTableView.reloadData()
        }
    }
    
    private func loadMore() {
        continuation = continuation == "" ? nil : continuation
        NetworksService.shared.playlistOrAlbumDetail(browseId: playlist?.playlistId ?? "", continuation: continuation) { [weak self] data, continuation in
            self?.tracks += data
            self?.continuation = continuation
            self?.listTableView.reloadData()
        }
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func backClick() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func optionClick() {
        guard let p = playlist else { return }
        
        let optionView = PlaylistOptionView()
        optionView.options = [.favourite, .share]
        optionView.playlist = p
        optionView.onSelected = { [weak self] op in
            switch op {
            case .favourite:
                guard let realm = DBService.shared.realm else { return }
                
                if let plNeedRemove = DBService.shared.findPlaylistOnDb(p.playlistId) {
                    try? realm.write({
                        realm.delete(plNeedRemove)
                        
                        if self?.autoBackWhenDeletePlaylist ?? false {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        
                        //NotificationCenter.default.post(name: .databaseChanged, object: nil)
                        
                        SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted the playlist")
                    })
                }
                else {
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
                
            case .share:
                self?.sharePlaylistForFriends(p)
            default: break
            }
        }
        optionView.show()
    }
    
}

extension PlaylistOnlDetailController: UITableViewDelegate, UITableViewDataSource {
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
        return super.numberOfNatives() > 0 ? tracks.count + 1 : tracks.count
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
                return makeCell(tableView, track: tracks[indexPath.row - 1])
            }
        }
        else {
            return makeCell(tableView, track: tracks[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if super.numberOfNatives() > 0 {
            switch indexPath.row {
            case 0:
                break
            default:
                UIWindow.keyWindow?.mainTabbar?.play(with: tracks[indexPath.row - 1], tracks: tracks)
            }
        }
        else {
            UIWindow.keyWindow?.mainTabbar?.play(with: tracks[indexPath.row], tracks: tracks)
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
                return PlaylistDetailTrackItemCell.height
            }
        }
        else {
            return PlaylistDetailTrackItemCell.height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return PlaylistOnlDetailHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect: CGRect = .init(x: 0, y: 0, width: tableView.size.width, height: PlaylistOnlDetailHeaderView.height)
        
        if headerTableView == nil {
            headerTableView = PlaylistOnlDetailHeaderView(frame: rect)
        }
        
        headerTableView?.frame = rect
        headerTableView?.playlist = playlist
        headerTableView?.onShuffle = { [weak self] in
            self?.playList(shuffle: true)
        }
        headerTableView?.onPlay = { [weak self] in
            self?.playList(shuffle: false)
        }
        return headerTableView!
    }
    
    private func playList(shuffle: Bool) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            var tmpTracks = tracks
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

extension PlaylistOnlDetailController: UIScrollViewDelegate {
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
