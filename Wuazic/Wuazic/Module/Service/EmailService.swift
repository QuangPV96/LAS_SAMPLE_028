import UIKit
import MessageUI

class EmailService: NSObject {
    func compose(controller: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([AppSetting.email])
            
            controller.present(composeVC, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Notification", message: "You have not set up an email.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: nil))
            if let popover = alert.popoverPresentationController {
                popover.sourceView = controller.view
                popover.sourceRect = controller.view.bounds
            }
            controller.present(alert, animated: true, completion: nil)
        }
    }
}

extension EmailService: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
