import UIKit
import RealmSwift

class CreatePlaylistView: BaseView {
    
    private let height: CGFloat = 410
    
    var playlist: PlaylistObject? {
        didSet {
            textField.text = playlist?.title
        }
    }
    var onUpdated: ((PlaylistObject) -> Void)?
    var onCreated: ((PlaylistObject) -> Void)?
    
    // MARK: - properties
    fileprivate let container1View: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x1B1C1D)
        return view
    }()
    
    fileprivate let container2View: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x242526)
        return view
    }()
    
    fileprivate let titleHeader: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Create new playlist"
        view.textColor = .white
        view.font = UIFont.gilroyBold(of: 18)
        return view
    }()
    
    fileprivate let closeButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Close", for: .normal)
        view.setTitleColor(UIColor(rgb: 0x00D1EE), for: .normal)
        view.titleLabel?.font = UIFont.gilroyMedium(of: 16)
        return view
    }()
    
    fileprivate let textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.returnKeyType = .done
        view.font = UIFont.gilroyMedium(of: 20)
        view.attributedPlaceholder = NSAttributedString(
            string: "ENTER YOUR PLAYLIST",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.3),
                         NSAttributedString.Key.font: UIFont.gilroyMedium(of: 20) as Any]
        )
        return view
    }()
    
    fileprivate let redView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(rgb: 0x00D1EE)
        return view
    }()
    
    fileprivate let saveButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("SAVE", for: .normal)
        view.setTitleColor(UIColor.black, for: .normal)
        view.titleLabel?.font = UIFont.gilroyBold(of: 16)
        view.backgroundColor = .white
        view.layer.cornerRadius = 23
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let errorLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.textColor = .red
        view.textAlignment = .center
        view.font = UIFont.italicSystemFont(ofSize: 16)
        view.numberOfLines = 0
        return view
    }()
    
    // MARK: - initital
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    deinit {
#if DEBUG
        print("RELEASED \(String(describing: self.self))")
#endif
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container1View.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        container2View.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveClick), for: .touchUpInside)
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditDidChange(_:)), for: .editingChanged)
        
        addSubview(container1View)
        addSubview(container2View)
        
        container2View.addSubview(titleHeader)
        container2View.addSubview(closeButton)
        container2View.addSubview(textField)
        container2View.addSubview(redView)
        container2View.addSubview(saveButton)
        container2View.addSubview(errorLabel)
        
        container1View.topAnchor.constraint(equalTo: topAnchor).isActive = true
        container1View.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        container1View.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        container1View.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        container2View.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        container2View.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        container2View.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        container2View.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        titleHeader.topAnchor.constraint(equalTo: container2View.topAnchor, constant: 20).isActive = true
        titleHeader.leftAnchor.constraint(equalTo: container2View.leftAnchor, constant: 20).isActive = true
        titleHeader.rightAnchor.constraint(equalTo: closeButton.leftAnchor).isActive = true
        titleHeader.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: container2View.topAnchor, constant: 20).isActive = true
        closeButton.rightAnchor.constraint(equalTo: container2View.rightAnchor, constant: -20).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        textField.centerYAnchor.constraint(equalTo: container2View.centerYAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: container2View.leftAnchor, constant: 20).isActive = true
        textField.rightAnchor.constraint(equalTo: container2View.rightAnchor, constant: -20).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        redView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0).isActive = true
        redView.leftAnchor.constraint(equalTo: container2View.leftAnchor, constant: 20).isActive = true
        redView.rightAnchor.constraint(equalTo: container2View.rightAnchor, constant: -20).isActive = true
        redView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        saveButton.centerXAnchor.constraint(equalTo: container2View.centerXAnchor).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: container2View.bottomAnchor, constant: -20).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        errorLabel.topAnchor.constraint(equalTo: redView.bottomAnchor).isActive = true
        errorLabel.leftAnchor.constraint(equalTo: container2View.leftAnchor, constant: 20).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: container2View.rightAnchor, constant: -20).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor).isActive = true
        
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
    }
    
    // MARK: - public
    func show() {
        guard let kWindow = UIWindow.keyWindow else { return }
        
        let paView = UIView(frame: kWindow.bounds)
        paView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        paView.alpha = 0
        paView.addSubview(self)
        kWindow.addSubview(paView)
        
        // update frame
        self.frame = CGRect(x: 0, y: kWindow.size.height, width: kWindow.size.width, height: self.height)
        
        // animate
        UIView.animate(withDuration: 0.3) {
            paView.alpha = 1
            self.frame = CGRect(x: 0, y: kWindow.size.height - self.height, width: kWindow.size.width, height: self.height)
            self.presentKeyboard()
        } completion: { _ in
            
        }
    }
    
    func close() {
        guard let paView = self.superview else { return }
        
        self.textField.resignFirstResponder() // hide keyboard
        
        UIView.animate(withDuration: 0.3) {
            paView.alpha = 0
            self.frame = CGRect(x: 0, y: paView.size.height, width: paView.size.width, height: self.height)
        } completion: { _ in
            self.removeFromSuperview()
            paView.removeFromSuperview()
        }
    }
    
    func presentKeyboard() {
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - event
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let paView = superview else { return }
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let frameNew = CGRect(x: 0,
                              y: paView.bounds.size.height - self.height - keyboardSize.height,
                              width: paView.bounds.size.width,
                              height: self.height)
        
        UIView.animate(withDuration: 0.3) {
            self.frame = frameNew
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        guard let paView = superview else { return }
        
        let frameNew = CGRect(x: 0,
                              y: paView.bounds.size.height - self.height,
                              width: paView.bounds.size.width,
                              height: self.height)
        
        UIView.animate(withDuration: 0.3) {
            self.frame = frameNew
        }
    }
    
    @objc func closeClick() {
        close()
    }
    
    @objc func saveClick() {
        let title = textField.textString
        if title.isEmpty {
            self.errorLabel.text = "The playlist name is empty"
            return
        }
        
        guard let realm = DBService.shared.realm else { return }
        
        // case rename
        if let pl = playlist {
            if let _ = realm.objects(PlaylistObject.self).first(where: { $0.title == title && $0.id != pl.id }) {
                self.errorLabel.text = "Already exists playlist '\(title)'"
                return
            }
            
            try? realm.write({
                pl.title = title
            })
            
            onUpdated?(pl)
            close()
            
        }
        else {
            // case: add new
            if let _ = realm.objects(PlaylistObject.self).first(where: { $0.title == title }) {
                self.errorLabel.text = "Already exists playlist '\(title)'"
                return
            }
            
            let playlist = PlaylistObject()
            playlist.title = title
            
            try? realm.write {
                realm.add(playlist)
            }
            
            onCreated?(playlist)
            close()
        }
    }
    
    @objc func textFieldEditDidChange(_ sender: Any) {
        self.errorLabel.text = ""
    }
    
}

extension CreatePlaylistView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
