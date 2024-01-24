
import UIKit
@available(iOS 13.0, *)

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var naviVC: UINavigationController?
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        self.window?.windowScene =  windowScene
        let vc  = AudioHomeVC()
        naviVC = UINavigationController(rootViewController: vc)
        naviVC?.isNavigationBarHidden = true
        window?.rootViewController = naviVC
        self.window?.makeKeyAndVisible()
    }

}


