//
//  MuPlayerDelegate.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

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
