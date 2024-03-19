import RealmSwift

class SettingObject: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var key: String = ""
    @objc dynamic var value: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class ArtistObject: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var browseId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var subscribers: String = ""
    @objc dynamic var image: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension ArtistObject {
    var thumbnailURL: URL? {
        return URL(string: image)
    }
    
    class func parse(_ data: MuAnyHashable) -> ArtistObject {
        let artist = ArtistObject()
        artist.browseId = (data["browseId"] as? String) ?? ((data["playlistId"] as? String) ?? "")
        artist.title = (data["title"] as? String) ?? ""
        artist.subscribers = (data["subscribers"] as? String) ?? ((data["description"] as? String) ?? "")
        artist.image = (data["image"] as? String) ?? ""
        return artist
    }
}
