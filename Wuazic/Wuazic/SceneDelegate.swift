
import UIKit
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    static var shared: SceneDelegate?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {return}
        SceneDelegate.shared = self
        self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        self.window?.windowScene =  windowScene
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let naviVC = UINavigationController(rootViewController: StartVC())
        naviVC.isNavigationBarHidden = true
        naviVC.navigationBar.barStyle = .default
        self.window?.rootViewController = naviVC
        window?.overrideUserInterfaceStyle = .light
        self.window?.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
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

