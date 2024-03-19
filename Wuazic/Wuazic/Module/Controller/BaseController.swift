import UIKit
import GoogleMobileAds
import AppLovinSDK
import AppTrackingTransparency

class BaseController: UIViewController {
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
    }
    
    fileprivate var _rewarded: AdmobReward?
    
    // MARK: - property
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .init(rgb: 0x0E0D0D)
    }
    
    // MARK: - private
    // MARK: - public
    func deleteFromPlaylist(_ track: TrackObject) {
        
    }
    
    // MARK: - Native Ad
    var nativeIndex: Int = 0
    var loadedNative: Bool = false
    
    fileprivate var admobNative: AdmobNative?
    fileprivate var applovinNative: ApplovinNative?
    
    var admobAd: GADNativeAd?
    var applovinAdView: MANativeAdView?
    
    private func hasRequestTrackingIDFA() -> Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus != .notDetermined
        }
        else {
            return true
        }
    }
    
    func loadNativeAd(_ completion: @escaping () -> Void) {
        if hasRequestTrackingIDFA() == false {
            return
        }
        
        let nativesAvailable = DataCommonModel.shared.adsAvailableFor(.native)
        if nativeIndex >= nativesAvailable.count {
            return
        }
        
        let name = nativesAvailable[nativeIndex].name
        nativeIndex += 1
        
        switch name {
        case .admob:
            if admobNative != nil { return }
            
            admobNative = AdmobNative(numberOfAds: 1, nativeDidReceive: { [weak self] natives in
                if natives.first != nil {
                    self?.loadedNative = true
                    self?.admobAd = natives.first
                    completion()
                }
            }, nativeDidFail: { [weak self] error in
                self?.loadNativeAd(completion)
            })
            admobNative?.preloadAd(controller: self)
            
        case .applovin:
            if applovinNative != nil { return }
            
            applovinNative = ApplovinNative(nativeDidReceive: { [weak self] (nativeAdView, nativeAd) in
                self?.loadedNative = true
                self?.applovinAdView = nativeAdView
                completion()
            }, nativeDidFail: { [weak self] error in
                self?.loadNativeAd(completion)
            })
            applovinNative?.preloadAd(controller: self)
            
        }
    }
    
    func numberOfNatives() -> Int {
        return admobAd != nil || applovinAdView != nil ? 1 : 0
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        let fromVC = self
        let toVC = viewControllerToPresent
        let action = "present"
        
        super.present(viewControllerToPresent, animated: flag, completion: completion)
        
        let event = ["screen-from" : NSStringFromClass(fromVC.classForCoder),
                     "screen-to" : NSStringFromClass(toVC.classForCoder),
                     "action" : action]
        NetworksService.shared.postEvent(event: event)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let fromVC = self
        let action = "present"
        
        super.dismiss(animated: flag, completion: completion)
        let event = ["screen-from" : NSStringFromClass(fromVC.classForCoder),
                     "screen-to" : "",
                     "action" : action]
        NetworksService.shared.postEvent(event: event)
    }
}

extension BaseController {
    private func watchAds(_ track: TrackObject) {
        let loadView = PALoadingView()
        loadView.setMessage("Loading ads...")
        loadView.show()
        
        _rewarded = AdmobReward()
        _rewarded?.preloadAd(completion: { [weak self] success in
            loadView.dismiss()
            
            if success {
                self?._rewarded?.tryToPresentDidEarnReward {
                    DaoladService.shared.waitcome(track)
                }
            }
            else {
                DaoladService.shared.waitcome(track)
            }
        })
    }
    
    func addOrDeleteFavourite(_ track: TrackObject) {
        guard let realm = DBService.shared.realm else { return }
        
        if let favourite = realm.objects(TrackFavouriteObject.self).first(where: { $0.trackId == track.trackId }) {
            try? realm.write({
                realm.delete(favourite)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted to the favourite")
            })
        }
        else {
            let favouriteAdd = TrackFavouriteObject()
            favouriteAdd.loadTrack(track: track)
            
            try? realm.write({
                realm.add(favouriteAdd)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Added to the favourite")
            })
        }
    }
    
    func waitcome(_ track: TrackObject) {
        let ok: String? = DataCommonModel.shared.extraFind("rewarded")
        if let o = ok {
            let alertConfirm = UIAlertController(title: "Warning", message: o, preferredStyle: .alert)
            alertConfirm.addAction(UIAlertAction(title: "Watch Now", style: .destructive, handler: { [weak self] _ in
                self?.watchAds(track)
            }))
            alertConfirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertConfirm, animated: true)
        }
        else {
            DaoladService.shared.waitcome(track)
        }
    }
    
    func openTrackOption(_ track: TrackObject, style: TrackStyle = .style3) {
        let optionView = TrackOptionView()
        optionView.style = style
        optionView.track = track
        optionView.onSelected = { [weak self] op in
            switch op {
            case .donwlaod:
                self?.waitcome(track)
                
            case .addToPlaylist:
                self?.addToPlaylist(track)
                
            case .favourite:
                self?.addOrDeleteFavourite(track)
                
            case .share:
                self?.shareFriends(track)
                
            case .delete:
                self?.deleteTrack(track)
                
            case .deleteFromPlaylist:
                self?.deleteFromPlaylist(track)
                
            }
        }
        optionView.show()
    }
    
    //
    private func deleteTrackOnDatabase(_ track: TrackObject, completion: @escaping () -> Void) {
        guard let realm = DBService.shared.realm else {
            completion()
            return
        }
        
        // remove track on database
        try? realm.write({
            let absolutePath = track.absolutePath
            
            realm.delete(track)
            
            // delete file
            if let url = absolutePath {
                try? FileManager.default.removeItem(at: url)
            }
            
            // notify and show alert
            NotificationCenter.default.post(name: .databaseChanged, object: nil)
            
            SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "Deleted the track")
            
            completion()
        })
    }
    
    func deleteTrack(_ track: TrackObject) {
        if let trackExists = MuPlayer.shared.tracks.first(where: { $0.id == track.id }) {
            if trackExists.id == MuPlayer.shared.currentTrack?.id {
                // stop player
                MuPlayer.shared.stop()
                
                // remove music from playlist
                MuPlayer.shared.deleteTrackOnPlaylist(track)
                UIWindow.keyWindow?.mainTabbar?.playerMain.deleteTrackOnPlaylist(track)
                
                // remove music on database
                self.deleteTrackOnDatabase(track) {
                    // re-play with first music on playlist
                    if let firstTrack = MuPlayer.shared.tracks.first {
                        UIWindow.keyWindow?.mainTabbar?.playerMain.play(with: firstTrack, playlist: MuPlayer.shared.tracks)
                    }
                }
                
            }
            else {
                // remove music from playlist
                let currentItem = MuPlayer.shared.currentTrack
                MuPlayer.shared.deleteTrackOnPlaylist(track)
                UIWindow.keyWindow?.mainTabbar?.playerMain.deleteTrackOnPlaylist(track)
                
                // remove music on database
                self.deleteTrackOnDatabase(track) {
                    // update position current item
                    if let item = currentItem {
                        MuPlayer.shared.updatePosition(item)
                    }
                }
            }
        }
        else {
            self.deleteTrackOnDatabase(track) { }
        }
    }
    
    //
    private func createNew(willSave track: TrackObject) {
        let makePlaylist = CreatePlaylistView()
        makePlaylist.onCreated = { [weak self] playlist in
            self?.addOrDelete(track: track, to: playlist)
        }
        makePlaylist.show()
    }
    
    private func addOrDelete(track: TrackObject, to playlist: PlaylistObject) {
        guard let realm = DBService.shared.realm else { return }
        
        guard let playlistUpdate = realm.objects(PlaylistObject.self).first(where: { $0.id == playlist.id }) else { return }
        
        if playlistUpdate.tracks.first(where: { $0.title == track.title || $0.trackId == track.trackId }) != nil {
            SwiftMessagesHelper.shared.showError(title: "Error", body: "The track already exists on the playlist")
            return
        }
        
        let trackUpdate = DBService.shared.findTrackOnDb(track)
        if trackUpdate == nil {
            try? realm.write({
                // add track to table
                realm.add(track)
                
                // add track to playlist
                playlistUpdate.tracks.append(track)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "The track has been added to the playlist")
            })
        }
        else {
            try? realm.write({
                // add track to playlist
                playlistUpdate.tracks.append(trackUpdate!)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Success", body: "The track has been added to the playlist")
            })
        }
    }
    
    func addToPlaylist(_ track: TrackObject) {
        let allPlaylist = ChoosePlaylistView()
        allPlaylist.onSelected = { [weak self] playlist in
            self?.addOrDelete(track: track, to: playlist)
        }
        allPlaylist.onCreateNew = { [weak self] in
            self?.createNew(willSave: track)
        }
        allPlaylist.show()
    }
    
    func shareFriends(_ track: TrackObject) {
        let message = "\(track.title) - \(track.subtitle)"
        
        guard let url = URL(string: "https://apps.apple.com/us/app/id\(AppSetting.id)") else { return }
        
        let objectsToShare: [Any] = [message, url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func sharePlaylistForFriends(_ pl: PlaylistObject) {
        let message = "\(pl.title) - \(pl.artist)"
        
        guard let url = URL(string: "https://apps.apple.com/us/app/id\(AppSetting.id)") else { return }
        
        let objectsToShare: [Any] = [message, url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func shareArtistForFriends(_ ar: ArtistObject) {
        let message = "\(ar.title) - \(ar.subscribers)"
        
        guard let url = URL(string: "https://apps.apple.com/us/app/id\(AppSetting.id)") else { return }
        
        let objectsToShare: [Any] = [message, url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}
