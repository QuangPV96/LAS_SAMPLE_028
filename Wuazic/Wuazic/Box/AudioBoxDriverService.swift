
import UIKit
import BoxSDK
import AuthenticationServices

enum AudioBoxError: Error {
    case NotAuthorized
    case OffsetNotExists
}

enum AudioBoxEnum {
    case video
    case audio
    case all
}


class AudioBoxDriverService: NSObject {
    private var boxSdk: BoxSDK!
    private var boxClient: BoxClient?
    private var window: UIWindow?
    private var page: Int = 0
    private var more: Bool = false
    var boxAuthorized: Bool {
        return boxClient != nil
    }
    
    // current user logged
    var userBox: User?
    
    static let getInstance = AudioBoxDriverService()
    
    override init() {
    }
    
    func awake() {
        boxSdk = BoxSDK(clientId: clientId, clientSecret: clientSecret)
        KeychainTokenStore().read { (result) in
            switch result {
            case .success(_):
                self.signIn { success in
                    self.requestCurrentAccount { (user) in }
                }
            case let .failure(error):
                print("Error read keychain BoxSdk: \(error.localizedDescription)")
            }
        }
    }
    
    func requestCurrentAccount(_ completion: @escaping (_ user: User?) -> Void) {
        guard let cl = boxClient else {
            self.userBox = nil
            completion(nil)
            return
        }
        cl.users.getCurrent(fields: ["name", "login"]) { (result: Result<User, BoxSDKError>) in
            guard case let .success(user) = result else {
                DispatchQueue.main.async {
                    self.userBox = nil
                }
                return
            }
            DispatchQueue.main.async {
                self.userBox = user
                completion(user)
            }
        }
    }
    
    func signIn(_ completion: @escaping (_ success: Bool) -> Void) {
        if #available(iOS 13, *) {
            boxSdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context:self) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.boxClient = client
                case let .failure(error):
                    self?.boxClient = nil
                    print("error in getOAuth2Client: \(error)")
                }
                DispatchQueue.main.async {
                    completion(self?.boxClient != nil)
                }
            }
        } else {
            boxSdk.getOAuth2Client(tokenStore: KeychainTokenStore()) { [weak self] result in
                switch result {
                case let .success(client):
                    self?.boxClient = client
                case let .failure(error):
                    self?.boxClient = nil
                    print("error in getOAuth2Client: \(error)")
                }
                DispatchQueue.main.async {
                    completion(self?.boxClient != nil)
                }
            }
        }
    }
    
    func signOut() {
        boxClient = nil
        userBox = nil
        KeychainTokenStore().clear { (result) in
            switch result {
            case .success(): break
            case let .failure(error):
                print(error)
            }
        }
        
    }
    
    func search(_ media: AudioBoxEnum, completion: @escaping (_ files: [File], _ error: Error?) -> Void) {
        guard let cl = boxClient else {
            completion([], AudioBoxError.NotAuthorized)
            return
        }
        var q = ""
        
        switch media {
        case .video:
            q = "*.mp4 OR *.mov OR *.mpeg"
        case .audio:
            q = "*.mp3 OR *.m4a OR *.wav"
            
        case .all:
            q = "*.mp4 OR *.mov OR *.mpeg OR .mp3 OR *.m4a OR *.wav"
        }
   
        
        // only get max 200 items
        let iterator = cl.search.query(query: q, itemType: .file, limit: 200)
        
        iterator.next { results in
            switch results {
            case let .success(page):
                var result: [File] = []
                
                for item in page.entries {
                    switch item {
                    case let .file(file):
                        result.append(file)
                    default: break
                    }
                }
                
                completion(result, nil)
                
            case let .failure(err):
                completion([], err.error)
                print(err)
            }
        }
    }
    
    func download(_ fileItem: File?, progressBlock: @escaping (Progress) -> Void, completion: @escaping ((Bool, String) -> Void)) {
        guard let fileItem = fileItem, let cl = boxClient, let name = fileItem.name else {
            completion(false, "")
            return
        }
        let newName = name.replacingOccurrences(of: " ", with: "")

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsURL.appendingPathComponent(newName)
        
        cl.files.download(fileId: fileItem.id, destinationURL: url, version: nil, progress: progressBlock) { (result: Result<Void, BoxSDKError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(true, newName)
                    print("File downloaded successfully")
                case .failure(let failure):
                    print("Error downloading file: \(failure.localizedDescription)")
                    completion(false, "")
                }
            }
        }
    }
    
}

extension AudioBoxDriverService: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.window ?? ASPresentationAnchor()
    }
}
