

import Foundation
import AVFoundation

typealias ADictionary = [String: Any]
public let SAVE_AUDIO_JSON = "save_audio_file.json"
public let WIFI_TRANS_JSON = "wifi_trans_file.json"

public let clientId = "voqlrg7x4uwjb48hmrhawyjarjxjpwey"
public let clientSecret = "UlmlMlAHEM557VZ4jhfN2c7jwfFoNpnW"

public func getNameFileFromPath(path: String) -> String {
    let name = String(path.split(separator: "/")[path.split(separator: "/").count - 1])
    if path.fileExtension() == "mp3" || path.fileExtension() == "mp4"{
        return name.fileName()
    }
    return ""
}
func checkMediaType(url: URL)-> String {
    let asset = AVAsset(url: url)
    let assetType = asset.tracks(withMediaType: AVMediaType.video).count > 0 ? "Video" : "Audio"
    print("Media Type: \(assetType)")
    return assetType
}
func getUrlFromName(downloadOnDevicePath: String)-> URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(downloadOnDevicePath)
    return fileURL
}

func copyFileToDoc(inputUrl: URL?, completion: ((URL?) -> Void)) {
    do {
        if let inputUrl = inputUrl {
            let nameSave = "Audio_\(Date().timeIntervalSince1970).m4a"
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentDirectory.appendingPathComponent(nameSave)
            try FileManager.default.copyItem(at: inputUrl, to: outputURL)
            completion(outputURL)
        }
    }catch {
       
    }
    completion(nil)
}
func formatSecondsToHHMM(seconds: Double) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad

    if let formattedString = formatter.string(from: TimeInterval(seconds)) {
        return formattedString
    } else {
        return "00:00"
    }
}

public func dataToJSON(data: Data) -> Any? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: [])
    } catch _ {
        
    }
    return nil
}
public func readString(fileName: String) -> String? {
    do {
        if let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            if !FileManager.default.fileExists(atPath: fileURL.absoluteString){
                FileManager.default.createFile(atPath: fileURL.absoluteString, contents: nil, attributes: nil)
            }
            let savedText = try String(contentsOf: fileURL)
            return savedText
        }
        return nil
    } catch {
        return nil
    }
}

public func writeString(aString: String, fileName: String) {
    do {
        
        if let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            if !FileManager.default.fileExists(atPath: fileURL.absoluteString){
                FileManager.default.createFile(atPath: fileURL.absoluteString, contents: nil, attributes: nil)
            }
            try aString.write(to: fileURL, atomically: false, encoding: .utf8)
        }
    } catch {
        
    }
}

func formatTimeTrim(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let seconds = (seconds % 3600) % 60
    
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}
