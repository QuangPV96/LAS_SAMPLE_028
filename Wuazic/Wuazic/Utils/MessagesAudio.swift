import Foundation
import SwiftMessages

class MessagesAudio {
    static let shared = MessagesAudio()
    let successSwiftMessage = SwiftMessages()
    let timeSwiftMessage = SwiftMessages()
    let freeCastSwiftMessage = SwiftMessages()
    let commonMessageInstant = SwiftMessages()
    let reviewSwifMessage = SwiftMessages()
    let premiumSwiftMessage = SwiftMessages()
    let approachViewMessage = SwiftMessages()
    
    var sharedConfig: SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        config.preferredStatusBarStyle = .lightContent
        return config
    }
}

extension MessagesAudio {
    func showMessage(messageType type: Theme, withTitle title: String = "", message: String, completion: (() -> Void)? = nil, duration: SwiftMessages.Duration = .seconds(seconds: 3)) {
        var config = sharedConfig
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(type)
        view.button?.isHidden = true
        view.configureContent(title: title, body: message)
        view.configureDropShadow()
        config.duration = duration
        config.eventListeners = [{ event in
            switch event {
            case .didHide:
                completion?()
            default:
                break
            }
            }]
        commonMessageInstant.show(config: config, view: view)
    }
    
    func showMessage(messageType type: Theme, withTitle title: String = "", message: String, completion: (() -> Void)? = nil, duration: SwiftMessages.Duration = .seconds(seconds: 3), config: SwiftMessages.Config) {
        var config = config
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(type)
        view.button?.isHidden = true
        view.configureContent(title: title, body: message)
        view.configureDropShadow()
        config.duration = duration
        config.eventListeners = [{ event in
            switch event {
            case .didHide:
                completion?()
            default:
                break
            }
            }]
        commonMessageInstant.show(config: config, view: view)
    }
    
    
    func quickSuccessMessageCenter(message: String) {
        
    }
    
    func showNoInternetConnection() {
        let viewID = "no-internet-connection"
        let currentView = SwiftMessages.current(id: viewID)
        // Guard message currently is not shown
        guard currentView == nil else { return }
        var config = SwiftMessages.Config()
        config.dimMode = .none
        config.presentationStyle = .top
        //        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .forever
        
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.error)
        view.configureContent(body: "Error connection")
        view.id = viewID
        SwiftMessages.sharedInstance.show(config: config, view: view)
    }
    
    func hideNoInternetConnection() {
        SwiftMessages.hide(id: "no-internet-connection")
    }
}
