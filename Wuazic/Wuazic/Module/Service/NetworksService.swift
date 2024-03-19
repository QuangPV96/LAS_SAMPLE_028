import Foundation
import SwiftSoup

private let prefixSrcImage = "data:image/jpeg;"
public enum AltEnum: String {
    case setting = "999"
    case getLi = "get-lynk"
    case getVi = "det-vydeo"
    case getPl = "det-plailyst"
    case suggestTerm = "sug-term"
    case upNext = "up-next"
    case search = "fynd-seach"
    
    case searchAll = "fynd-seach-all"
    case searchSong = "fynd-seach-song"
    case searchVideo = "fynd-seach-video"
    case searchArtist = "fynd-seach-artist"
    case searchPlaylist = "fynd-seach-playlist"
    case searchAlbum = "fynd-seach-album"
    case searchGenre = "fynd-seach-genres"
    
    case searchArtistDetail = "fynd-seach-artist-detail"
    case playlistOrAlbumDetail = "playlist-or-album-detail"
    case genreDetail = "fynd-seach-genres-detail"
    
    case humHottest = "hum-hottest"
    case humNewst = "hum-newst"
    case humArtits = "hum-artits"
    case humRecommend = "hum-recommend"
    case humTredn = "hum-tredn"
    case humNewstDetail = "hum-newst-detail"
    case humArtitsDetail = "hum-artits-detail"
    
    func description() -> String {
        return UserDefaults.standard.string(forKey: self.rawValue) ?? ""
    }
}

public enum SearchType: Int {
    case video = 1
    case playlist = 2
}

class NetworksService: NSObject {
    fileprivate var hosst: String {
        return (UserDefaults.standard.string(forKey: "hosst") ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - properties
    fileprivate var id: String {
        get {
            if UserDefaults.standard.string(forKey: "keysclientid") == nil {
                UserDefaults.standard.set(UUID().uuidString, forKey: "keysclientid")
            }
            return UserDefaults.standard.string(forKey: "keysclientid") ?? ""
        }
    }
    
    // MARK: - initial
    public static let shared = NetworksService()
    public override init() {
        super.init()
    }
    
    // MARK: - private
    fileprivate func analyticsPage(_ link: String, params: [String: Any], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: link) else {
            completion(nil)
            return
        }
        
        let json = (try? params.jsonString()) ?? ""
        let zztok = (try? AesCbCService().encrypt(json)) ?? ""
        
        var request = URLRequest(url: url)
        request.addValue(zztok, forHTTPHeaderField: "Cookie")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _data = data, let html = String(data: _data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            var srcSetting: String? = nil
            do {
                let doc: Document = try SwiftSoup.parse(html)
                let imgTags = try doc.select("img")
                
                for tag in imgTags.array() {
                    guard var src = try? tag.attr("src") else {
                        continue
                    }
                    
                    let alt = (try? tag.attr("alt")) ?? ""
                    
                    src = src.replacingOccurrences(of: prefixSrcImage, with: "")
                    
                    if let srcDe = try? AesCbCService().decrypt(src) {
                        switch alt {
                        case AltEnum.setting.rawValue:
                            srcSetting = srcDe
                            LogService.shared.show("saved setting")
                            
                        default:
                            if let list = srcDe.toArrayJson {
                                for json in list {
                                    if let key = json["key"] as? String, let value = json["value"] as? String {
                                        UserDefaults.standard.set(value, forKey: key)
                                        UserDefaults.standard.synchronize()
                                        
                                        LogService.shared.show("saved \(key)")
                                    }
                                }
                            }
                        }
                    }
                }
                
            } catch { }
            
            DispatchQueue.main.async {
                completion(srcSetting)
            }
            
        }.resume()
    }
    
    @discardableResult
    fileprivate func saveDataCommon(_ json: MuDictionary) -> Bool {
        var time: Date?
        if let timeString = json["time"] as? String {
            time = timeString.toDate()
        }
        
        var adses: [AdsObject] = []
        for item in (json["networks"] as? [MuDictionary]) ?? [] {
            adses.append(AdsObject.createInstance(item))
        }
        
        let isRating = (json["isNotification"] as? Bool) ?? false
        let extra = json["extra"] as? String
        var user_defaults: [MuDictionary] = []
        if let json = extra?.toJson {
            user_defaults = (json["user_defaults"] as? [MuDictionary]) ?? []
        }
        
        let version = (json["version"] as? Int) ?? 0
        let isSaved = writeData(time: time, adses: adses, isRating: isRating, extra: extra, userdefaults: user_defaults, version: version)
        if isSaved {
            DataCommonModel.shared.readData()
        }
        return isSaved
    }
    
    @discardableResult
    fileprivate func writeData(time: Date?, adses: [AdsObject], isRating: Bool, extra: String?, userdefaults: [MuDictionary], version: Int) -> Bool {
        let version_latest_saved: Int = UserDefaults.standard.integer(forKey: "version_latest_saved")
        if version_latest_saved != version {
            let dic: MuDictionary = [
                "time": time?.timeIntervalSince1970,
                "adses": (adses.count == 0 ? adsesDefault : adses).map({ $0.toDictionary() }),
                "isRating": isRating,
                "extra": extra
            ]
            
            do {
                // save data
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
                let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
                UserDefaults.standard.set(jsonString, forKey: "dataCommonSaved")
                UserDefaults.standard.synchronize()
                
                // save userdefaults
                for item in userdefaults {
                    for (key, value) in item {
                        UserDefaults.standard.set(value, forKey: key)
                        UserDefaults.standard.synchronize()
                    }
                }
                
                LogService.shared.show("saved dattdataCommonSaved")
                
                // save version
                UserDefaults.standard.set(version, forKey: "version_latest_saved")
                UserDefaults.standard.synchronize()
                
                return true
                
            } catch (let err) {
                LogService.shared.show(err.localizedDescription)
            }
        }
        return false
    }
    
    // MARK: - public
    public func dataCommonSaved() -> MuDictionary {
        let defaultDic: MuDictionary = [
            "time": nil,
            "adses": adsesDefault.map({ $0.toDictionary() }),
            "isRating": nil,
            "extra": nil
        ]
        
        if let str = UserDefaults.standard.string(forKey: "dataCommonSaved") {
            return str.toJson ?? defaultDic
        }
        return defaultDic
    }
    
    public func getScript(_ alt: AltEnum) -> String? {
        return UserDefaults.standard.string(forKey: alt.rawValue)
    }
}

extension NetworksService {
    public func decode(src: String) -> String {
        if let src = try? AesCbCService().decrypt(src) {
            return src
        }
        return ""
    }
    
    private func findTextReal(data: Data?, response: URLResponse?, error: Error?) -> String? {
        guard let _data = data, let html = String(data: _data, encoding: .utf8) else {
            return nil
        }
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let imgTags = try doc.select("img")
            
            for tag in imgTags.array() {
                guard var src = try? tag.attr("src") else {
                    continue
                }
                
                src = src.replacingOccurrences(of: prefixSrcImage, with: "")
                
                if let srcDe = try? AesCbCService().decrypt(src) {
                    return srcDe
                }
            }
            
        } catch { }
        
        return nil
    }
    
    private func makeParams() -> [String: Any] {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        print(version)
        return ["time": Date().timeIntervalSince1970, "id": id, "version": version]
    }
    
    public func checkNetwork(completion: @escaping (Bool) -> Void) {
        self.analyticsPage(self.hosst, params: self.makeParams()) { [weak self] data in
            if let _s = data {
                let json: MuDictionary? = _s.toJson
                if let new_json = json {
                    self?.saveDataCommon(new_json)
                }
            }
            completion(true)
        }
    }
    
    
}

extension NetworksService {
    // MARK: - search
    func suggestion(term: String, completion: @escaping (_ data: [String]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.suggestTerm.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [term]) { value in
            if let val = value, val.isArray, let result = val.toArray() as? [String] {
                completion(result)
            }
            else {
                completion([])
            }
        }
    }
    
    // MARK: - other
    func findHLLS(id: String, completion: @escaping (_ url: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.getLi.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [id, 0]) { value in
            if let val = value, val.isObject, let dictionary = val.toDictionary(),
               let data = dictionary["data"] as? MuAnyHashable,
               let url = data["url"] as? String
            {
                completion(url)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func findLink(id: String, completion: @escaping (_ url: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.getLi.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [id, 1]) { value in
            if let val = value, val.isObject, let dictionary = val.toDictionary(),
               let data = dictionary["data"] as? MuAnyHashable,
               let url = data["url"] as? String
            {
                completion(url)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func upNext(id: String, completion: @escaping (_ data: [TrackObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.upNext.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [id]) { value in
            guard let val = value,
                  let dictionary = val.toDictionary(),
                  let data = dictionary["data"] as? MuAnyHashable,
                  let videos = data["videos"] as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var result: [TrackObject] = []
            for it in videos {
                let track = TrackObject()
                track.title = (it["title"] as? String) ?? ""
                track.trackId = (it["videoId"] as? String) ?? ""
                track.trackThumbnailUrl = (it["thumbnail"] as? String) ?? ""
                track.artist = (it["content"] as? String) ?? ""
                track.time = (it["time"] as? String) ?? ""
                result.append(track)
            }
            completion(result)
        }
    }
    
    func trending(completion: @escaping (_ data: [TrackObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humTredn.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: []) { value in
            guard let val = value, val.isArray,
                  let dictionary = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var result: [TrackObject] = []
            for item in dictionary {
                if let obj = TrackObject.parse(item) {
                    result.append(obj)
                }
            }
            completion(result)
        }
    }
    
    func newest(completion: @escaping (_ data: [TrackObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humNewst.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: []) { value in
            guard let val = value, val.isArray,
                  let results = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var result: [TrackObject] = []
            for item in results {
                if let obj = TrackObject.parse(item) {
                    result.append(obj)
                }
            }
            completion(result)
        }
    }
    
    func newestDetail(trackId: String, playlistId: String, completion: @escaping (_ data: [TrackObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humNewstDetail.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [trackId, playlistId]) { value in
            guard let val = value, val.isArray,
                  let results = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var result: [TrackObject] = []
            for item in results {
                if let obj = TrackObject.parse(item) {
                    result.append(obj)
                }
            }
            completion(result)
        }
    }
    
    func hottest(completion: @escaping (_ data: [TrackObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humHottest.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: []) { value in
            guard let val = value, val.isArray,
                  let results = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var result: [TrackObject] = []
            for item in results {
                if let obj = TrackObject.parse(item) {
                    result.append(obj)
                }
            }
            completion(result)
        }
    }
    
    func artists(completion: @escaping (_ data: [ArtistObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humArtits.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: []) { value in
            guard let val = value, val.isArray,
                  let dictionary = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            let result = dictionary.map({ ArtistObject.parse($0) })
            completion(result)
        }
    }
    
    func artistDetail(artistId: String, completion: @escaping (_ songs: [TrackObject], _ videos: [TrackObject], _ playlists: [PlaylistObject], _ albums: [PlaylistObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humArtitsDetail.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [artistId]) { value in
            guard let val = value, val.isArray,
                  let listDictionary = val.toArray() as? [MuAnyHashable] else
            {
                completion([], [], [], [])
                return
            }
            
            var songs: [TrackObject] = []
            var videos: [TrackObject] = []
            var playlists: [PlaylistObject] = []
            var albums: [PlaylistObject] = []
            
            for dictionary in listDictionary {
                if let type = dictionary["type"] as? String, let contents = dictionary["contents"] as? [MuAnyHashable] {
                    if type == "song" {
                        for it in contents {
                            if let obj = TrackObject.parse(it) {
                                songs.append(obj)
                            }
                        }
                    }
                    else if type == "video" {
                        for it in contents {
                            if let obj = TrackObject.parse(it) {
                                videos.append(obj)
                            }
                        }
                    }
                    else if type == "featured" {
                        playlists = contents.map({ PlaylistObject.parse($0) })
                    }
                    else if type == "album" {
                        albums = contents.map({ PlaylistObject.parse($0) })
                    }
                }
            }
            
            completion(songs, videos, playlists, albums)
        }
    }
    
    func recommend(completion: @escaping (_ data: [TrackObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.humRecommend.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: []) { value in
            guard let val = value, val.isArray,
                  let results = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var result: [TrackObject] = []
            for item in results {
                if let obj = TrackObject.parse(item) {
                    result.append(obj)
                }
            }
            completion(result)
        }
    }
    
    /// only support search
    func searchSingle(term: String, scip: String, continuation: String?, completion: @escaping (_ data: [TrackObject], _ c: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(scip)
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [term, continuation]) { value in
            guard let val = value, val.isArray, let dictionary = val.toArray().first as? MuAnyHashable else {
                completion([], nil)
                return
            }
            
            let contents = (dictionary["contents"] as? [MuAnyHashable]) ?? []
            let c = dictionary["continuation"] as? String
            
            var result: [TrackObject] = []
            for item in contents {
                if let obj = TrackObject.parse(item) {
                    result.append(obj)
                }
            }
            
            completion(result, c)
        }
    }
    
    func searchPlaylist(term: String, continuation: String?, completion: @escaping (_ data: [PlaylistObject], _ token: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.searchPlaylist.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [term, continuation]) { value in
            guard let val = value, val.isArray, let dictionary = val.toArray().first as? MuAnyHashable else {
                completion([], nil)
                return
            }
            
            let contents = (dictionary["contents"] as? [MuAnyHashable]) ?? []
            let c = dictionary["continuation"] as? String
            
            let result = contents.map({ PlaylistObject.parse($0) })
            completion(result, c)
        }
    }
    
    func searchAlbum(term: String, continuation: String?, completion: @escaping (_ data: [PlaylistObject], _ token: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.searchAlbum.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [term, continuation]) { value in
            guard let val = value, val.isArray, let dictionary = val.toArray().first as? MuAnyHashable else {
                completion([], nil)
                return
            }
            
            let contents = (dictionary["contents"] as? [MuAnyHashable]) ?? []
            let c = dictionary["continuation"] as? String
            
            let result = contents.map({ PlaylistObject.parse($0) })
            completion(result, c)
        }
    }
    
    func searchArtist(term: String, continuation: String?, completion: @escaping (_ data: [ArtistObject], _ token: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.searchArtist.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [term, continuation]) { value in
            guard let val = value, val.isArray, let dictionary = val.toArray().first as? MuAnyHashable else {
                completion([], nil)
                return
            }
            
            let contents = (dictionary["contents"] as? [MuAnyHashable]) ?? []
            let c = dictionary["continuation"] as? String
            
            let result = contents.map({ ArtistObject.parse($0) })
            completion(result, c)
        }
    }
    
    func playlistOrAlbumDetail(browseId: String, continuation: String?, completion: @escaping (_ data: [TrackObject], _ continuation: String?) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.playlistOrAlbumDetail.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [browseId, continuation]) { value in
            guard let val = value, val.isObject,
                  let dictionary = val.toDictionary(),
                  let results = dictionary["results"] as? [MuAnyHashable] else
            {
                completion([], nil)
                return
            }
            
            var data: [TrackObject] = []
            for it in results {
                if let obj = TrackObject.parse(it) {
                    data.append(obj)
                }
            }
            completion(data, dictionary["continuation"] as? String)
        }
    }
    
    func genres(completion: @escaping (_ data: [GenreObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.searchGenre.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: []) { value in
            guard let val = value, val.isObject,
                  let dictionary = val.toDictionary(),
                  let data = dictionary["data"] as? MuAnyHashable,
                  let results = data["content"] as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            var i: Int = 0
            var tmp: [GenreObject] = []
            for it in results {
                if i > 33 {
                    i = 0
                }
                
                let g = GenreObject(it)
                g.imageName = "\(i)"
                tmp.append(g)
                
                i += 1
            }
            
            completion(tmp)
        }
    }
    
    func genreDetail(p: String, bId: String, completion: @escaping (_ data: [GenreDetailObject]) -> Void) {
        let context = MuJSContext()
        context?.loadScript(AltEnum.genreDetail.description())
        
        MuJSCore.shared.execFuncWithRequest(context, funcName: "init", arguments: [bId, p]) { value in
            guard let val = value, val.isArray,
                  let results = val.toArray() as? [MuAnyHashable] else
            {
                completion([])
                return
            }
            
            let tmp = results.map({ GenreDetailObject($0) })
            completion(tmp)
        }
    }
    
    public func postEvent(event: [String: Any]) {
        let packageModel = PackageModel()
        packageModel.event = event
        NetworksService.shared.postEvent([packageModel])
      }
    
    public func postEvent(_ events: [PackageModel]) {
        let ev = events.map({ $0.toDictionary() })
        let package = ev.toJSONString()

        guard let url = URL(string: "\(self.hosst)/polling"),
           let packageEn = try? AesCbCService().encrypt(package)
        else {
          return
        }

        let parameters = [
          "package": packageEn
        ]
        let postData = parameters.toString().data(using: .utf8)

        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else { return }
        }
        task.resume()
      }
    
}
