

import UIKit
import BoxSDK
import AuthenticationServices
protocol AudioBoxDriverDelegate {
    func selectItemCallback(editType: EditType, url: URL)
}
class AudioBoxDriverVC: ExtensionVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var clvBox: UICollectionView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var vDownload: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    var editType: EditType = EditType.normal
    var delegate: AudioBoxDriverDelegate?
    var files: [File] = [File]()
    var boxDriverService = AudioBoxDriverService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clvBox.delegate = self
        clvBox.dataSource = self
        clvBox.register(UINib(nibName: "BoxDriverCell", bundle: .main), forCellWithReuseIdentifier: "BoxDriverCell")
        
        boxDriverService.awake()
        boxDriverService.signIn { isSuccess in
            if isSuccess == true {
                self.btnLogin.setTitle("Logout", for: .normal)
                self.boxDriverService.requestCurrentAccount { user in
                    DispatchQueue.main.async {
                        self.clvBox.reloadData()

                    }
                    self.lbTitle.text = user?.name
                }
                self.boxDriverService.search(AudioBoxEnum.all) { listFile, error in
                    self.files = listFile
                    DispatchQueue.main.async {
                        self.clvBox.reloadData()

                    }
                }
            }
        }
    }

    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionLogout(_ sender: Any) {
        if (btnLogin.title(for: .normal) == "Logout") {
            boxDriverService.signOut()
            files = [File]()
            clvBox.reloadData()
            btnLogin.setTitle("Login", for: .normal)
        } else {
            boxDriverService.signIn { isSuccess in
                self.btnLogin.setTitle("Logout", for: .normal)
                self.boxDriverService.requestCurrentAccount { user in
                    self.lbTitle.text = user?.name
                }
                self.boxDriverService.search(AudioBoxEnum.all) { listFile, error in
                    self.files = listFile
                    DispatchQueue.main.async {
                        self.clvBox.reloadData()

                    }
                }
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoxDriverCell", for: indexPath) as! BoxDriverCell
        cell.setData(file: files[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width-20, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(files[index].name!)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            self.navigationController?.popViewController(animated: true)
            if(self.delegate != nil) {
                self.delegate?.selectItemCallback(editType: editType, url: fileURL)
            }
        } else {
            vDownload.isHidden = false
            boxDriverService.download(files[index]) { progress in
                DispatchQueue.main.async {
                    self.progressBar.progress = Float(progress.completedUnitCount*100/progress.totalUnitCount)
                }
                
            } completion: { status, urlString in
                if status == true {
                    self.vDownload.isHidden = true
                    do {
                        let downloadOnDevicePath = urlString
                        var listSongDownload = AudioSaveModel.readWifiTransFileJson()
                        
                        let playableItem = AudioSaveModel()
                        playableItem._id = "\(Date().timeIntervalSince1970)"
                        playableItem.name = self.files[index].name!
                        playableItem.downloadOnDevicePath = downloadOnDevicePath
                        let newUrl = getUrlFromName(downloadOnDevicePath: downloadOnDevicePath)
                        if(newUrl != nil) {
                            let type = checkMediaType(url: newUrl)
                            if(type == "Audio") {
                                listSongDownload.append(playableItem)
                                let jsonData = try JSONSerialization.data(withJSONObject: listSongDownload.map{$0.toString()}, options: JSONSerialization.WritingOptions.prettyPrinted)
                                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                                    writeString(aString: jsonString, fileName: WIFI_TRANS_JSON)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                                if(self.delegate != nil) {
                                    self.delegate?.selectItemCallback(editType: self.editType, url: newUrl)
                                }
                            }
                        }
                      
                       
                    } catch {
                        print("\(error)")
                    }
                } else {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        print("\(error)")
                    }
                    
                    self.vDownload.isHidden = true
                    MessagesAudio.shared.showMessage(messageType: .error, message: "Download Failed")
                }
            }
        }
    }

}
