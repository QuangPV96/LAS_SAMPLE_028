import UIKit
import AVFAudio
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barStyle = .default
        getIdAdses()
        
        DBService.shared.setup()
        ApplovinHandle.shared.awake {
            ApplovinOpenHandle.shared.awake()
        }
        
        application.beginReceivingRemoteControlEvents()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
        } catch let error as NSError {
            print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
        setupRootVC()
        return true
    }
    
    private func getIdAdses() {
        guard let url = URL(string: AppSetting.list_ads) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let newData = data else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: newData, options: .mutableContainers) as? [String:Any] {
                for (key, value) in json {
                    UserDefaults.standard.set(value, forKey: key)
                    UserDefaults.standard.synchronize()
                }
                DBService.shared.saveTimeAdsesLatest()
            }
        }.resume()
    }
    
    func setupRootVC() {
        let naviVC = UINavigationController(rootViewController: StartVC())
        naviVC.isNavigationBarHidden = true
        naviVC.navigationBar.barStyle = .default
        window?.rootViewController = naviVC
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        window?.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) else {
            return
        }
        if rootViewController is StartVC {
            return
        }
        AdmodOpen.shared.tryToPresentAd()
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        guard rootViewController != nil else { return nil }
        
        guard !(rootViewController.isKind(of: (UITabBarController).self)) else{
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        }
        guard !(rootViewController.isKind(of:(UINavigationController).self)) else{
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        }
        guard !(rootViewController.presentedViewController != nil) else {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
}

