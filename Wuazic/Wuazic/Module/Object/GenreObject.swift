import UIKit

class GenreObject: NSObject {
    var title: String = ""
    var bId: String = ""
    var pa: String = ""
    var imageName: String = ""
    
    override init() { }
    
    init(_ data: MuAnyHashable) {
        self.title = (data["title"] as? String) ?? ""
        self.bId = (data["browseId"] as? String) ?? ""
        self.pa = (data["params"] as? String) ?? ""
    }
}

extension GenreObject {
    var imageThumbnail: UIImage? {
        return UIImage(imgName: imageName)
    }
}

class GenreDetailObject: NSObject {
    var title: String = ""
    var bId: String = ""
    var pa: String = ""
    var playlist: [PlaylistObject] = []
    
    init(_ data: MuAnyHashable) {
        self.title = (data["title"] as? String) ?? ""
        self.bId = (data["browseId"] as? String) ?? ""
        self.pa = (data["params"] as? String) ?? ""
        
        if let content = data["content"] as? [MuAnyHashable] {
            for it in content {
                let p = PlaylistObject()
                p.title = (it["title"] as? String) ?? ""
                p.artist = (it["description"] as? String) ?? ""
                p.playlistId = (it["browseId"] as? String) ?? ""
                p.playlistThumbnailUrl = (it["image"] as? String) ?? ""
                self.playlist.append(p)
            }
        }
    }
}

extension GenreDetailObject {
    func toGenre() -> GenreObject {
        let g = GenreObject()
        g.title = title
        g.bId = bId
        g.pa = pa
        return g
    }
}
