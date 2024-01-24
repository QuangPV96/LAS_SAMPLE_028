

import Foundation
import AVFoundation
import UIKit

enum SaveFinish {
    case finish
    case error
}

class AudioSaveModel: NSObject {
    var _id: String = ""
    var name: String = ""
    var downloadOnDevicePath: String = ""
    var duration: Double = 0
    var url: URL!
    var artworkImage: UIImage?

    override init() {
        super.init()
    }
    
    init(url: URL) {
        super.init()
        self.url = url;
    }
    
    init(_ dictionary: ADictionary) {
        if let val = dictionary["_id"] as? String { _id = val }
        if let val = dictionary["name"] as? String {
            name = val
        }
        if let val = dictionary["downloadOnDevicePath"] as? String {
            downloadOnDevicePath = val
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(downloadOnDevicePath)
            self.url = fileURL
            let asset = AVAsset(url: url)
            self.artworkImage = asset.getArtwork()
            self.duration = CMTimeGetSeconds(asset.duration)
        }
    }
  
    func getAudioSizeInMB() -> String? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url?.path ?? "")
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let fileSizeInBytes = fileSize.int64Value
                let fileSizeInMB = Double(fileSizeInBytes) / (1024 * 1024)
                return String(format: "%.2f MB", fileSizeInMB)
            }
        } catch {
            
        }
        
        return "0 MB"
    }

    func checkValueEqual(playableItem: AudioSaveModel) -> Bool {
        if (self._id == playableItem._id && self.name == playableItem.name) {
            return true
        } else {
            return false
        }
    }
    
    func toString() -> [String: Any] {
        return ["_id": _id,
                "name": name,
                "downloadOnDevicePath": downloadOnDevicePath]
    }
    
    static func readFileFromJson() -> [AudioSaveModel] {
        let string = readString(fileName: SAVE_AUDIO_JSON)
        if string == nil || string == "" {
            return [AudioSaveModel]()
        }
        let data: [ADictionary] = dataToJSON(data: (string?.data(using: .utf8))!) as! [[String: Any]]
        var result = [AudioSaveModel]()
        for item in data {
            let model = AudioSaveModel(item)
            result.append(model)
        }
        return result
    }
    
    static func readWifiTransFileJson() -> [AudioSaveModel] {
        let string = readString(fileName: WIFI_TRANS_JSON)
        if string == nil || string == "" {
            return [AudioSaveModel]()
        }
        let data: [ADictionary] = dataToJSON(data: (string?.data(using: .utf8))!) as! [[String: Any]]
        var result = [AudioSaveModel]()
        for item in data {
            let model = AudioSaveModel(item)
            result.append(model)
        }
        return result
    }
    
    static func deleteFile(playableItem: AudioSaveModel){
        let playableItems = readFileFromJson()
        var playableItemsNew = [AudioSaveModel]()
        for item in playableItems {
            if !item.checkValueEqual(playableItem: playableItem) {
                playableItemsNew.append(item)
            }
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: playableItemsNew.map{$0.toString()}, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                writeString(aString: jsonString, fileName: SAVE_AUDIO_JSON)
            }
        } catch {
            print("\(error)")
        }
    }
    
    static func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch let myJSONError {
            print("convert to json error: \(myJSONError)")
        }
        return nil
    }
    
   static func saveAudioToDocument(urlSave: URL?, onCompleteion: ((URL) -> Void?)) {
        if let videoUrl = urlSave {
            do {
               let nameSave = "Audio_\(Date().timeIntervalSince1970).m4a"
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
                onCompleteion(outputURL)
                
            }catch {
                MessagesAudio.shared.showMessage(messageType: .error, message: "Save audio error")
            }
        }
    }
}
