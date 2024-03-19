import Foundation
import AVFoundation

protocol MuPlayerDelegate: NSObject {
    func preparePlay(track: TrackObject)
    func readyToPlay(track: TrackObject)
    
    func configAVPlayer(layer: AVPlayerLayer?, track: TrackObject)
    func onTimeObserver(currentTime: Double, duration: Double)
    func willFindLink(track: TrackObject)
    func didFoundLink(track: TrackObject)
    func bufferChanged(timeValue: Float)
}
