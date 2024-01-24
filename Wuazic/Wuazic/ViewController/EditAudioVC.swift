

import UIKit
import AVFoundation

enum EditType {
    case normal
    case trim
    case speed
    case convert
    case videoToAudio
    case reverse
    case merge
    case mix
}
class EditAudioVC: ExtensionVC {
    @IBOutlet weak var btnTogether: UIButton!
    @IBOutlet weak var vSlider: AudioSlider!
    @IBOutlet weak var lbTimeEnd: UILabel!
    @IBOutlet weak var lbTimeCurrent: UILabel!
    @IBOutlet weak var vProgress: AudioUiView!
    @IBOutlet weak var ivPrevious: UIImageView!
    @IBOutlet weak var ivSkip: UIImageView!
    @IBOutlet weak var ivTogether: UIImageView!
    @IBOutlet weak var trimView: AudioTrimView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var vTrim: UIView!
    @IBOutlet weak var vNormal: UIView!
    @IBOutlet weak var vSpeed: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var clvSpeed: UICollectionView!
    @IBOutlet weak var ivCd: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var clvConvertAudio: UICollectionView!
    @IBOutlet weak var vConvertNormal: UIView!
    
    var isAnimating = true
    var nameAudio = ""
    var typeFile = ""
    var editType: EditType = EditType.normal
    var displayLink: CADisplayLink!
    var audioUrl: URL?
    var audioPlayer: AVAudioPlayer?
    var progressLayer: CAShapeLayer!
    var currentTime: CLong = 0
    var urlBegin : URL?
    var trimFinish = false
    var durationAudio: Float = 0
    var trimStartTime: Double = 0
    var trimEndTime:Double = 0
    private  var animation: CABasicAnimation!
    var currentProgressAnimation: CGFloat = 0.0
    var speedList: [Float] = [1, 1.5, 2, 2.5, 4]
    var speedValue: Float = 1
    var audioConvertList: [String] = ["Mp3", "M4a", "Wav"]
    override func viewDidLoad() {
        super.viewDidLoad()
        urlBegin = audioUrl
        rotateImage()
        setupEditType()
        playAudio()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let audioPlayer = self.audioPlayer {
            if(audioPlayer.isPlaying) {
                audioPlayer.stop()
                self.audioPlayer = nil
            }
        }
    }
    func rotateImage() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0) // 1 vòng xoay đầy đủ
        rotationAnimation.duration = 2.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude // Lặp vô hạn
        
        ivCd.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    func pauseAnimation() {
        let pausedTime = ivCd.layer.convertTime(CACurrentMediaTime(), from: nil)
        ivCd.layer.speed = 0.0
        ivCd.layer.timeOffset = pausedTime
    }
    
    func resumeAnimation() {
        let pausedTime = ivCd.layer.timeOffset
        ivCd.layer.speed = 1.0
        ivCd.layer.timeOffset = 0.0
        ivCd.layer.beginTime = 0.0
        let timeSincePause = ivCd.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        ivCd.layer.beginTime = timeSincePause
    }
    
    func setupEditType() {
        if(editType == EditType.normal) {
            lblName.text = nameAudio
            vNormal.isHidden = false
            btnSave.setImage(UIImage(named: "ic_share"), for: .normal)
            lblType.text = "Play Music"
            vConvertNormal.isHidden = false
            
            clvConvertAudio.delegate = self
            clvConvertAudio.dataSource = self
            clvConvertAudio.register(UINib(nibName: "ConvertAudioCell", bundle: nil), forCellWithReuseIdentifier: "ConvertAudioCell")
            
        }else if(editType == EditType.trim) {
            vTrim.isHidden = false
            lblType.isHidden = false
            lblType.text = "Trim"
            if let audioUrl = self.audioUrl {
                let audioAsset = AVAsset(url: audioUrl)
                trimView.asset = audioAsset
                trimView.delegate = self
            }
        }else if(editType == EditType.speed) {
            clvSpeed.delegate = self
            clvSpeed.dataSource = self
            clvSpeed.register(UINib(nibName: "SpeedCell", bundle: nil), forCellWithReuseIdentifier: "SpeedCell")
            
            lblType.isHidden = false
            lblType.text = "Speed"
            vSpeed.isHidden = false
            vNormal.isHidden = false
        }else if(editType == EditType.convert) {
            lblType.isHidden = false
            lblType.text = "Convert"
            vNormal.isHidden = false
        }else if(editType == EditType.videoToAudio) {
            lblType.isHidden = false
            lblType.text = "Video to audio"
            vNormal.isHidden = false
        }else if(editType == EditType.reverse) {
            lblType.isHidden = false
            lblType.text = "Reverse"
            vNormal.isHidden = false
        }else if(editType == EditType.merge) {
            lblType.isHidden = false
            lblType.text = "Merge"
            vNormal.isHidden = false
        }else if(editType == EditType.mix) {
            lblType.isHidden = false
            lblType.text = "Mix"
            vNormal.isHidden = false
        }
    }
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateSliderAndTime))
        displayLink.add(to: .main, forMode: .common)
    }
    
    func convertTimeIntervalToCMTime(timeInterval: TimeInterval) -> CMTime {
        let seconds = Int64(timeInterval)
        let preferredTimeScale: Int32 = 1000
        return CMTimeMake(value: seconds, timescale: preferredTimeScale)
    }
 
    func playAudio() {
        if(audioPlayer == nil) {
            progressLayer = CAShapeLayer()
            progressLayer.strokeColor = UIColor(hex: 0xC6FCAA).cgColor
            progressLayer.fillColor = nil
            progressLayer.lineWidth = 5.0
            vProgress.layer.addSublayer(progressLayer)
            setupDisplayLink()
            if let audioUrl = self.audioUrl {
                do {
                    resumeAnimation()
                    audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                    durationAudio = Float(audioPlayer?.duration ?? 0)
                    trimEndTime = Double(audioPlayer?.duration ?? 0)
                    let duration = Float(audioPlayer?.duration ?? 0)
                    let minutes = Int(duration) / 60
                    let seconds = Int(duration) % 60

                    lbTimeEnd.text = String(format: "%02d:%02d", minutes, seconds)
                    vSlider.maximumValue = duration
                    ivTogether.image = UIImage(named: "ic_pause")
                    
                    let progressPath = UIBezierPath(cgPath: UIBezierPath(roundedRect: vProgress.bounds, cornerRadius: vProgress.layer.cornerRadius).cgPath)
                    progressLayer.path = progressPath.cgPath
                    animation = CABasicAnimation(keyPath: "strokeEnd")
                    animation.fromValue = currentProgressAnimation
                    animation.toValue = 1.0
                    animation.duration = CFTimeInterval(durationAudio)
                    progressLayer.add(animation, forKey: "progressAnimation")
                } catch {
                    
                }
            }
        }else {
            if let audioPlayer = self.audioPlayer {
                if(audioPlayer.isPlaying) {
                   pauseAudio()
                }else {
                    if(trimFinish) {
                        seekToAudio(value: trimStartTime)
                        ivTogether.image = UIImage(named: "ic_pause")
                        audioPlayer.play()
                        displayLink.isPaused = false
                    }else {
                        resumeAudio()
                    }
                }
            }
        }
    }
    func pauseAudio() {
        if let audioPlayer = self.audioPlayer {
            if(audioPlayer.isPlaying) {
                audioPlayer.pause()
                pauseAnimation()
                displayLink.isPaused = true
                let pausedTime = progressLayer.convertTime(CACurrentMediaTime(), from: nil)
                progressLayer.speed = 0.0
                progressLayer.timeOffset = pausedTime
                ivTogether.image = UIImage(named: "ic_play")
            }
        }
        
    }
    func resumeAudio() {
        if let audioPlayer = self.audioPlayer {
            if(!audioPlayer.isPlaying) {
                resumeAnimation()
                let pausedTime = progressLayer.timeOffset
                progressLayer.speed = 1.0
                progressLayer.timeOffset = 0.0
                let timeSincePause = progressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                progressLayer.beginTime = timeSincePause
                ivTogether.image = UIImage(named: "ic_pause")
                audioPlayer.play()
                displayLink.isPaused = false
            }
        }
    }
    
    @objc func updateSliderAndTime() {
        // seekbar audio player
        DispatchQueue.global().async { [self] in
             if let audioPlayer = self.audioPlayer {
                 let newCurrent = audioPlayer.currentTime
                let currentTime = Int(newCurrent * 1000)
                 if(Double(newCurrent) >= trimStartTime && Double(newCurrent) <= trimEndTime) {
                     let minutes = currentTime / (60 * 1000)
                     let seconds = (currentTime % (60 * 1000)) / 1000
                     let milliseconds = currentTime % 1000
                     let cmTime = convertTimeIntervalToCMTime(timeInterval: audioPlayer.currentTime*1000)
                    
                     DispatchQueue.main.async {
                         self.trimView.seek(to: cmTime)
                         self.vSlider.value = Float(audioPlayer.currentTime)
                         self.lbTimeCurrent.text = String(format: "%02d:%02d", minutes, seconds, milliseconds)
                     }
                 }else {
                     DispatchQueue.main.async {
                         self.trimFinish = true
                         audioPlayer.currentTime = TimeInterval(self.trimStartTime)
                         self.pauseAudio()
                     }
                 }
               
             }
         }
     }
    
    @IBAction func sliderChange(_ sender: UISlider) {
        if self.audioPlayer != nil {
            seekToAudio(value: Double(sender.value))
        }else {
            let progressValue = Float(sender.value) / durationAudio
            currentProgressAnimation = TimeInterval(progressValue)
            playAudio()
        }
    }
    func seekToAudio(value: Double) {
        var progressValue = Float(value) / durationAudio
        var time: Double = 0
        if let audioPlayer = self.audioPlayer {
            time = Double(durationAudio) - Double(audioPlayer.currentTime)
        }
        
        if(editType == EditType.trim) {
            progressValue = 0
            time = Double(durationAudio)
        }
        if let audioPlayer = self.audioPlayer {
            audioPlayer.currentTime = TimeInterval(value)
            progressLayer.speed = 1.0
            progressLayer.timeOffset = 0.0
            animation.fromValue = TimeInterval(progressValue)
            animation.toValue = 1
            animation.duration = CFTimeInterval(time)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
    }
    func resetAudio() {
        self.ivTogether.image = UIImage(named: "ic_play")
        self.lbTimeCurrent.text = "00:00"
        vSlider.value = 0
        pauseAnimation()
        displayLink.isPaused = true
        
        audioPlayer = nil
        progressLayer.removeFromSuperlayer()
        progressLayer = nil
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionPrevious(_ sender: Any) {
    }
    @IBAction func actionToghether(_ sender: Any) {
        playAudio()
    }
    
    @IBAction func actionSkip(_ sender: Any) {
    }
    @IBAction func actionSave(_ sender: Any) {
        pauseAudio()
       
        if(editType == EditType.trim) {
            self.showLoading()
            FFmpegUtils.getInstance.delegate = self
            let startTime = formatTimeTrim(seconds: Int(trimStartTime))
            let endTime = formatTimeTrim(seconds: Int(trimEndTime))
            if let audioUrl =  self.audioUrl {
                FFmpegUtils.getInstance.trimAudioCmd(inputUrl: audioUrl, startTime: startTime, endTime: endTime)
            }
        }else if(editType == EditType.speed ||
                 editType == EditType.videoToAudio ||
                 editType == EditType.reverse ||
                 editType == EditType.merge ||
                 editType == EditType.mix
        ) {
            if let audioUrl =  self.audioUrl {
                AudioSaveModel.saveAudioToDocument(urlSave: audioUrl) { outPutUrl in
                    MessagesAudio.shared.showMessage(messageType: .success, message: "Save audio finish")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }else if(editType == EditType.convert) {
            self.showLoading()
            FFmpegUtils.getInstance.delegate = self
            if let audioUrl =  self.audioUrl {
                FFmpegUtils.getInstance.convertAudioCmd(inputUrl: audioUrl, outputFormat: typeFile)
            }
        }else if(editType == EditType.normal) {
            if let newUrl = audioUrl {
                let share = UIActivityViewController(activityItems: [newUrl], applicationActivities: nil)
                share.popoverPresentationController?.sourceView = self.btnSave
                self.present(share, animated: true, completion: nil)
            }else {
                MessagesAudio.shared.showMessage(messageType: .error, message: "Audio cannot be shared")
            }
        }
    }
}
extension EditAudioVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if(editType == EditType.trim) {
                
            }else {
                resetAudio()
            }
            
        }
    }
}
extension EditAudioVC: TRAudioTrimmerViewDelegate {
    func didChangePositionBar(_ playerTime: CMTime) {
        pauseAudio()
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        trimStartTime = trimView.startTime!.seconds
        trimEndTime = trimView.endTime!.seconds
        let timeStartStr = formatSecondsToHHMM(seconds: trimStartTime)
        let timeEndStr = formatSecondsToHHMM(seconds: trimEndTime)
        lbTimeCurrent.text = timeStartStr
        lbTimeEnd.text = timeEndStr
        durationAudio = Float(trimEndTime - trimStartTime)
        seekToAudio(value: trimStartTime)
        ivTogether.image = UIImage(named: "ic_pause")
        audioPlayer?.play()
        displayLink.isPaused = false
    }
}
extension EditAudioVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(clvConvertAudio == collectionView) {
            return audioConvertList.count
        }
        return speedList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(clvConvertAudio == collectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConvertAudioCell", for: indexPath) as! ConvertAudioCell
            let item = audioConvertList[indexPath.row]
            cell.lblAudio.text = item
            cell.ivAudio.image = UIImage(named: "ic_\(item)")
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpeedCell", for: indexPath) as! SpeedCell
        let item = speedList[indexPath.row]
        cell.lbSpeed.text = "x\(item)"
        if(speedValue == item) {
            cell.vParent.borderColor = UIColor(hex: 0xC6FCAA)
        }else {
            cell.vParent.borderColor = UIColor(hex: 0xFFFFFF)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(clvConvertAudio == collectionView) {
            return CGSize(width: 200, height: 120)
        }
        return CGSize(width: 48, height: 48)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(clvConvertAudio == collectionView) {
            FFmpegUtils.getInstance.delegate = self
            if let audioUrl = self.audioUrl {
                if(indexPath.row == 0) {
                    typeFile = "mp3"
                }else if(indexPath.row == 1) {
                    typeFile = "m4a"
                }else if(indexPath.row == 2) {
                    typeFile = "wav"
                }
                self.showLoading()
                editType = EditType.convert
                FFmpegUtils.getInstance.delegate = self
                FFmpegUtils.getInstance.convertAudioCmd(inputUrl: audioUrl, outputFormat: typeFile)
            }
            
        }else {
            speedValue = speedList[indexPath.row]
            clvSpeed.reloadData()
            
            if let audioUrl = self.urlBegin {
                self.pauseAudio()
                self.showLoading()
                FFmpegUtils.getInstance.delegate = self
                FFmpegUtils.getInstance.speedAudioCmd(inputUrl: audioUrl, speed: speedValue)
            }
        }
        
    }
}
                                                                
extension EditAudioVC: FFmpegUtilDelegate {
    func ffmpegFinish(url: URL?, errorCode: Int) {
        if(errorCode == 0) {
            self.audioUrl = url
            if(editType == EditType.trim) {
                DispatchQueue.main.sync {
                    self.hideLoading()
                    if let audioUrl = self.audioUrl {
                        AudioSaveModel.saveAudioToDocument(urlSave: audioUrl) { url in
                            MessagesAudio.shared.showMessage(messageType: .success, message: "Save audio finish")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else if(editType == EditType.speed) {
                DispatchQueue.main.sync {
                    self.hideLoading()
                    self.resetAudio()
                    self.playAudio()
                }
            }else if(editType == EditType.convert) {
                DispatchQueue.main.sync {
                    self.hideLoading()
                    if let videoUrl = self.audioUrl {
                        do {
                           let nameSave = "Audio_\(Date().timeIntervalSince1970).\(typeFile)"
                            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let outputURL = documentDirectory.appendingPathComponent(nameSave)
                            try FileManager.default.copyItem(at: videoUrl, to: outputURL)
                            var listSave = AudioSaveModel.readFileFromJson()
                            
                            let playableItem = AudioSaveModel()
                            playableItem._id = "\(Date().timeIntervalSince1970 * 1000.0)"
                            playableItem.name = nameSave
                            playableItem.downloadOnDevicePath = nameSave
                            
                            listSave.append(playableItem)
                            let jsonData = try JSONSerialization.data(withJSONObject: listSave.map{$0.toString()}, options: JSONSerialization.WritingOptions.prettyPrinted)
                            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                                writeString(aString: jsonString, fileName: SAVE_AUDIO_JSON)
                            }
                            MessagesAudio.shared.showMessage(messageType: .success, message: "Save audio finish")
                            self.navigationController?.popViewController(animated: true)
                        }catch {
                            MessagesAudio.shared.showMessage(messageType: .error, message: "Save audio error")
                        }
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
