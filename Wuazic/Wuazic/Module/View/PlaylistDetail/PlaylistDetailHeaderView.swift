import UIKit

class PlaylistDetailHeaderView: BaseView {
    
    static var height: CGFloat {
        return 70
    }
    
    var onShuffle: ((PlaylistObject) -> Void)?
    var onPlay: ((PlaylistObject) -> Void)?
    
    var playlist: PlaylistObject! {
        didSet {
            titleLabel.text = playlist.title
            subtitleLabel.text = playlist.detail
        }
    }
    
    // MARK: - properties
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 20)
        return view
    }()
    
    fileprivate let subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .init(rgb: 0x8B8B8B)
        view.font = UIFont.gilroy(of: 14)
        return view
    }()
    
    fileprivate let shuffleButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-playlist-shuffle"), for: .normal)
        return view
    }()
    
    fileprivate let playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-playlist-play"), for: .normal)
        return view
    }()
    
    fileprivate let lineRedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x00D1EE)
        view.isHidden = true
        return view
    }()
    
    // MARK: - initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        //backgroundColor = .init(rgb: 0x0E0D0D)
        
        shuffleButton.addTarget(self, action: #selector(shuffleClick), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playClick), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(shuffleButton)
        addSubview(playButton)
        addSubview(lineRedView)
        
        playButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 74).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        shuffleButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        shuffleButton.rightAnchor.constraint(equalTo: playButton.leftAnchor, constant: -15).isActive = true
        shuffleButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        shuffleButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: shuffleButton.leftAnchor, constant: -5).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        subtitleLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
        subtitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        lineRedView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lineRedView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        lineRedView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        lineRedView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    // MARK: - public
    
    // MARK: - event
    @objc func shuffleClick() {
        onShuffle?(playlist)
    }
    
    @objc func playClick() {
        onPlay?(playlist)
    }
}
