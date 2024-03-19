//
//  FeatureController.swift
//  SwiftyAds
//
//  Created by MinhNH on 09/04/2023.
//

import UIKit

private enum FeatureLayout {
    case header, trend, hot, community, artist, newest, recommend
}

class FeatureController: BaseController {
    
    fileprivate var heightPlayerMini: CGFloat = 0
    
    // MARK: - property
    fileprivate let layouts: [FeatureLayout] = [.header, .trend, .hot, .community, .artist, .newest, .recommend]
    
    fileprivate var trending: [TrackObject] = []
    fileprivate var hottest: [TrackObject] = []
    fileprivate var artists: [ArtistObject] = []
    fileprivate var newest: [TrackObject] = []
    fileprivate var recommend: [TrackObject] = []
    
    fileprivate let bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "bg-feature"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: FeatHeaderCell.self)
        view.registerItem(cell: FeatTrendCell.self)
        view.registerItem(cell: FeatHotCell.self)
        view.registerItem(cell: FeatCommunityCell.self)
        view.registerItem(cell: FeatArtistCell.self)
        view.registerItem(cell: FeatNewestCell.self)
        view.registerItem(cell: FeatRecommendCell.self)
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
        view.addSubview(listCollectionView)
        
        bgImageView.layoutEdges()
        listCollectionView.layoutSafeAreaEdges()
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        listCollectionView.reloadData()
        
        setupObservers()
        loadData()
    }
    
    // MARK: - private
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .databaseChanged, object: nil, queue: .main) { [weak self] sender in
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .willShowPlayerMini, object: nil, queue: .main) { [weak self] sender in
            self?.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .didHidePlayerMini, object: nil, queue: .main) { [weak self] sender in
            self?.heightPlayerMini = UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0
            self?.listCollectionView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .isConnected, object: nil, queue: .main) { [weak self] sender in
            if self?.dataEmpty() ?? false {
                self?.loadData()
            }
        }
    }
    
    private func dataEmpty() -> Bool {
        return trending.count == 0 || hottest.count == 0 || artists.count == 0 || newest.count == 0 || recommend.count == 0
    }
    
    private func randomTrack(_ list: [TrackObject]) -> TrackObject? {
        if list.count == 0 {
            return nil
        }
        
        let index = Int.random(in: 0..<list.count)
        return list[index]
    }
    
    private func loadData() {
        NetworksService.shared.trending { data in
            self.trending = data
            self.listCollectionView.reloadData()
        }
        NetworksService.shared.hottest { data in
            self.hottest = data
            self.listCollectionView.reloadData()
            
            if let track = self.randomTrack(self.hottest) {
                UserNotificationHandle.shared.makeScheduleEveryday(body: track.subtitle)
            }
            if let track = self.randomTrack(self.hottest) {
                UserNotificationHandle.shared.makeScheduleEveryday(body: track.subtitle, hour: 15, minute: 10)
            }
        }
        NetworksService.shared.artists { data in
            self.artists = data
            self.listCollectionView.reloadData()
        }
        NetworksService.shared.newest { data in
            self.newest = data
            self.listCollectionView.reloadData()
        }
        NetworksService.shared.recommend { data in
            self.recommend = data
            self.listCollectionView.reloadData()
        }
    }
    
    // MARK: - public
    // MARK: - event
    
}

extension FeatureController: UICollectionViewDelegate, UICollectionViewDataSource {
    func presentTrackOption(_ track: TrackObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.openTrackOption(track)
        }
    }
    
    func presentAristDetail(_ artist: ArtistObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let detail = ArtistDetailController()
            detail.artist = artist
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func presentNewestDetail(_ track: TrackObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let detail = NewestDetailController()
            detail.newest = track
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func presentNewestMore() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            let moreController = NewestController()
            moreController.data = self.newest
            self.navigationController?.pushViewController(moreController, animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch layouts[indexPath.row] {
        case .header:
            let cell: FeatHeaderCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        case .trend:
            let cell: FeatTrendCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.data = trending
            cell.onPlay = { [weak self] track in
                guard let self = self else { return }
                
                UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: self.trending)
            }
            cell.onDaolod = { [weak self] track in
                self?.waitcome(track)
            }
            return cell
            
        case .recommend:
            let cell: FeatRecommendCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.data = recommend
            cell.onOption = { [weak self] track in
                self?.presentTrackOption(track)
            }
            cell.onDaolod = { [weak self] track in
                self?.waitcome(track)
            }
            cell.onPlay = { [weak self] track in
                guard let self = self else { return }
                
                UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: self.recommend)
            }
            cell.onMore = { [weak self] tracks in
                let moreController = RecommendController()
                moreController.data = self?.recommend ?? []
                self?.navigationController?.pushViewController(moreController, animated: true)
            }
            return cell
            
        case .newest:
            let cell: FeatNewestCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.data = newest
            cell.onSelected = { [weak self] track in
                self?.presentNewestDetail(track)
            }
            cell.onMore = { [weak self] in
                self?.presentNewestMore()
            }
            return cell
        case .artist:
            let cell: FeatArtistCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.data = artists
            cell.onSelected = { [weak self] artist in
                self?.presentAristDetail(artist)
            }
            cell.onMore = { [weak self] artists in
                let moreController = ArtistController()
                moreController.data = self?.artists ?? []
                self?.navigationController?.pushViewController(moreController, animated: true)
            }
            return cell
        case .hot:
            let cell: FeatHotCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.data = hottest
            cell.onPlay = { [weak self] track in
                guard let self = self else { return }
                
                UIWindow.keyWindow?.mainTabbar?.play(with: track, tracks: self.hottest)
            }
            cell.onDaolod = { [weak self] track in
                self?.waitcome(track)
            }
            cell.onOption = { [weak self] track in
                self?.presentTrackOption(track)
            }
            cell.onMore = { [weak self] tracks in
                let moreController = HotController()
                moreController.data = self?.hottest ?? []
                self?.navigationController?.pushViewController(moreController, animated: true)
            }
            return cell
        case .community:
            let cell: FeatCommunityCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.onCommunity = {
                self.add(CommunityVC(), frame: self.view.frame)
            }
            return cell
        }
    }
}

extension FeatureController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: kPadding, bottom: self.heightPlayerMini, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.size.width - 2 * kPadding
        switch layouts[indexPath.row] {
        case .header:
            return FeatHeaderCell.size(width: width)
        case .community:
            
            let teleChannel: String = DataCommonModel.shared.extraFind("telegram_channel") ?? ""
            let teleGroup: String = DataCommonModel.shared.extraFind("telegram_group") ?? ""
            let discord: String = DataCommonModel.shared.extraFind("discord_group") ?? ""
            
            if teleChannel != "" || teleGroup != "" || discord != "" {
                return FeatCommunityCell.size(width: width)
            } else {
                return CGSize(width: width, height: 0)
            }
        case .trend:
            return FeatTrendCell.size(width: width)
        case .recommend:
            let numberItems = CGFloat(min(kMaxItemDisplay, recommend.count))
            let height = numberItems * FeatRecommendItemCell.size(width: width).height
            return .init(width: width, height: height + 40)  // 40 is height title label
        case .newest:
            return FeatNewestCell.size(width: width)
        case .artist:
            return FeatArtistCell.size(width: width)
        case .hot:
            return FeatHotCell.size(width: width)
        }
    }
}
