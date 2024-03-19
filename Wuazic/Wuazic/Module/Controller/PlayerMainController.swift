import UIKit
import AVKit
import MarqueeLabel
import SDWebImage

protocol PlayerMainDelegate: NSObject {
    func preparePlay(track: TrackObject)
    func onTimeObserver(currentTime: Double, duration: Double)
}


class PlayerMainController: BaseController {
    
    fileprivate var isSeeking: Bool = false
    fileprivate var track: TrackObject!
    fileprivate var playlist: [TrackObject] = []
    
    var delegate: PlayerMainDelegate?
    
    // MARK: - property
    fileprivate let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    fileprivate let playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }()
    
    fileprivate let thumbnailImage: UIImageView = {
        let view = UIImageView(image: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        return view
    }()
    
    fileprivate let titleTrackLabel: MarqueeLabel = {
        let view = MarqueeLabel()
        view.type = .leftRight
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 20)
        return view
    }()
    
    fileprivate let subtileTrackLabel: MarqueeLabel = {
        let view = MarqueeLabel()
        view.type = .leftRight
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .init(rgb: 0x00D1EE)
        view.font = UIFont.gilroy(of: 14)
        return view
    }()
    
    fileprivate let dimissButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-arrow-down"), for: .normal)
        return view
    }()
    
    fileprivate let optionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-option-white"), for: .normal)
        return view
    }()
    
    fileprivate let airPlayButton: AVRoutePickerView = {
        let view = AVRoutePickerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor.white
        return view
    }()
    
    fileprivate let likeButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-like"), for: .normal)
        view.setImage(UIImage(imgName: "ic-liked"), for: .selected)
        return view
    }()
    
    fileprivate let daolodButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-donwlaod"), for: .normal)
        view.setImage(UIImage(imgName: "ic-donwlaod-active"), for: .selected)
        return view
    }()
    
    fileprivate let loadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let view = UIActivityIndicatorView(style: .medium)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.color = .white
            return view
        }
        else {
            let view = UIActivityIndicatorView(style: .white)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
    }()
    
    fileprivate let slider: UISlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setThumbImage(UIImage(imgName: "ic-thumb"), for: .normal)
        view.setThumbImage(UIImage(imgName: "ic-thumb"), for: .highlighted)
        view.setThumbImage(UIImage(imgName: "ic-thumb"), for: .highlighted)
        
        //view.setThumbImage(UIImage(imgName: "ic-thumb-active"), for: .highlighted)
        //view.setThumbImage(UIImage(imgName: "ic-thumb-active"), for: .highlighted)
        
        view.minimumTrackTintColor = UIColor(rgb: 0x00D1EE)
        view.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.25)
        return view
    }()
    
    fileprivate let timeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .left
        view.textColor = .white
        view.font = UIFont.gilroyMedium(of: 14)
        view.text = "00:00"
        return view
    }()
    
    fileprivate let timeRemainingLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        view.textColor = .white
        view.font = UIFont.gilroyMedium(of: 14)
        view.text = "00:00"
        return view
    }()
    
    fileprivate let stackControls: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.backgroundColor = .clear
        return stack
    }()
    
    fileprivate let repeatButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-repeat"), for: .normal)
        return view
    }()
    
    fileprivate let shuffleButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-shuffle"), for: .normal)
        view.setImage(UIImage(imgName: "ic-shuffle-active"), for: .selected)
        return view
    }()
    
    fileprivate let previousButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-previous"), for: .normal)
        return view
    }()
    
    fileprivate let nextButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-next"), for: .normal)
        return view
    }()
    
    fileprivate let playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-mainplayer-play"), for: .normal)
        view.setImage(UIImage(imgName: "ic-mainplayer-pause"), for: .selected)
        return view
    }()
    
    fileprivate let trackPlayingButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-mainplayer-playlist"), for: .normal)
        return view
    }()
    
    fileprivate let addToPlaylistButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-addtoplaylist"), for: .normal)
        return view
    }()
    
    fileprivate let viewContentBanner: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    var heightBanner : NSLayoutConstraint?
    var admodBanner: AdmobBanner?
    
    // MARK: - outlet
    
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupMainView()
        setupHeader()
        setupPlayerContainer()
        setupSlider()
        setupControls()
        setupFooter()
        setupObservers()
        updateDataForControls()
        
        MuPlayer.shared.delegate = self
        MuPlayer.shared.setupRemoteSystemControls()
        
        if self.track != nil {
            self.updateData(self.track)
            MuPlayer.shared.setPlaylist(self.playlist, currentTrack: self.track)
        }
        
        admodBanner = AdmobBanner { size, isSuccess in
            if isSuccess {
                self.heightBanner?.constant = size.height
                self.viewContentBanner.layoutIfNeeded()
            }
        }
        admodBanner!.addToViewIfNeed(parent: self.viewContentBanner, controller: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playButton.isSelected = MuPlayer.shared.isPlaying
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // bug when play offline the first
        if let _layer = MuPlayer.shared.playerLayer, let _supper = _layer.superlayer {
            if _layer.frame != _supper.bounds {
                _layer.frame = _supper.bounds
            }
        }
    }
    
    // MARK: - private
    fileprivate func updateDataForControls() {
        titleTrackLabel.text = ""
        subtileTrackLabel.text = ""
        thumbnailImage.image = Thumbnail.mainplayer
        
        timeLabel.text = 0.0.timeFormat()
        timeRemainingLabel.text = 0.0.timeFormat()
        
        playButton.isSelected = false
        shuffleButton.isSelected = false
        
        switch MuPlayer.shared.repeatState {
        case .one:
            repeatButton.setImage(UIImage(imgName: "ic-repeat-one"), for: .normal)
        case .all:
            repeatButton.setImage(UIImage(imgName: "ic-repeat-all"), for: .normal)
        case .off:
            repeatButton.setImage(UIImage(imgName: "ic-repeat"), for: .normal)
        }
        
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(forName: .databaseChanged, object: nil, queue: .main) { [weak self] _ in
            guard let self = self, let tr = self.track, !tr.isInvalidated else { return }
            
            // maybe update like state
            if let _ = DBService.shared.realm?.objects(TrackFavouriteObject.self).first(where: { $0.trackId == tr.trackId }) {
                self.likeButton.isSelected = true
            }
            else {
                self.likeButton.isSelected = false
            }
        }
        
        NotificationCenter.default.addObserver(forName: .updateState, object: nil, queue: .main) { [weak self] sender in
            if let tr = sender.object as? TrackObject, tr.trackId == self?.track.trackId {
                self?.updateState(tr)
            }
        }
    }
    
    fileprivate func updateData(_ track: TrackObject) {
        updateState(track)
        
        titleTrackLabel.text = track.title
        subtileTrackLabel.text = track.artist
        //thumbnailImage.sd_setImage(with: track.thumbnailURL, placeholderImage: Thumbnail.mainplayer, context: nil)
        
        if let _ = DBService.shared.realm?.objects(TrackFavouriteObject.self).first(where: { $0.trackId == track.trackId }) {
            likeButton.isSelected = true
        }
        else {
            likeButton.isSelected = false
        }
        
        nextButton.isEnabled = MuPlayer.shared.canNext()
        previousButton.isEnabled = MuPlayer.shared.canPrevious()
    }
    
    private func setupMainView() {
        view.backgroundColor = .clear
        view.addSubview(blurEffectView)
        blurEffectView.layoutEdges()
    }
    
    private func setupHeader() {
        dimissButton.addTarget(self, action: #selector(dimissClick), for: .touchUpInside)
        optionButton.addTarget(self, action: #selector(optionClick), for: .touchUpInside)
        
        view.addSubview(dimissButton)
        view.addSubview(airPlayButton)
        //view.addSubview(optionButton)
        
        dimissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        dimissButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        dimissButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        dimissButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        /*
        optionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        optionButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        optionButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        optionButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        */
        
        airPlayButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        airPlayButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        airPlayButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        airPlayButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func setupPlayerContainer() {
        likeButton.addTarget(self, action: #selector(likeClick), for: .touchUpInside)
        daolodButton.addTarget(self, action: #selector(daolodClick), for: .touchUpInside)
        
        view.addSubview(playerContainerView)
        view.addSubview(likeButton)
        view.addSubview(titleTrackLabel)
        view.addSubview(daolodButton)
        view.addSubview(loadingView)
        view.addSubview(subtileTrackLabel)
        
        playerContainerView.topAnchor.constraint(equalTo: dimissButton.bottomAnchor, constant: 50).isActive = true
        playerContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        playerContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 9.0 / 16.0).isActive = true
        
        likeButton.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 50).isActive = true
        likeButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        likeButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        daolodButton.topAnchor.constraint(equalTo: likeButton.topAnchor).isActive = true
        daolodButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        daolodButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        daolodButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        loadingView.topAnchor.constraint(equalTo: likeButton.topAnchor).isActive = true
        loadingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        titleTrackLabel.topAnchor.constraint(equalTo: likeButton.topAnchor).isActive = true
        titleTrackLabel.leftAnchor.constraint(equalTo: likeButton.rightAnchor, constant: 10).isActive = true
        titleTrackLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        titleTrackLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        subtileTrackLabel.topAnchor.constraint(equalTo: titleTrackLabel.bottomAnchor).isActive = true
        subtileTrackLabel.leftAnchor.constraint(equalTo: likeButton.rightAnchor, constant: 10).isActive = true
        subtileTrackLabel.rightAnchor.constraint(equalTo: daolodButton.leftAnchor, constant: -10).isActive = true
        subtileTrackLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        playerContainerView.addSubview(thumbnailImage)
        thumbnailImage.layoutEdges()
    }
    
    private func setupSlider() {
        slider.addTarget(self, action: #selector(playheadChanged(with:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(seekingEnd), for: .touchUpInside)
        slider.addTarget(self, action: #selector(seekingEnd), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(seekingStart), for: .touchDown)
        
        view.addSubview(slider)
        view.addSubview(timeLabel)
        view.addSubview(timeRemainingLabel)
        
        slider.topAnchor.constraint(equalTo: subtileTrackLabel.bottomAnchor, constant: 30).isActive = true
        slider.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
        slider.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 31).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        timeRemainingLabel.topAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        timeRemainingLabel.rightAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        timeRemainingLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        timeRemainingLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    
    private func setupControls() {
        repeatButton.addTarget(self, action: #selector(repeatClick), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextClick), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(shuffleClick), for: .touchUpInside)
        
        view.addSubview(stackControls)
        
        stackControls.addArrangedSubview(repeatButton)
        stackControls.addArrangedSubview(previousButton)
        stackControls.addArrangedSubview(playButton)
        stackControls.addArrangedSubview(nextButton)
        stackControls.addArrangedSubview(shuffleButton)
        
        stackControls.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 50).isActive = true
        stackControls.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        stackControls.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        stackControls.heightAnchor.constraint(equalToConstant: 67).isActive = true
    }
    
    private func setupFooter() {
        trackPlayingButton.addTarget(self, action: #selector(trackplayingClick), for: .touchUpInside)
        addToPlaylistButton.addTarget(self, action: #selector(addToPlaylistClick), for: .touchUpInside)
        
        view.addSubview(trackPlayingButton)
        view.addSubview(addToPlaylistButton)
        
        view.addSubview(viewContentBanner)
        
        viewContentBanner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        viewContentBanner.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        viewContentBanner.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        heightBanner = viewContentBanner.heightAnchor.constraint(equalToConstant: 0)
        heightBanner?.isActive = true
        
        trackPlayingButton.bottomAnchor.constraint(equalTo: viewContentBanner.topAnchor, constant: -5).isActive = true
        trackPlayingButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        trackPlayingButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        trackPlayingButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        addToPlaylistButton.topAnchor.constraint(equalTo: trackPlayingButton.topAnchor).isActive = true
        addToPlaylistButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        addToPlaylistButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        addToPlaylistButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    
    private func updateState(_ track: TrackObject) {
        switch DaoladService.shared.getState(track) {
        case .response:
            daolodButton.isHidden = false
            daolodButton.isSelected = true
            loadingView.isHidden = true
            loadingView.stopAnimating()
        case .inqueue:
            daolodButton.isHidden = true
            daolodButton.isSelected = false
            loadingView.isHidden = false
            loadingView.startAnimating()
        case .none:
            daolodButton.isHidden = false
            daolodButton.isSelected = false
            loadingView.isHidden = true
            loadingView.stopAnimating()
        }
    }
    
    // MARK: - public
    func play(with track: TrackObject, playlist: [TrackObject]) {
        self.track = track
        self.playlist = playlist
        
        if isViewLoaded {
            self.updateData(self.track)
            
            if shuffleButton.isSelected {
                self.playlist.shuffle()
                
                if let i = self.playlist.firstIndex(where: { $0.trackId == track.id }) {
                    self.playlist.swapAt(0, i)
                }
            }
            
            MuPlayer.shared.setPlaylist(self.playlist, currentTrack: self.track)
        }
    }
    
    func deleteTrackOnPlaylist(_ track: TrackObject) {
        self.playlist.removeAll(where: { $0.id == track.id })
    }
    
    // MARK: - event
    @objc func dimissClick() {
        //NotificationCenter.default.post(name: .willShowPlayerMini, object: nil)
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.dismiss(animated: true) { }
        }
    }
    
    @objc func optionClick() {
        
    }
    
    @objc func likeClick() {
        guard let tr = track else { return }
        
        super.addOrDeleteFavourite(tr)
    }
    
    @objc func daolodClick() {
        if track == nil { return }
        if DaoladService.shared.getState(track) != .none { return }
        
        self.waitcome(track)
    }
    
    @objc func repeatClick() {
        switch MuPlayer.shared.repeatState {
        case .off:
            MuPlayer.shared.repeatState = .one
            repeatButton.setImage(UIImage(imgName: "ic-repeat-one"), for: .normal)
        case .one:
            MuPlayer.shared.repeatState = .all
            repeatButton.setImage(UIImage(imgName: "ic-repeat-all"), for: .normal)
        case .all:
            MuPlayer.shared.repeatState = .off
            repeatButton.setImage(UIImage(imgName: "ic-repeat"), for: .normal)
        }
    }
    
    @objc func previousClick() {
        MuPlayer.shared.playPrevious()
    }
    
    @objc func playClick() {
        if MuPlayer.shared.isPlaying {
            MuPlayer.shared.pause()
        }
        else {
            MuPlayer.shared.resume()
        }
        playButton.isSelected = MuPlayer.shared.isPlaying
    }
    
    @objc func nextClick() {
        MuPlayer.shared.playNext()
    }
    
    @objc func shuffleClick() {
        shuffleButton.isSelected = !shuffleButton.isSelected
    }
    
    @objc func trackplayingClick() {
        let trackView = TrackPlayingView()
        trackView.track = track
        trackView.tracks = playlist
        trackView.onSelected = { [weak self] track in
            guard let self = self else { return }
            
            self.play(with: track, playlist: self.playlist)
        }
        trackView.show()
    }
    
    @objc func addToPlaylistClick() {
        guard let tr = track else { return }
        
        super.addToPlaylist(tr)
    }
    
    // slider
    @objc func seekingStart(sender: Any? = nil) {
        isSeeking = true
    }
    
    @objc func seekingEnd(sender: Any? = nil) {
        isSeeking = false
    }
    
    @objc func playheadChanged(with sender: UISlider) {
        isSeeking = true
        MuPlayer.shared.seekToTime(seconds: Float64(sender.value))
    }
}

extension PlayerMainController: MuPlayerDelegate {
    func preparePlay(track: TrackObject) {
        self.track = track
        self.slider.value = 0
        self.slider.minimumValue = 0
        self.slider.maximumValue = Float(MuPlayer.shared.duration)
        self.updateData(self.track)
        self.delegate?.preparePlay(track: self.track)
    }
    
    func readyToPlay(track: TrackObject) {
        self.track = track
        self.updateData(self.track)
    }
    
    func configAVPlayer(layer: AVPlayerLayer?, track: TrackObject) {
        guard let _layer = layer else { return }
        
        _layer.removeFromSuperlayer()
        _layer.frame = playerContainerView.bounds
        playerContainerView.layer.addSublayer(_layer)
    }
    
    func onTimeObserver(currentTime: Double, duration: Double) {
        playButton.isSelected = MuPlayer.shared.isPlaying
        
        if !isSeeking {
            slider.value = Float(currentTime)
        }
        slider.maximumValue = Float(duration)
        
        timeLabel.text = currentTime.timeFormat()
        timeRemainingLabel.text = (duration - currentTime).timeFormat()
        
        self.delegate?.onTimeObserver(currentTime: currentTime, duration: duration)
    }
    
    func willFindLink(track: TrackObject) {
        updateData(track)
    }
    
    func didFoundLink(track: TrackObject) {
        
    }
    
    func bufferChanged(timeValue: Float) {
        
    }
}
