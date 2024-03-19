//
//  AVAssetExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import AVKit

extension AVAsset {
    func getArtwork(at duration: Float64 = 5.0) -> UIImage? {
        if let metaArtwork = self.metadata.first(where: {$0.commonKey == .commonKeyArtwork}),
           let data = metaArtwork.value as? Data
        {
            let image = UIImage(data: data)
            return image
        }
        
        //
        let imageGenerator = AVAssetImageGenerator(asset: self)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let durationSeconds = CMTimeGetSeconds(self.duration)
        let time = durationSeconds > duration ? CMTimeMakeWithSeconds(duration, preferredTimescale: Int32(NSEC_PER_SEC)) : .zero
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
