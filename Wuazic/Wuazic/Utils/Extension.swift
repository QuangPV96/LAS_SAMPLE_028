

import UIKit
import AVFoundation

extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension AVAsset {
  func getArtwork() -> UIImage? {
    if let metaArtwork = self.metadata.first(where: {$0.commonKey == .commonKeyArtwork}), let data = metaArtwork.value as? Data {
      let image = UIImage(data: data)
      return image
    }
     
    let imageGenerator = AVAssetImageGenerator(asset: self)
    imageGenerator.appliesPreferredTrackTransform = true
     
    let durationSeconds = CMTimeGetSeconds(self.duration)
    let time = durationSeconds > 1 ? CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC)) : .zero
    var actualTime: CMTime = CMTime.zero
    do {
        let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
        let image = UIImage(cgImage: imageRef)
        return image
    } catch let error as NSError {
        print("\(error.description). Time: \(actualTime)")
    }
    return nil
  }
}
