

import UIKit
import MediaPlayer
import AVFoundation
import StoreKit
import MobileCoreServices
import Photos
import Lottie
import GoogleMobileAds

class AudioHomeVC: ExtensionVC {
    @IBOutlet weak var vStudio: UIView!
    @IBOutlet weak var clvHome: UICollectionView!
    @IBOutlet weak var vTabStudio: AudioUiView!
    @IBOutlet weak var vTabHome: AudioUiView!
    @IBOutlet weak var vGradient: UIView!
    @IBOutlet weak var ivEmpty: UIView!
    @IBOutlet weak var tbvStudio: UITableView!
    @IBOutlet weak var lblEmpty: UILabel!
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var bannerBound: UIView!
    
    private let animationLoading = LottieAnimationView(name: "anim_empty")
    
    var bannerView: GADBannerView?
    
    var listFunctionHome: [HomeModel] = [HomeModel(icon: "ic_trim", name: "Trim"),
                                         HomeModel(icon: "ic_merge", name: "Merge"),
                                         HomeModel(icon: "ic_speed", name: "Speed"),
                                         HomeModel(icon: "ic_convert", name: "Convert"),
                                         HomeModel(icon: "ic_video_audio", name: "Video to Audio"),
                                         HomeModel(icon: "ic_reverse", name: "Reverse"),
                                         HomeModel(icon: "ic_mix", name: "Mix"),
                                         HomeModel(icon: "ic_rate", name: "Play list")]
    var colorTab: UIColor?
    var editType = EditType.videoToAudio
    var listStudio: [AudioSaveModel] = []
    var itemHomeSelect: HomeModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemHomeSelect = listFunctionHome[0]
        vGradient.bottomRadius(radius: 100)
        vGradient.backgroundColor = UIColor.setUpGradient(v: vGradient, listColor: [UIColor(hex: 0x131818), UIColor(hex: 0x393937)], isHorizontal: false)
        colorTab = UIColor.setUpGradient(v: vGradient, listColor: [UIColor(hex: 0xF2450E), UIColor(hex: 0xF8BF5E)], isHorizontal: true)
        vTabHome.backgroundColor = colorTab
        vTabStudio.backgroundColor = UIColor.clear
        
        tbvStudio.delegate = self
        tbvStudio.dataSource = self
        tbvStudio.register(UINib(nibName: "AudioMergeCell", bundle: nil), forCellReuseIdentifier: "AudioMergeCell")
        
        clvHome.delegate = self
        clvHome.dataSource = self
        clvHome.register(UINib(nibName: "AudioHomeCell", bundle: nil), forCellWithReuseIdentifier: "AudioHomeCell")
        loadBannerAdmod()
    }
    
    func loadBannerAdmod(){
        bannerView = GADBannerView(adSize: GADPortraitInlineAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width))
        bannerView?.adUnitID = DataCommonModel.shared.admob_banner
        bannerView?.rootViewController = self
        bannerView?.delegate = self
        bannerBound.addSubview(bannerView!)
        bannerView?.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)
        bannerView?.load(GADRequest())
    }
    
    func adDidReceive(_ height: CGFloat) {
        for constraint in self.bannerBound.constraints {
            if constraint.identifier == "heightConstraint" {
               constraint.constant = height
            }
        }
        bannerBound.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listStudio = AudioSaveModel.readFileFromJson()
        tbvStudio.reloadData()
        statusStudio()
        
        animationLoading.contentMode = .scaleAspectFit
        ivEmpty.addSubview(animationLoading)
        animationLoading.frame = CGRect(x: 0, y: 0, width: ivEmpty.frame.width, height: ivEmpty.frame.height)
        DispatchQueue.main.async {
            self.animationLoading.play(fromProgress: 0,
                                       toProgress: 1,
                                       loopMode: LottieLoopMode.loop,
                                       completion: { (finished) in})
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationLoading.pause()
        animationLoading.removeFromSuperview()
    }

    func selectAudioFile(isGallery: Bool = false) {
        let audioPopup = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        audioPopup.popoverPresentationController?.sourceView = self.vBottom
        if(isGallery) {
            audioPopup.addAction(UIAlertAction(title: "Import from Gallery", style: .default , handler:{ (UIAlertAction)in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false { return }
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.videoMaximumDuration = TimeInterval(240.0)
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.modalPresentationStyle = .custom
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }
      
        
        audioPopup.addAction(UIAlertAction(title: "iCloud", style: .default , handler:{ (UIAlertAction)in
            let pickerController = MPMediaPickerController(mediaTypes: .music)
            pickerController.delegate = self
            self.present(pickerController, animated: true)
        }))
        
        audioPopup.addAction(UIAlertAction(title: "My Rencent", style: .default , handler:{ (UIAlertAction)in
            let vc = AudioBottomSheet()
            vc.editType = self.editType
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        
        audioPopup.addAction(UIAlertAction(title: "Box Driver", style: .default , handler:{ (UIAlertAction)in
            let vc = AudioBoxDriverVC()
            vc.delegate = self
            vc.editType = self.editType
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        audioPopup.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                
        }))
        
        self.present(audioPopup, animated: true)
    }
    
    func checkFile(url: URL)-> Int {
        let type = checkMediaType(url: url)
        if(editType == EditType.videoToAudio) {
            if(type == "Audio") {
                self.createMessageView(message: "This function only supports video genres")
                return 0
            }
            return 1
        }else {
            if(type == "Video") {
                self.createMessageView(message: "This function only supports audio genres")
                return 0
            }
            return 1
        }
    }
    func statusStudio() {
        if(listStudio.count == 0) {
            tbvStudio.isHidden = true
            ivEmpty.isHidden = false
            lblEmpty.isHidden = false
        } else {
            tbvStudio.isHidden = false
            ivEmpty.isHidden = true
            lblEmpty.isHidden = true
        }
        if clvHome.isHidden == false {
            bannerBound.isHidden = false
        } else {
            if(listStudio.count == 0) {
                bannerBound.isHidden = true
            } else {
                bannerBound.isHidden = false
            }
        }
    }

    @IBAction func actionHome(_ sender: Any) {
        vTabHome.backgroundColor = colorTab
        vTabStudio.backgroundColor = UIColor.clear
        vStudio.isHidden = true
        clvHome.isHidden = false
        bannerBound.isHidden = false
    }
    
    @IBAction func actionStudio(_ sender: Any) {
        vTabHome.backgroundColor = UIColor.clear
        vTabStudio.backgroundColor = colorTab
        vStudio.isHidden = false
        clvHome.isHidden = true
        
        if(listStudio.count == 0) {
            bannerBound.isHidden = true
        } else {
            bannerBound.isHidden = false
        }
        
    }
}
extension AudioHomeVC: UITableViewDelegate, UITableViewDataSource,AudioMergeCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listStudio.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMergeCell") as! AudioMergeCell
        let item = listStudio[indexPath.row]
        cell.delegate = self
        cell.index = indexPath.row
        cell.lblName.text = item.name
        cell.lblDuration.text = formatSecondsToHHMM(seconds: item.duration)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func delete(row: Int) {
        let item = listStudio[row]
        AudioSaveModel.deleteFile(playableItem: item)
        listStudio.remove(at: row)
        tbvStudio.reloadData()
        statusStudio()
    }
    func select(row: Int) {
        let item = listStudio[row]
        let vc = EditAudioVC()
        vc.audioUrl = item.url
        vc.editType = EditType.normal
        vc.nameAudio = item.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension AudioHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listFunctionHome.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioHomeCell", for: indexPath) as! AudioHomeCell
        let item = listFunctionHome[indexPath.row]
        cell.ivIcon.image = UIImage(named: item.icon)
        cell.lbName.text = item.name
        if indexPath.row == 0 {
            cell.gradientView.startColor = UIColor.init(hex: 0xE05159)
            cell.gradientView.endColor = UIColor.init(hex: 0xFF1673)
        } else if indexPath.row == 1 {
            cell.gradientView.startColor = UIColor.init(hex: 0x51E0C6)
            cell.gradientView.endColor = UIColor.init(hex: 0x1FB3F5)
        } else if indexPath.row == 2 {
            cell.gradientView.startColor = UIColor.init(hex: 0xE0DA51)
            cell.gradientView.endColor = UIColor.init(hex: 0xF9871F)
        } else if indexPath.row == 3 {
            cell.gradientView.startColor = UIColor.init(hex: 0xE265F6)
            cell.gradientView.endColor = UIColor.init(hex: 0x9816FF)
        } else if indexPath.row == 4 {
            cell.gradientView.startColor = UIColor.init(hex: 0x14DE95)
            cell.gradientView.endColor = UIColor.init(hex: 0x06967F)
        } else if indexPath.row == 5 {
            cell.gradientView.startColor = UIColor.init(hex: 0x0047FF)
            cell.gradientView.endColor = UIColor.init(hex: 0x0EB4CB)
        } else if indexPath.row == 6 {
            cell.gradientView.startColor = UIColor.init(hex: 0x4C98F0)
            cell.gradientView.endColor = UIColor.init(hex: 0x342AA5)
        } else if indexPath.row == 7 {
            cell.gradientView.startColor = UIColor.init(hex: 0xFC7A30)
            cell.gradientView.endColor = UIColor.init(hex: 0xED653A)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(AudioApp.isAudioIPad()) {
            let size = clvHome.frame.width/4-16
            return CGSize(width: size, height: size)
        }
        let size = clvHome.frame.width/3-16
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = listFunctionHome[indexPath.row]
        itemHomeSelect = item
        if(itemHomeSelect.name == "Trim") {
            editType = EditType.trim
            selectAudioFile()
        }else if(itemHomeSelect.name == "Speed") {
            editType = EditType.speed
            selectAudioFile()
        }else if(itemHomeSelect.name == "Merge") {
            editType = EditType.merge
            selectAudioFile()
        }else if(itemHomeSelect.name == "Convert") {
            editType = EditType.convert
            selectAudioFile()
        }else if(itemHomeSelect.name == "Video to Audio") {
            editType = EditType.videoToAudio
            selectAudioFile(isGallery: true)
        }else if(itemHomeSelect.name == "Reverse") {
            editType = EditType.reverse
            selectAudioFile()
        }else if(itemHomeSelect.name == "Mix") {
            editType = EditType.mix
            selectAudioFile()
        }else {
            let vc = AudioBottomSheet()
            vc.editType = EditType.normal
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func nextScreenConvert(type: String, audioUrl: URL?) {
        let vc = EditAudioVC()
        vc.editType = EditType.convert
        vc.audioUrl = audioUrl
        vc.typeFile = type
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    func convertVideoToAudio(videoUrl: URL) {
        FFmpegUtils.getInstance.delegate = self
        FFmpegUtils.getInstance.convertVideoToAudioCmd(inputUrl: videoUrl)
    }
    func reverseAudio(videoUrl: URL) {
        FFmpegUtils.getInstance.delegate = self
        FFmpegUtils.getInstance.reverseAudioCmd(inputUrl: videoUrl)
    }
    
}
extension AudioHomeVC: MPMediaPickerControllerDelegate {
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let item: MPMediaItem = mediaItemCollection.items[0]
        let pathURL: URL? = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL
        if pathURL == nil {
                
        }

        let name1 = item.value(forProperty: MPMediaItemPropertyTitle) as! String
        let newName = name1.replacingOccurrences(of: " ", with: "")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("\(newName).mp4")
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error as NSError {
            print(error.debugDescription)
        }
        let exportSession = AVAssetExportSession(asset: AVAsset(url: item.assetURL!), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = .m4a
        exportSession?.outputURL = fileURL
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously(completionHandler: { () -> Void in
            if (exportSession!.status == AVAssetExportSession.Status.completed){
                do {
                    let downloadOnDevicePath = "\(newName).mp4"
                    var listSongDownload = AudioSaveModel.readWifiTransFileJson()
                    
                    let audioModel = AudioSaveModel()
                    audioModel._id = "\(Date().timeIntervalSince1970)"
                    audioModel.name = name1
                    audioModel.downloadOnDevicePath = downloadOnDevicePath
                    let outputUrl = getUrlFromName(downloadOnDevicePath: downloadOnDevicePath)
                    let type = checkMediaType(url: outputUrl)
                    if(type == "Audio") {
                        listSongDownload.append(audioModel)
                        let jsonData = try JSONSerialization.data(withJSONObject: listSongDownload.map{$0.toString()}, options: JSONSerialization.WritingOptions.prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                            writeString(aString: jsonString, fileName: WIFI_TRANS_JSON)
                        }
                    }
                   
                    DispatchQueue.main.async {
                        let next = self.checkFile(url: outputUrl)
                        if(next == 0) {
                            return
                        }else {
                            audioModel.url = outputUrl
                            if(self.editType == EditType.trim) {
                                 let vc = EditAudioVC()
                                 vc.audioUrl = outputUrl
                                 vc.editType = self.editType
                                 self.navigationController?.pushViewController(vc, animated: true)
                             }else if(self.editType == EditType.speed) {
                                 let vc = EditAudioVC()
                                 vc.audioUrl = outputUrl
                                 vc.editType = self.editType
                                 self.navigationController?.pushViewController(vc, animated: true)
                             }else if(self.editType == EditType.merge) {
                                 var listUrl: [AudioSaveModel] = []
                                 let vc = AudioMergeVC()
                                 listUrl.append(audioModel)
                                 vc.listUrl = listUrl
                                 vc.audioUrl = outputUrl
                                 self.navigationController?.pushViewController(vc, animated: true)
                             }else if(self.editType == EditType.convert) {
                                 var type = ""
                                 let alert = UIAlertController(title: "Convert", message: nil, preferredStyle: .actionSheet)
                                 alert.popoverPresentationController?.sourceView = self.vBottom
                                 alert.addAction(UIAlertAction(title: "Mp3", style: .default , handler:{ [self] (UIAlertAction)in
                                     type = "mp3"
                                     self.nextScreenConvert(type: type, audioUrl: outputUrl)
                                 }))
                                     
                                 alert.addAction(UIAlertAction(title: "M4a", style: .default , handler:{ (UIAlertAction)in
                                    type = "m4a"
                                     self.nextScreenConvert(type: type, audioUrl: outputUrl)
                                 }))
                                 
                                 alert.addAction(UIAlertAction(title: "WAV", style: .default , handler:{ (UIAlertAction)in
                                     type = "wav"
                                     self.nextScreenConvert(type: type, audioUrl: outputUrl)
                                 }))
                                     
                                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                                     type = ""
                                 }))
                                 
                                 self.present(alert, animated: true)
                             }else if(self.editType == EditType.videoToAudio) {
                                 self.showLoading()
                                 self.convertVideoToAudio(videoUrl: outputUrl)
                             }else if(self.editType == EditType.reverse) {
                                 self.showLoading()
                                 self.reverseAudio(videoUrl: outputUrl)
                             }else if(self.editType == EditType.mix) {
                                 var listUrl: [AudioSaveModel] = []
                                 let vc = AudioMergeVC()
                                 listUrl.append(audioModel)
                                 vc.listUrl = listUrl
                                 vc.audioUrl = outputUrl
                                 self.navigationController?.pushViewController(vc, animated: true)
                             }
                        }
                        
                    }
                    
                } catch {
                    print("\(error)")
                }
            } else if (exportSession!.status == AVAssetExportSession.Status.cancelled) {
            } else {
            }
        })
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}

extension AudioHomeVC: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let movieUrl = info[.mediaURL] as? URL else { return }
        do {
            let videoData = try Data(contentsOf: movieUrl)
            let name = "\(movieUrl.deletingPathExtension().lastPathComponent).\(movieUrl.pathExtension)"
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(name.replacingOccurrences(of: " ", with: ""))
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                print(error.debugDescription)
            }
            try videoData.write(to: fileURL)
            let downloadOnDevicePath = name.replacingOccurrences(of: " ", with: "")
            var listSongDownload = AudioSaveModel.readWifiTransFileJson()
            let audioModel = AudioSaveModel()
            audioModel._id = "\(Date().timeIntervalSince1970)"
            audioModel.name = name
            audioModel.downloadOnDevicePath = downloadOnDevicePath
            let outputUrl = getUrlFromName(downloadOnDevicePath: downloadOnDevicePath)
            let type = checkMediaType(url: outputUrl)
            if(type == "Audio") {
                listSongDownload.append(audioModel)
                let jsonData = try JSONSerialization.data(withJSONObject: listSongDownload.map{$0.toString()}, options: JSONSerialization.WritingOptions.prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    writeString(aString: jsonString, fileName: WIFI_TRANS_JSON)
                }
            }
            DispatchQueue.main.async {
                let next = self.checkFile(url: outputUrl)
                if(next == 0) {
                    return
                }else {
                    audioModel.url = outputUrl
                    if(self.editType == EditType.trim) {
                         let vc = EditAudioVC()
                         vc.audioUrl = outputUrl
                         vc.editType = self.editType
                         self.navigationController?.pushViewController(vc, animated: true)
                     }else if(self.editType == EditType.speed) {
                         let vc = EditAudioVC()
                         vc.audioUrl = outputUrl
                         vc.editType = self.editType
                         self.navigationController?.pushViewController(vc, animated: true)
                     }else if(self.editType == EditType.merge) {
                         var listUrl: [AudioSaveModel] = []
                         let vc = AudioMergeVC()
                         listUrl.append(audioModel)
                         vc.listUrl = listUrl
                         vc.audioUrl = outputUrl
                         self.navigationController?.pushViewController(vc, animated: true)
                     }else if(self.editType == EditType.convert) {
                         var type = ""
                         let alert = UIAlertController(title: "Convert", message: nil, preferredStyle: .actionSheet)
                         alert.popoverPresentationController?.sourceView = self.vBottom
                         alert.addAction(UIAlertAction(title: "Mp3", style: .default , handler:{ [self] (UIAlertAction)in
                             type = "mp3"
                             self.nextScreenConvert(type: type, audioUrl: outputUrl)
                         }))
                             
                         alert.addAction(UIAlertAction(title: "M4a", style: .default , handler:{ (UIAlertAction)in
                            type = "m4a"
                             self.nextScreenConvert(type: type, audioUrl: outputUrl)
                         }))
                         
                         alert.addAction(UIAlertAction(title: "WAV", style: .default , handler:{ (UIAlertAction)in
                             type = "wav"
                             self.nextScreenConvert(type: type, audioUrl: outputUrl)
                         }))
                             
                         alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                             type = ""
                         }))
                         
                         self.present(alert, animated: true)
                     }else if(self.editType == EditType.videoToAudio) {
                         self.showLoading()
                         self.convertVideoToAudio(videoUrl: outputUrl)
                     }else if(self.editType == EditType.reverse) {
                         self.showLoading()
                         self.reverseAudio(videoUrl: outputUrl)
                     }else if(self.editType == EditType.mix) {
                         var listUrl: [AudioSaveModel] = []
                         let vc = AudioMergeVC()
                         listUrl.append(audioModel)
                         vc.listUrl = listUrl
                         vc.audioUrl = outputUrl
                         self.navigationController?.pushViewController(vc, animated: true)
                     }
                }
            }
            
        } catch {
            print("\(error)")
        }
    }
}

extension AudioHomeVC: UINavigationControllerDelegate {

}
extension AudioHomeVC: FFmpegUtilDelegate {
    func ffmpegFinish(url: URL?, errorCode: Int) {
        if(errorCode == 0) {
            if(editType == EditType.videoToAudio) {
                DispatchQueue.main.sync {
                    if let audioUrl = url {
                        self.hideLoading()
                        let vc = EditAudioVC()
                        vc.audioUrl = audioUrl
                        vc.editType = EditType.videoToAudio
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else if(editType == EditType.reverse) {
                DispatchQueue.main.sync {
                    if let audioUrl = url {
                        self.hideLoading()
                        let vc = EditAudioVC()
                        vc.audioUrl = audioUrl
                        vc.editType = EditType.reverse
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }else {
            DispatchQueue.main.sync {
                self.hideLoading()
                MessagesAudio.shared.showMessage(messageType: .error, message: "The file is corrupted or not supported. Please choose another file")
            }
        }
      
    }
}
extension AudioHomeVC: AudioBottomSheetDelegate {
    func selectAudioSheet(audioModel: AudioSaveModel) {
        if let outputUrl = audioModel.url {
            if(itemHomeSelect.name == "Trim") {
                let vc = EditAudioVC()
                vc.audioUrl = outputUrl
                vc.editType = EditType.trim
                self.navigationController?.pushViewController(vc, animated: true)
            }else if(itemHomeSelect.name == "Speed") {
                let vc = EditAudioVC()
                vc.audioUrl = outputUrl
                vc.editType = EditType.speed
                self.navigationController?.pushViewController(vc, animated: true)
            }else if(itemHomeSelect.name == "Merge") {
                var listUrl: [AudioSaveModel] = []
                let vc = AudioMergeVC()
                listUrl.append(audioModel)
                vc.listUrl = listUrl
                vc.audioUrl = outputUrl
                self.navigationController?.pushViewController(vc, animated: true)
            }else if(itemHomeSelect.name == "Convert") {
                var type = ""
                let alert = UIAlertController(title: "Convert", message: nil, preferredStyle: .actionSheet)
                alert.popoverPresentationController?.sourceView = self.vBottom
                alert.addAction(UIAlertAction(title: "Mp3", style: .default , handler:{ [self] (UIAlertAction)in
                    type = "mp3"
                    self.nextScreenConvert(type: type, audioUrl: outputUrl)
                }))
                    
                alert.addAction(UIAlertAction(title: "M4a", style: .default , handler:{ (UIAlertAction)in
                   type = "m4a"
                    self.nextScreenConvert(type: type, audioUrl: outputUrl)
                }))
                
                alert.addAction(UIAlertAction(title: "WAV", style: .default , handler:{ (UIAlertAction)in
                    type = "wav"
                    self.nextScreenConvert(type: type, audioUrl: outputUrl)
                }))
                    
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                    type = ""
                }))
                
                self.present(alert, animated: true)
            }else if(itemHomeSelect.name == "Video to Audio") {
                self.showLoading()
                editType = EditType.videoToAudio
                convertVideoToAudio(videoUrl: outputUrl)
            }else if(itemHomeSelect.name == "Reverse") {
                self.showLoading()
                editType = EditType.reverse
                reverseAudio(videoUrl: outputUrl)
            }else if(itemHomeSelect.name == "Mix") {
                var listUrl: [AudioSaveModel] = []
                let vc = AudioMergeVC()
                listUrl.append(audioModel)
                vc.listUrl = listUrl
                vc.audioUrl = outputUrl
                vc.editType = EditType.mix
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
extension AudioHomeVC: AudioBoxDriverDelegate {
    func selectItemCallback(editType: EditType, url: URL) {
        let next = checkFile(url: url)
        if(next == 0){
            return
        }else {
            let outputUrl = url
            let rencentAudios = AudioSaveModel.readWifiTransFileJson()
            var audioModel: AudioSaveModel?
            rencentAudios.forEach { audioSaveModel in
                if(audioSaveModel.url.path == url.path){
                    audioModel = audioSaveModel
                }
            }

            if(itemHomeSelect.name == "Trim") {
                let vc = EditAudioVC()
                vc.audioUrl = outputUrl
                vc.editType = editType
                self.navigationController?.pushViewController(vc, animated: true)
            }else if(itemHomeSelect.name == "Speed") {
                let vc = EditAudioVC()
                vc.audioUrl = outputUrl
                vc.editType = editType
                self.navigationController?.pushViewController(vc, animated: true)
            }else if(itemHomeSelect.name == "Merge") {
                var listUrl: [AudioSaveModel] = []
                let vc = AudioMergeVC()
                if let audioModel = audioModel {
                    listUrl.append(audioModel)
                    vc.listUrl = listUrl
                    vc.audioUrl = outputUrl
                    self.navigationController?.pushViewController(vc, animated: true)
                }
               
            }else if(itemHomeSelect.name == "Convert") {
                var type = ""
                let alert = UIAlertController(title: "Convert", message: nil, preferredStyle: .actionSheet)
                alert.popoverPresentationController?.sourceView = self.vBottom
                alert.addAction(UIAlertAction(title: "Mp3", style: .default , handler:{ [self] (UIAlertAction)in
                    type = "mp3"
                    self.nextScreenConvert(type: type, audioUrl: outputUrl)
                }))
                    
                alert.addAction(UIAlertAction(title: "M4a", style: .default , handler:{ (UIAlertAction)in
                   type = "m4a"
                    self.nextScreenConvert(type: type, audioUrl: outputUrl)
                }))
                
                alert.addAction(UIAlertAction(title: "WAV", style: .default , handler:{ (UIAlertAction)in
                    type = "wav"
                    self.nextScreenConvert(type: type, audioUrl: outputUrl)
                }))
                    
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
                    type = ""
                }))
                
                self.present(alert, animated: true)
            }else if(itemHomeSelect.name == "Video to Audio") {
                self.showLoading()
                self.editType = editType
                convertVideoToAudio(videoUrl: outputUrl)
            }else if(itemHomeSelect.name == "Reverse") {
                self.showLoading()
                self.editType = editType
                reverseAudio(videoUrl: outputUrl)
            }else if(itemHomeSelect.name == "Mix") {
                var listUrl: [AudioSaveModel] = []
                let vc = AudioMergeVC()
                if let audioModel = audioModel {
                    listUrl.append(audioModel)
                    vc.listUrl = listUrl
                    vc.audioUrl = outputUrl
                    vc.editType = editType
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
    }
}

extension AudioHomeVC: GADBannerViewDelegate {
    //for banner
    /// Tells the delegate an ad request loaded an ad.
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if bannerBound != nil{
            bannerBound.isHidden = false
            adDidReceive(bannerView.frame.size.height)
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        if bannerBound != nil{
            bannerBound.isHidden = true
        }
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        if bannerBound != nil{
            bannerBound.isHidden = true
        }
        loadBannerAdmod()
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
}
