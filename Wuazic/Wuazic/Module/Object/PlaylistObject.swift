//
//  PlaylistObject.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import RealmSwift
import AVKit

class PlaylistObject: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var artist: String = ""
    
    dynamic var tracks: List<TrackObject> = List()
    
    // online
    @objc dynamic var playlistId: String?
    @objc dynamic var playlistThumbnailUrl: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension PlaylistObject {
    var type: PlaylistType {
        return playlistId != nil ? .online : .manually
    }
    
    var first: TrackObject? {
        return tracks.first
    }
    
    var trackThumbnailUrl: URL? {
        return URL(string: playlistThumbnailUrl ?? "") ?? first?.thumbnailURL
    }
    
    var trackLastThumbnailUrl: URL? {
        return URL(string: playlistThumbnailUrl ?? "") ?? tracks.last?.thumbnailURL
    }
    
    var detail: String {
        if !artist.isEmpty {
            return artist
        }
        if tracks.count == 0 {
            return "0 track"
        }
        return tracks.count > 1 ? "\(tracks.count) tracks" : "1 track"
    }
    
    class func parse(_ data: MuAnyHashable) -> PlaylistObject {
        let playlist = PlaylistObject()
        playlist.title = (data["title"] as? String) ?? ""
        playlist.artist = (data["description"] as? String) ?? ""
        playlist.playlistId = (data["browseId"] as? String) ?? ""
        playlist.playlistThumbnailUrl = (data["image"] as? String) ?? ""
        return playlist
    }
}
