

import Foundation
import mobileffmpeg
import AVFAudio
import AVFoundation

protocol FFmpegUtilDelegate {
    func ffmpegFinish(url: URL?, errorCode: Int)
}
class FFmpegUtils: NSObject, ExecuteDelegate, StatisticsDelegate, LogDelegate {
    var delegate: FFmpegUtilDelegate?
    var  nameAudioSave = ""
    var  outputURL: URL?
    static let getInstance = FFmpegUtils()
    
    override init() {
        
    }
    func createNameAndOutPut() {
        nameAudioSave = "Audio_\(Date().timeIntervalSince1970).m4a"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        outputURL = documentDirectory.appendingPathComponent(nameAudioSave)
    }
    
    func mixAudioCmd(inputURLs: [URL]) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        if let audioOutput = outputURL {
            let inputArgs = inputURLs.enumerated().map { (index, url) in
                    return "-i \(url.path)"
                }
                
                let inputArgsString = inputArgs.joined(separator: " ")
                
                let command = "\(inputArgsString) -filter_complex \"\(inputURLs.enumerated().map { (index, _) in "[\(index):a]" }.joined())amix=inputs=\(inputURLs.count):duration=first:dropout_transition=2\" \(audioOutput.path)"
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
           
        }
    }
    
    func reverseAudioCmd(inputUrl: URL) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        if let audioOutput = outputURL {
            let  command = "-i \(inputUrl.path) -af areverse \(audioOutput.path)"
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
        }
    }
    
    func convertAudioCmd(inputUrl: URL, outputFormat: String) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        if let audioOutput = outputURL {
            var  command = ""
            if(outputFormat == "m4a") {
                command = "-i \(inputUrl.path) -c:a aac -b:a 192k \(audioOutput.path)"
            }else if(outputFormat == "mp3" || outputFormat == "wav" || outputFormat == "mov"){
                command = "-i \(inputUrl.path) -f \(outputFormat) \(audioOutput.path)"
            }
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
        }
    }
    
    func convertVideoToAudioCmd(inputUrl: URL) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        if let audioOutput = outputURL {
            let  command = "-i \(inputUrl.path) -vn -c:a copy \(audioOutput.path)"
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
           
        }
    }
    func trimAudioCmd(inputUrl: URL, startTime: String, endTime: String) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        if let audioOutput = outputURL {
            let command = "-i \(inputUrl.path) -ss \(startTime) -to \(endTime) -c:a aac -strict experimental \(audioOutput.path)"
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
           
        }
    }
   
    
    func speedAudioCmd(inputUrl: URL, speed: Float) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        if let audioOutput = outputURL {
            let command = "-i \(inputUrl.path) -filter:a \"atempo=\(speed)\" -vn \(audioOutput.path)"
            
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
        }
    }
    
    func mergeAudioCmd(audioUrls: [URL]) {
        MobileFFmpegConfig.setStatisticsDelegate(self)
        createNameAndOutPut()
        

        if let audioOutput = outputURL {
                var command = ""
                // Add input options
                for url in audioUrls {
                    command += " -i \(url.path)"
                }
                // Add filter complex options
                command += " -filter_complex \""
                for (index, _) in audioUrls.enumerated() {
                    command += "[\(index):0]"
                }
                command += "concat=n=\(audioUrls.count):v=0:a=1[out]\""
                // Add output options
                command += " -map \"[out]\" \(audioOutput.path)"
            DispatchQueue.main.async {
                MobileFFmpegConfig.setStatisticsDelegate(self)
                MobileFFmpegConfig.setLogDelegate(self)
                MobileFFmpeg.executeAsync(command, withCallback: self)
                MobileFFmpegConfig.resetStatistics()
            }
        }else {
        }
       
    }
    func statisticsCallback(_ statistics: Statistics!) {
    }
    func executeCallback(_ executionId: Int, _ returnCode: Int32) {
        if let audioUrl =  outputURL{
            if(self.delegate != nil) {
                self.delegate?.ffmpegFinish(url: audioUrl, errorCode: Int(returnCode))
            }
        }
        
    }
    func logCallback(_ executionId: Int, _ level: Int32, _ message: String!) {

    }
}

