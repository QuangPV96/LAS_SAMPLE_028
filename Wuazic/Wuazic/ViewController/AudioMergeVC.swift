
import UIKit
import AVFAudio

class AudioMergeVC: ExtensionVC {

    @IBOutlet weak var tbvAudio: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vSlider: AudioSlider!
    @IBOutlet weak var lbTimeEnd: UILabel!
    @IBOutlet weak var lbTimeCurrent: UILabel!
    @IBOutlet weak var ivTogether: UIImageView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblTotal: UILabel!
    
    var editType = EditType.merge
    var listUrl: [AudioSaveModel] = []
    var displayLink: CADisplayLink!
    var audioUrl: URL?
    var audioAddFakeUrl: URL?
    var audioPlayer: AVAudioPlayer?
    var isPreview = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if(editType == EditType.mix) {
            lblTitle.text = "Mix audio"
        }
        audioAddFakeUrl = audioUrl
        FFmpegUtils.getInstance.delegate = self
        
        tbvAudio.delegate = self
        tbvAudio.dataSource = self
        tbvAudio.register(UINib(nibName: "AudioMergeCell", bundle: nil), forCellReuseIdentifier: "AudioMergeCell")
        setLabelTotal()
        playAudio()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let audioPlayer = self.audioPlayer {
            if(audioPlayer.isPlaying) {
                audioPlayer.stop()
                self.ivTogether.image = UIImage(named: "ic_play")
                self.audioPlayer = nil
            }
        }
    }
 
    
    func setLabelTotal() {
        lblTotal.text = "select \(listUrl.count) out of 4 items"
    }
    func convertToListUrl()-> [URL]? {
        let list = listUrl.map { model in
            return model.url
        }.compactMap { $0 }
        return list
    }
   
    @objc func updateSliderAndTime() {
        // seekbar audio player
        DispatchQueue.global().async { [self] in
            if let audioPlayer = self.audioPlayer {
                let newCurrent = audioPlayer.currentTime
                let currentTime = Int(newCurrent * 1000)
                let minutes = currentTime / (60 * 1000)
                let seconds = (currentTime % (60 * 1000)) / 1000
                let milliseconds = currentTime % 1000
                let value = Float(audioPlayer.currentTime)
                let current = String(format: "%02d:%02d", minutes, seconds, milliseconds)
                DispatchQueue.main.async {
                    self.vSlider.value = value
                    self.lbTimeCurrent.text = current
                }
            }
        }
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        if self.audioPlayer != nil {
            seekToAudio(value: Double(sender.value))
        }else {
            playAudio()
        }
    }

    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionSave(_ sender: Any) {
        if let audioUrl = self.audioUrl {
            AudioSaveModel.saveAudioToDocument(urlSave: audioUrl) { outputUrl in
                let vc = EditAudioVC()
                vc.editType = editType
                vc.audioUrl = audioUrl
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func actionAdd(_ sender: Any) {
        let vc = AudioBottomSheet()
        vc.editType = self.editType
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func actionPrevious(_ sender: Any) {
        if let audioPlayer = self.audioPlayer {
            let newCurrent = audioPlayer.currentTime - 5
            audioPlayer.currentTime = newCurrent
            let currentTime = Int(newCurrent * 1000)
            let minutes = currentTime / (60 * 1000)
            let seconds = (currentTime % (60 * 1000)) / 1000
            let milliseconds = currentTime % 1000
            let value = Float(audioPlayer.currentTime)
            let current = String(format: "%02d:%02d", minutes, seconds, milliseconds)
            DispatchQueue.main.async {
                self.vSlider.value = value
                self.lbTimeCurrent.text = current
            }
        }
    }
    
    @IBAction func actionTogether(_ sender: Any) {
        playAudio()
    }
    
    @IBAction func actionSkip(_ sender: Any) {
        if let audioPlayer = self.audioPlayer {
            let newCurrent = audioPlayer.currentTime + 5
            audioPlayer.currentTime = newCurrent
            let currentTime = Int(newCurrent * 1000)
            let minutes = currentTime / (60 * 1000)
            let seconds = (currentTime % (60 * 1000)) / 1000
            let milliseconds = currentTime % 1000
            let value = Float(audioPlayer.currentTime)
            let current = String(format: "%02d:%02d", minutes, seconds, milliseconds)
            DispatchQueue.main.async {
                self.vSlider.value = value
                self.lbTimeCurrent.text = current
            }
        }
    }
    
    @IBAction func actionPreview(_ sender: Any) {
        let list = convertToListUrl()
        if(list != nil) {
            if(editType == EditType.merge) {
                if(list!.count > 1) {
                    pauseAudio()
                    self.showLoading()
                    FFmpegUtils.getInstance.mergeAudioCmd(audioUrls: list!)
                }else {
                    // print
                    self.createMessageView(message: "You need to select two or more audios to perform the audio merge function")
                }
            }else {
                if(list!.count > 1) {
                    pauseAudio()
                    self.showLoading()
                    FFmpegUtils.getInstance.mixAudioCmd(inputURLs: list!)
                }else {
                    // print
                    self.createMessageView(message: "You need to select two or more audios to perform the audio mix function")
                }
            }
        }
       
    }
}

extension AudioMergeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUrl.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMergeCell") as! AudioMergeCell
        let item = listUrl[indexPath.row]
        cell.delegate = self
        cell.index = indexPath.row
        cell.lblName.text = item.name
        cell.lblDuration.text = formatSecondsToHHMM(seconds: item.duration)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
extension AudioMergeVC {
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateSliderAndTime))
        displayLink.add(to: .main, forMode: .common)
    }
    
    func playAudio() {
        if(audioPlayer == nil) {
            setupDisplayLink()
            if let audioUrl = self.audioUrl {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                    let duration = Float(audioPlayer?.duration ?? 0)
                    let minutes = Int(duration) / 60
                    let seconds = Int(duration) % 60
                    
                    let timeEnd = String(format: "%02d:%02d", minutes, seconds)
                    lbTimeEnd.text = timeEnd
                    vSlider.maximumValue = duration
                    ivTogether.image = UIImage(named: "ic_pause")
                } catch {
                    
                }
            }
        }else {
            if let audioPlayer = self.audioPlayer {
                if(audioPlayer.isPlaying) {
                   pauseAudio()
                }else {
                    resumeAudio()
                }
            }
        }
    }
    func pauseAudio() {
        if let audioPlayer = self.audioPlayer {
            if(audioPlayer.isPlaying) {
                audioPlayer.pause()
                ivTogether.image = UIImage(named: "ic_play")
            }
        }
        
    }
    func resumeAudio() {
        if let audioPlayer = self.audioPlayer {
            if(!audioPlayer.isPlaying) {
                audioPlayer.play()
                ivTogether.image = UIImage(named: "ic_pause")
            }
        }
    }
  
    func seekToAudio(value: Double) {
        if let audioPlayer = self.audioPlayer {
            audioPlayer.currentTime = TimeInterval(value)
        }
    }
    func resetAudio() {
        self.ivTogether.image = UIImage(named: "ic_play")
        self.lbTimeCurrent.text = "00:00"
        audioPlayer = nil
        vSlider.value = 0
    }
}
extension AudioMergeVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
           resetAudio()
        }
    }
}
extension AudioMergeVC: AudioMergeCellDelegate {
    func delete(row: Int) {
        if(listUrl.count > 2) {
            listUrl.remove(at: row)
            setLabelTotal()
            tbvAudio.reloadData()
        }else {
            if(editType == EditType.merge) {
                self.createMessageView(message: "You need to select two or more audios to perform the audio merge function")
            }else {
                self.createMessageView(message: "You need to select two or more audios to perform the audio mix function")
            }
        }
    }
    func select(row: Int) {
        
    }
}
extension AudioMergeVC: FFmpegUtilDelegate {
    func ffmpegFinish(url: URL?, errorCode: Int) {
        if(errorCode == 0) {
            self.audioUrl = url
           
            DispatchQueue.main.sync {
                self.hideLoading()
                self.btnSave.isHidden = false
                pauseAudio()
                resetAudio()
                playAudio()
            }
        }else {
            
            DispatchQueue.main.sync {
                self.hideLoading()
                MessagesAudio.shared.showMessage(messageType: .error, message: "The file is corrupted or not supported. Please choose another file")
            }
           
        }
       
    }
}


extension AudioMergeVC : AudioBottomSheetDelegate {
    func selectAudioSheet(audioModel: AudioSaveModel) {
        if(listUrl.count < 4) {
            listUrl.append(audioModel)
            setLabelTotal()
            tbvAudio.reloadData()
        }else {
            self.createMessageView(message: "Only a maximum of 4 audios can be selected")
        }
    }
}
