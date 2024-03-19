import UIKit
import AVFoundation
import StoreKit

class TabBarController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - property
    lazy var playerMain: PlayerMainController = {
        let view = PlayerMainController()
        view.modalPresentationStyle = .overFullScreen
        return view
    }()
    
    lazy var playerMini: PlayerMiniView = {
        let view = PlayerMiniView()
        return view
    }()
    
    var paddingBottom: CGFloat {
        let height = self.playerMini.frame.size.height
        return playerMini.isPresenting ? height + 10 : 0
    }
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupTabbarView()
        setupViewControllers()
        setupPlayerMini()
        playerMain.delegate = self
        
        NotificationCenter.default.addObserver(forName: .willShowPlayerMini, object: nil, queue: .main) { [weak self] _ in
            self?.showMiniPlayerIfNeed()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            self?.presentRatePopup()
        })
    }
    
    // MARK: - private
    private func presentRatePopup() {
        if !DataCommonModel.shared.isRating { return }
        
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.windows.first?.windowScene {
                if #available(iOS 14.0, *) {
                    SKStoreReviewController.requestReview(in: windowScene)
                } else {
                    SKStoreReviewController.requestReview()
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    private func setupTabbarView() {
        let backgroundTabbar = UIColor(rgb: 0x0A0909)
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundTabbar
            
            tabBar.standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        else {
            //Set the background color
            UITabBar.appearance().backgroundColor = backgroundTabbar
            tabBar.backgroundImage = UIImage()   //Clear background
        }
    }
    
    private func setupViewControllers() {
        let feature = FeatureController()
        feature.tabBarItem = UITabBarItem(title: nil,
                                          image: UIImage(imgName: "ic-tab-feature")?.withRenderingMode(.alwaysOriginal),
                                          selectedImage: UIImage(imgName: "ic-tab-feature-active")?.withRenderingMode(.alwaysOriginal))
        feature.tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
        
        let library = LibraryController()
        library.tabBarItem = UITabBarItem(title: nil,
                                          image: UIImage(imgName: "ic-tab-library")?.withRenderingMode(.alwaysOriginal),
                                          selectedImage: UIImage(imgName: "ic-tab-library-active")?.withRenderingMode(.alwaysOriginal))
        library.tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
        
        let search = SearchController()
        search.tabBarItem = UITabBarItem(title: nil,
                                         image: UIImage(imgName: "ic-tab-search")?.withRenderingMode(.alwaysOriginal),
                                         selectedImage: UIImage(imgName: "ic-tab-search-active")?.withRenderingMode(.alwaysOriginal))
        search.tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
        
        self.viewControllers = [BaseNavigationController(rootViewController: feature),
                                BaseNavigationController(rootViewController: library),
                                BaseNavigationController(rootViewController: search)]
    }
    
    private func openPlayerMain() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.present(self.playerMain, animated: true)
        }
    }
    
    private func setupPlayerMini() {
        playerMini.isPresenting = false
        playerMini.onClick = { [weak self] in
            self?.openPlayerMain()
        }
        playerMini.onPlayOrPause = { [weak self] in
            guard let self = self else { return }
            
            if MuPlayer.shared.isPlaying {
                MuPlayer.shared.pause()
            }
            else {
                MuPlayer.shared.resume()
            }
            
            self.playerMini.playinsg = MuPlayer.shared.isPlaying
        }
        playerMini.frame = CGRect(x: kPadding,
                                  y: self.view.frame.size.height,
                                  width: self.tabBar.frame.size.width - 2 * kPadding,
                                  height: PlayerMiniView.height)
        view.insertSubview(playerMini, belowSubview: self.tabBar)
    }
    
    // MARK: - public
    func showMiniPlayerIfNeed() {
        if playerMini.isPresenting { return }
        
        playerMini.playinsg = MuPlayer.shared.isPlaying
        playerMini.track = MuPlayer.shared.currentTrack
        playerMini.isPresenting = true
        UIView.animate(withDuration: 0.3) {
            NotificationCenter.default.post(name: .willShowPlayerMini, object: self.paddingBottom)
            
            var frame = self.playerMini.frame
            frame.origin.y = self.tabBar.frame.origin.y - PlayerMiniView.height - 5
            self.playerMini.frame = frame
        } completion: { _ in
            
        }
    }
    
    func hideMiniPlayer() {
        playerMini.isPresenting = false
        UIView.animate(withDuration: 0.3) {
            var frame = self.playerMini.frame
            frame.origin.y = self.tabBar.frame.origin.y
            self.playerMini.frame = frame
        } completion: { _ in
            NotificationCenter.default.post(name: .didHidePlayerMini, object: self.paddingBottom)
        }
    }
    
    func play(with track: TrackObject, tracks: [TrackObject]) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.showMiniPlayerIfNeed()
            
            self.playerMain.play(with: track, playlist: tracks)
            self.present(self.playerMain, animated: true) {
                LocalPushService.shared.requestAuthorization { _ in
                    LocalPushService.shared.addScheduleEveryday()
                }
            }
        }
    }
    
    // MARK: - event
    
}

extension TabBarController: PlayerMainDelegate {
    func preparePlay(track: TrackObject) {
        playerMini.track = track
    }
    
    func onTimeObserver(currentTime: Double, duration: Double) {
        if let track = MuPlayer.shared.currentTrack {
            playerMini.track = track
        }
        
        if playerMini.playinsg != MuPlayer.shared.isPlaying {
            playerMini.playinsg = MuPlayer.shared.isPlaying
        }
    }
}
