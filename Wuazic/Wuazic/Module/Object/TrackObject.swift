import UIKit
import RealmSwift

class TrackObject: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var length: Double = 0.0
    
    // online
    @objc dynamic var trackId: String?
    @objc dynamic var trackThumbnailUrl: String?
    
    var time: String?
    var playlistId: String?
    var trackUrl: String?   // use to play
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension TrackObject {
    var lastPath: String? {
        return trackId == nil ? nil : "data/\(trackId!).mp4"
    }
    
    var type: TrackType {
        if let _path = lastPath {
            let uls = URL.document().appendingPathComponent(_path)
            if FileManager.default.fileExists(atPath: uls.path) {
                return .offline
            }
        }
        if trackId != nil || trackUrl != nil { return .online }
        return .unknow
    }
    
    var absolutePath: URL? {
        if type == .offline, let _path = lastPath {
            return URL.document().appendingPathComponent(_path)
        }
        return nil
    }
    
    var subtitle: String {
        var list: [String] = self.length > 0 ? [self.length.timeFormat()] : []
        if !self.artist.isEmpty {
            list.append(self.artist)
        }
        if list.count == 0, let tt = self.time, !tt.isEmpty {
            list.append(tt)
        }
        return list.count == 0 ? "N/A" : list.joined(separator: " - ")
    }
    
    var thumbnailURL: URL? {
        return URL(string: trackThumbnailUrl ?? "")
    }
    
    var thumbnailMaxResURL: URL? {
        return URL(string: "https://img.youtube.com/vi/\(trackId ?? "")/maxresdefault.jpg")
    }
}

extension TrackObject {
    class func parse(_ data: MuAnyHashable) -> TrackObject? {
        guard let title = data["title"] as? String, let videoId = data["videoId"] as? String else { return nil }
        
        let track = TrackObject()
        track.title = title
        track.trackId = videoId
        track.trackThumbnailUrl = (data["thumbnail"] as? String) ?? ((data["image"] as? String) ?? "")
        track.artist = (data["description"] as? String) ?? ((data["subtitle"] as? String) ?? "")
        track.playlistId = (data["playlistId"] as? String) ?? ((data["browseId"] as? String) ?? "")
        track.time = ""
        
        if let tt = data["time"] as? String {
            track.time = " \(tt) "
        }
        
        return track
    }
}
