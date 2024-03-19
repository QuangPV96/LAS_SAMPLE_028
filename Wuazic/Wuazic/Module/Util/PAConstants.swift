//
//  Constants.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UIKit

struct Thumbnail {
    static let artist = UIImage(imgName: "thumbnail-artist")
    static let trend = UIImage(imgName: "thumbnail-mainplayer")
    static let mainplayer = UIImage(imgName: "thumbnail-mainplayer")
    static let playlist = UIImage(imgName: "thumbnail-playlist")
    static let track = UIImage(imgName: "thumbnail-track")
    static let newest = UIImage(imgName: "thumbnail-newest")
}

public typealias MuDictionary = [String:Any?]
public typealias MuAnyHashable = [AnyHashable : Any]

struct AppSetting {
    static let id = "6476621391"
    static let email = "giraysazay@icloud.com"
    static let homepage = "https://giraysazay.github.io"
    static let privacy = "https://giraysazay.github.io/privacy.html"
    static let list_ads = "https://quangphung4396.github.io/movieios.github.io//list-adses-music.json"
    static let titleNoti = "lPlayer Videos"
    static let contentNoti = "lPlayer - Music Player & Videos"
    
    public static func getIDDevice() -> String {
        let key = "keysclientid"
        if MuKeychain.getString(forKey: key) == nil {
            let uuid = UUID().uuidString
            _ = MuKeychain.setString(value: uuid, forKey: key)
        }
        return MuKeychain.getString(forKey: key) ?? ""
    }
}

enum TrackType: Int {
    case unknow, offline, online
}

enum PlaylistType: Int {
    case manually, online
}

public enum AdsName: String {
    case admob, applovin
}

public enum AdsUnit: String {
    case banner, native, interstitial, open, reward
}

let kPadding: CGFloat = 15
let kMaxItemDisplay: Int = 15
