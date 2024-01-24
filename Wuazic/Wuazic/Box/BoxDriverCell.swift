
import UIKit
import BoxSDK

class BoxDriverCell: UICollectionViewCell {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var ivDownload: AudioImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setData(file: File) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy at HH:mm a"
        self.lbName.text = file.name
        self.lblContent.text = String(format: "Date Modified %@", formatter.string(from: file.modifiedAt ?? Date()))
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(file.name!)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            ivDownload.image = UIImage(named: "ic_downloaded")
        } else {
            ivDownload.image = UIImage(named: "ic_download")
        }
    }
}
