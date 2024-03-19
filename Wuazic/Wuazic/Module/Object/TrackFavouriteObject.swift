import Foundation
import RealmSwift

class TrackFavouriteObject: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var length: Double = 0.0
    
    // local
    @objc dynamic var relativePath: String?
    
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

extension TrackFavouriteObject {
    func toTrack() -> TrackObject {
        let track = TrackObject()
        track.title = self.title
        track.artist = self.artist
        track.length = self.length
        track.trackId = self.trackId
        track.trackThumbnailUrl = self.trackThumbnailUrl
        track.time = self.time
        track.playlistId = self.playlistId
        return track
    }
    
    func loadTrack(track: TrackObject) {
        self.title = track.title
        self.artist = track.artist
        self.length = track.length
        self.trackId = track.trackId
        self.trackThumbnailUrl = track.trackThumbnailUrl
        self.time = track.time
        self.playlistId = track.playlistId
    }
}
