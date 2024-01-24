
import UIKit

class AudioHomeCell: UICollectionViewCell {

    @IBOutlet weak var constrantWitdh: NSLayoutConstraint!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if(AudioApp.isAudioIPad()) {
            constrantWitdh.constant = 48
            lbName.font = UIFont(name: "Inter-Medium", size: 20)
        }else {
            constrantWitdh.constant = 40
            lbName.font = UIFont(name: "Inter-Medium", size: 16)
        }
    }

}
