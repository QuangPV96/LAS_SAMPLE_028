

import UIKit
protocol AudioMergeCellDelegate {
    func delete(row: Int)
    func select(row: Int)
}
class AudioMergeCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var ivThumb: AudioImageView!
    var delegate: AudioMergeCellDelegate?
    var index: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionDelete(_ sender: Any) {
        if(self.delegate != nil) {
            self.delegate?.delete(row: index)
        }
    }
    
    @IBAction func actionSelect(_ sender: Any) {
        if(self.delegate != nil) {
            self.delegate?.select(row: index)
        }
    }
}
