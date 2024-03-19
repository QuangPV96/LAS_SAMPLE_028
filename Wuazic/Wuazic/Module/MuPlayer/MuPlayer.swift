import UIKit
import AVFoundation
import MediaPlayer
import SDWebImage

class MuPlayer: NSObject {
    // MARK: - define some types
    struct Keys {
        static let loadedTimeRanges = "loadedTimeRanges"
    }
    
    enum PlaybackState {
        case play
        case pause
        case stop
    }
    
    enum RepeatState: Int {
        case off
        case one
        case all
    }
    
    // MARK: - property
    private var _player: AVPlayer?
    private var _playerLayer: AVPlayerLayer?
    var playerLayer: AVPlayerLayer? {
        return _playerLayer
    }
    
    private var _timeObserver: Any?
    private var _isRunningBackground: Bool = false
    var isRunningBackground: Bool {
        return _isRunningBackground
    }
    
    private var _index: Int = 0
    private var _tracks: [TrackObject] = []
    private var _currentTrack: TrackObject? {
        if self._tracks.count > 0 && self._index < self._tracks.count {
            return self._tracks[self._index]
        }
        return nil
    }
    
    var tracks: [TrackObject] {
        return self._tracks
    }
    
    var currentTrack: TrackObject? {
        return self._currentTrack
    }
    
    var repeatState: RepeatState {
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "muplayer-repeat-state")
            UserDefaults.standard.synchronize()
        }
        get {
            return RepeatState(rawValue: UserDefaults.standard.integer(forKey: "muplayer-repeat-state")) ?? .off
        }
    }
    
    weak var delegate: MuPlayerDelegate?
    
    // MARK: - init
    static let shared = MuPlayer()
    
    override init() {
        super.init()
    }
    
    // MARK: - config session
    func configSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - observers
    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinish(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func registerKVO() {
        guard let player = self._player, let durationCMTimeFormat = player.currentItem?.asset.duration else {
            return
        }
        
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        var duration = CMTimeGetSeconds(durationCMTimeFormat)
        duration = duration.isNaN ? 0.0 : duration
        
        // time observer
        self._timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateInfoCenter()
            self?.delegate?.onTimeObserver(currentTime: CMTimeGetSeconds(time), duration: Double(duration))
        }
        
        // add KVO
        player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status),
                                        options: .new, context: nil)
        
        player.currentItem?.addObserver(self, forKeyPath: Keys.loadedTimeRanges,
                                        options: .new, context: nil)
    }
    
    private func removeKVO() {
        guard let observer = _timeObserver else { return }
        
        self._player?.removeTimeObserver(observer)
        self._player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        self._player?.currentItem?.removeObserver(self, forKeyPath: Keys.loadedTimeRanges)
        self._timeObserver = nil
    }
    
    // MARK: - private
    private func prepareToPlay() {
        guard let track = self._currentTrack else { return }
        
        switch track.type {
        case .unknow:
            return
            
        case .offline:
            guard let url = track.absolutePath else { return }
            
            let item = AVPlayerItem(url: url)
            self._player = AVPlayer(playerItem: item)
            
        case .online:
            guard let urlString = track.trackUrl, let url = URL(string: urlString) else { return }
            
            let item = AVPlayerItem(url: url)
            self._player = AVPlayer(playerItem: item)
            
        }
        
        if self._player != nil {
            self._playerLayer = AVPlayerLayer(player: self._player!)
            self._playerLayer?.videoGravity = .resizeAspect
        }
        
        registerKVO()
        
        delegate?.configAVPlayer(layer: self._playerLayer, track: track)
        delegate?.preparePlay(track: track)
    }
    
    private func requestLinkPlay(_ track: TrackObject, completion: @escaping (String) -> Void) {
        delegate?.willFindLink(track: track)
        
        let context = MuJSContext()
        context?.loadScript(AltEnum.getLi.description())
        
        let id = track.trackId ?? ""
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [id, 0]) { [weak self] value in
            guard let val = value else {
                completion("")
                return
            }
            
            if val.isObject,
               let data = val.toDictionary()["data"] as? [AnyHashable:Any],
               let url = data["url"] as? String
            {
                completion(url)
                self?.delegate?.didFoundLink(track: track)
            }
            else {
                completion("")
            }
        }
    }
    
    // MARK: - public
    func awake() {
        configSession()
        registerObservers()
    }
    
    func setPlaylist(_ tracks: [TrackObject], currentTrack: TrackObject) {
        if currentTrack.type == .online && (currentTrack.trackUrl ?? "").isEmpty {
            self.requestLinkPlay(currentTrack) { [weak self] url in
                if url.isEmpty {
                    // error, auto next
                    self?.playNext()
                }
                else {
                    currentTrack.trackUrl = url
                    self?.setPlaylist(tracks, currentTrack: currentTrack)
                }
            }
            return
        }
        
        self._tracks = tracks
        
        // update position
        updatePosition(currentTrack)
        
        stop()
        resetAVPlayerLayer()
        
        // prepare play
        prepareToPlay()
        
        updateStateNextOrPreviousCenter()
    }
    
    func updatePosition(_ track: TrackObject) {
        if let index = self._tracks.firstIndex(of: track) {
            self._index = index
        }
    }
    
    func setPlaylistShuffle(_ tracks: [TrackObject]) {
        guard let track = self._currentTrack else { return }
        
        self._tracks = tracks
        
        // update position
        if let index = self._tracks.firstIndex(of: track) {
            self._index = index
        }
    }
    
    func deleteTrackOnPlaylist(_ track: TrackObject) {
        self._tracks.removeAll(where: { $0.id == track.id })
    }
    
    // MARK: - control playlist
    private func playCurrentItem() {
        guard let track = self._currentTrack else { return }
        
        if track.type == .online {
            self.requestLinkPlay(track) { [weak self] url in
                if url.isEmpty {
                    // error, auto next
                    self?.playNext()
                }
                else {
                    track.trackUrl = url
                    
                    self?.prepareToPlay()
                    
                    self?.updateStateNextOrPreviousCenter()
                }
            }
        }
        else {
            self.prepareToPlay()
            
            self.updateStateNextOrPreviousCenter()
        }
    }
    
    func canNext() -> Bool {
        return self._tracks.count > 0 && self._index < self._tracks.count - 1
    }
    
    func playNext() {
        if canNext() {
            self._index += 1
            
            resetAVPlayerLayer()
            stop()
            
            playCurrentItem()
        }
    }
    
    func canPrevious() -> Bool {
        return self._tracks.count > 0 && self._index > 0
    }
    
    func playPrevious() {
        if canPrevious() {
            self._index -= 1
            
            resetAVPlayerLayer()
            stop()
            
            playCurrentItem()
        }
    }
    
    func resume() {
        if self._player == nil {
            prepareToPlay()
            updateStateNextOrPreviousCenter()
            
            return
        }
        
        if isPlaying == false {
            self._player?.play()
        }
    }
    
    func pause() {
        self._player?.pause()
    }
    
    func stop() {
        removeKVO()
        
        self._player?.pause()
        self._player?.rate = 0
        self._player = nil
    }
    
    func resetAVPlayerLayer() {
        self._playerLayer?.player = nil
        self._playerLayer?.removeFromSuperlayer()
        self._playerLayer = nil
    }
    
    // MARK: - sliding, information music (duration, current time,...)
    func seekToTime(seconds: Float64) {
        let targetTime = CMTimeMakeWithSeconds(seconds, preferredTimescale: Int32(NSEC_PER_SEC))
        self._player?.currentItem?.seek(to: targetTime, completionHandler: { success in
            // don't nothing
        })
    }
    
    var currentTime: Float64 {
        let currentTime = self._player?.currentItem?.currentTime() ?? .zero
        return CMTimeGetSeconds(currentTime)
    }
    
    var duration: Float64 {
        let duration = self._player?.currentItem?.asset.duration ?? .zero
        let second = CMTimeGetSeconds(duration)
        return second.isNaN ? 0.0 : second
    }
    
    var isPlaying: Bool {
        return (self._player?.rate ?? 0) > 0
    }
    
    var isEmpty: Bool {
        return self._tracks.count == 0 || self._currentTrack == nil
    }
    
    // MARK: - Control Center / Lockscreen
    func setupRemoteSystemControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            self.resume()
            return .success
        }
        commandCenter.pauseCommand.addTarget { event in
            self.pause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.playNext()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.playPrevious()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let avPlayer = self._player else { return .commandFailed }
            guard let eventPosition = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            let timeIntervalChanged = CMTime(seconds: eventPosition.positionTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            avPlayer.currentItem?.seek(to: timeIntervalChanged, completionHandler: { success in
                // don't nothing
            })
            
            return .success
        }
    }
    
    func updateStateNextOrPreviousCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = canNext()
        commandCenter.previousTrackCommand.isEnabled = canPrevious()
    }
    
    func updateInfoCenter() {
        guard let player = self._player else { return }
        guard let track = self._currentTrack else { return }
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        
        switch track.type {
        case .unknow: break
        case .offline:
            if let asset = player.currentItem?.asset, let image = asset.getArtwork() {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
            }
        case .online:
            if let image = SDImageCache.shared.imageFromCache(forKey: track.trackThumbnailUrl) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: KVO Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            var status: AVPlayerItem.Status = .unknown
            if let statusNumber = change?[.newKey] as? NSNumber,
               let newStatus = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
                status = newStatus
            }
            switch status {
            case .readyToPlay:
                if let tr = self._currentTrack {
                    delegate?.readyToPlay(track: tr)
                }
                
                _player?.play()
                
                self.updateInfoCenter()
                
            case .failed:
                if let item = object as? AVPlayerItem,
                   let error = item.error as NSError?,
                   let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                    print(error)
                    print(underlyingError)
                }
                
            default:
                break
            }
        } else if keyPath == Keys.loadedTimeRanges {
            guard let duration = _player?.currentItem?.duration else { return }
            
            if let ch = change, let timeRanges = ch[.newKey] as? [CMTimeRange], timeRanges.count > 0 {
                let timeRange = timeRanges[0]
                let timeDuration = CMTimeGetSeconds(timeRange.duration)
                let secondDuration = CMTimeGetSeconds(duration)
                let bufferTimeValue: Float = secondDuration != 0 ? Float(timeDuration / secondDuration) : 0
                let value = bufferTimeValue > 0.95 ? 1 : bufferTimeValue
                
                delegate?.bufferChanged(timeValue: value)
            }
        }
    }
    
    // MARK: - event
    @objc func playerDidFinish(_ sender: NSNotification) {
        guard let track = self._currentTrack else { return }
        if sender.object as? AVPlayerItem != self._player?.currentItem {
            return
        }
        
        updateStateNextOrPreviousCenter()
        
        switch repeatState {
        case .off:
            // next music if exists
            playNext()
            
        case .one:
            pause()
            seekToTime(seconds: 0)
            
            // reset slider, current time, duration
            delegate?.readyToPlay(track: track)
            resume()
            
        case .all:
            if self._tracks.count > 0 && self._index == self._tracks.count - 1 {
                self._index = 0
                
                resetAVPlayerLayer()
                stop()
                
                prepareToPlay()
                
                updateStateNextOrPreviousCenter()
            }
            else {
                playNext()
            }
        }
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        _isRunningBackground = false
        if self._player != nil {
            self._playerLayer = AVPlayerLayer(player: self._player!)
            self._playerLayer?.videoGravity = .resizeAspect
            
            guard let track = _currentTrack else { return }
            
            delegate?.configAVPlayer(layer: self._playerLayer, track: track)
        }
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        self._isRunningBackground = true
        resetAVPlayerLayer()
    }
}
