import UIKit

class ExtensionVC: UIViewController {
    var loadingView: AudioLoadingView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView = AudioLoadingView(frame: CGRect(x: 0, y: 0, width: AudioApp.screenWidth(), height: AudioApp.screenHeight()))
        loadingView.tag = 100
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showLoading() {
        self.view.addSubview(loadingView)
        loadingView.animationView.play()
    }
    
    func hideLoading() {
        loadingView.animationView.stop()
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        } else{
        }
    }
    func createMessageView(message: String?) {
     let messageController = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        messageController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            messageController.dismiss(animated: true, completion: nil)
     }))
     DispatchQueue.main.async { [weak self] in
       self?.present(messageController, animated: true, completion: nil)
     }
   }

}
