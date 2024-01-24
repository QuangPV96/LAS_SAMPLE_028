import Foundation
import UIKit
import Lottie
class AudioLoadingView: UIView {
    
    var animationView: LottieAnimationView = LottieAnimationView(name: "loading")

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let nib = UINib(nibName: "AudioLoadingView", bundle: nil)
        if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
            settingAnimation(view: view)
        }
    }
    private func settingAnimation(view: UIView) {
          animationView.frame = CGRect(x: AudioApp.screenWidth()/2 - 75, y: AudioApp.screenHeight()/2 - 75, width: 150, height: 150)
          animationView.contentMode = .scaleAspectFit
          animationView.loopMode = .loop
          view.addSubview(animationView)
    }
}
