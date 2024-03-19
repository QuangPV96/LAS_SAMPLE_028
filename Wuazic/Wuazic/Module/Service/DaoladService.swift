//
//  DaoladService.swift
//  SwiftyAds
//
//  Created by MinhNH on 21/04/2023.
//

import UIKit

class ImageMode: NSObject {
    let id: String
    let url: URL
    var ok: Bool = false
    
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}

class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.asyncoperation", attributes: .concurrent)
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        
        isFinished = false
        isExecuting = true
        main()
    }
    
    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}

final class ImageAsyncOperation: AsyncOperation {
    
    private let image: ImageMode
    private var task: URLSessionTask?
    
    init(image: ImageMode) {
        self.image = image
    }
    
    override func main() {
        let request = URLRequest(url: image.url)
        task = URLSession.shared.dataTask(with: request) { [unowned self] data, response, error in
            guard let _data = data else {
                self.finish()
                return
            }
            
            if !_data.isEmpty {
                let uluus = URL.data().appendingPathComponent("\(self.image.id).mp4")
                
                do {
                    try _data.write(to: uluus)
                    print("saved \(uluus)")
                } catch {
                    print(error)
                }
            }
            
            self.finish()
            
        }
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}

enum WaitSate {
    case response, inqueue, none
}

class DaoladService: NSObject {
    
    // MARK: - properties
    lazy var waitInProgress: [String: ImageAsyncOperation] = [:]
    lazy var waitQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "waitcome"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: - initial
    static let shared = DaoladService()
    
    override init() { }
    
    // MARK: - private
    private func taskCompletion(_ track: TrackObject, id: String) {
        self.waitInProgress.removeValue(forKey: id)
        
        guard let lastPath = track.lastPath else { return }
        
        let uluus = URL.document().appendingPathComponent(lastPath)
        if FileManager.default.fileExists(atPath: uluus.path) {
            guard let realm = DBService.shared.realm else { return }
            
            if realm.objects(TrackObject.self).first(where: { $0.trackId == id }) == nil {
                try? realm.write({
                    realm.add(track)
                })
                
                NotificationCenter.default.post(name: .updateState, object: track)
                
                NotificationCenter.default.post(name: .databaseChanged, object: nil)
                
                SwiftMessagesHelper.shared.showSuccess(title: "Sucess")
            }
        }
    }
    
    // MARK: - public
    func getState(_ track: TrackObject) -> WaitSate {
        if track.type == .offline {
            return .response
        }
        if self.waitInProgress[track.trackId ?? ""] != nil {
            return .inqueue
        }
        return .none
    }
    
    func waitcome(_ track: TrackObject, retry: Bool = true) {
        guard let id = track.trackId else { return }
        
        NetworksService.shared.findLink(id: id) { [weak self] link in
            guard let self = self else { return }
            guard let url = URL(string: link ?? "") else {
                /*
                 if retry {
                 self.waitcome(track, retry: false)
                 }
                 */
                return
            }
            
            if self.waitInProgress[id] != nil {
                return
            }
            
            let imgMode = ImageMode(id: id, url: url)
            let imageObj = ImageAsyncOperation(image: imgMode)
            imageObj.completionBlock = {
                DispatchQueue.main.async {
                    self.taskCompletion(track, id: id)
                }
            }
            self.waitInProgress[id] = imageObj
            self.waitQueue.addOperation(imageObj)
            
            NotificationCenter.default.post(name: .updateState, object: track)
        }
    }
    
}
