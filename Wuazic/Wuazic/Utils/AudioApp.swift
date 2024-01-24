import Foundation
import UIKit
class AudioApp{
   
    static func screenWidth() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return screenWidth
    }
    static func screenHeight() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return screenHeight
    }
    static func isAudioIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

}
