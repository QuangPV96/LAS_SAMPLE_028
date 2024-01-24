

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var naviVC: UINavigationController?
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc  = AudioHomeVC()
        naviVC = UINavigationController(rootViewController: vc)
        naviVC?.isNavigationBarHidden = true
        window?.rootViewController = naviVC
        window?.makeKeyAndVisible()
        return true
    }

}
