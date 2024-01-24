//
//  AudioBottomSheet.swift
//  CreateAudio1
//
//  Created by apple on 16/12/2023.
//

import UIKit
import Lottie

protocol AudioBottomSheetDelegate {
    func selectAudioSheet(audioModel: AudioSaveModel)
}

class AudioBottomSheet: ExtensionVC {
    @IBOutlet weak var vLine: AudioUiView!
    @IBOutlet weak var lblListMusic: UILabel!
    @IBOutlet weak var vHeader: UIView!
    @IBOutlet weak var clvAudio: UITableView!
    @IBOutlet weak var vEmpty: UIView!
    @IBOutlet weak var viewAnimation: UIView!
    
    private let animationLoading = LottieAnimationView(name: "anim_empty")
    
    var editType = EditType.normal
    var listFilter: [AudioSaveModel] = []
    var delegate:AudioBottomSheetDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        if(editType == EditType.normal) {
            lblListMusic.isHidden = true
            vHeader.isHidden = false
            vLine.isHidden = true
        }else {
            vLine.isHidden = false
        }
        clvAudio.delegate = self
        clvAudio.dataSource = self
        clvAudio.register(UINib(nibName: "AudioMergeCell", bundle: nil), forCellReuseIdentifier: "AudioMergeCell")
        filterData()
       
        // Do any additional setup after loading the view.
    }
    func filterData() {
        listFilter = AudioSaveModel.readWifiTransFileJson()
        if(listFilter.count == 0) {
            vEmpty.isHidden = false
        }else {
            vEmpty.isHidden = true
        }
        clvAudio.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationLoading.contentMode = .scaleAspectFit
        viewAnimation.addSubview(animationLoading)
        animationLoading.frame = CGRect(x: 0, y: 0, width: viewAnimation.frame.width, height: viewAnimation.frame.height)
        DispatchQueue.main.async {
            self.animationLoading.play(fromProgress: 0,
                                       toProgress: 1,
                                       loopMode: LottieLoopMode.loop,
                                       completion: { (finished) in})
            
        }
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationLoading.pause()
        animationLoading.removeFromSuperview()
    }
    
}
extension AudioBottomSheet: UITableViewDelegate, UITableViewDataSource,AudioMergeCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioMergeCell") as! AudioMergeCell
        let item = listFilter[indexPath.row]
        cell.delegate = self
        cell.index = indexPath.row
        cell.lblName.text = item.name
        cell.lblDuration.text = formatSecondsToHHMM(seconds: item.duration)
        let type = checkMediaType(url: item.url)
        if(type == "Video") {
            cell.ivThumb.image = item.artworkImage
            cell.ivThumb.isHidden = false
        }else {
            cell.ivThumb.isHidden = true
        }
        cell.btnClear.isHidden = false
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func delete(row: Int) {
        do {
            listFilter.remove(at: row)
            if(listFilter.count == 0) {
                vEmpty.isHidden = false
            }else {
                vEmpty.isHidden = true
            }
            clvAudio.reloadData()
            let jsonData = try JSONSerialization.data(withJSONObject: listFilter.map{$0.toString()}, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                writeString(aString: jsonString, fileName: WIFI_TRANS_JSON)
            }
        }catch {
            
        }
        
    
    }
    func select(row: Int) {
        let item = listFilter[row]
        if(editType == EditType.normal) {
            let vc = EditAudioVC()
            vc.audioUrl = item.url
            vc.editType = editType
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let type = checkMediaType(url: item.url)
        if(editType == EditType.videoToAudio) {
            if(type == "Audio") {
                self.createMessageView(message: "This function only supports video genres")
            }else {
                self.dismiss(animated: true) {
                    if(self.delegate != nil) {
                        self.delegate?.selectAudioSheet(audioModel: item)
                    }
                }
            }
        }else {
            if(type == "Video") {
                self.createMessageView(message: "This function only supports audio genres")
            }else {
                self.dismiss(animated: true) {
                    if(self.delegate != nil) {
                        self.delegate?.selectAudioSheet(audioModel: item)
                    }
                }
            }
        }
    }
}
