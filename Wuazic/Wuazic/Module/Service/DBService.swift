//
//  DBService.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UIKit
import RealmSwift

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

public class DBService: NSObject {
    
    // MARK: - property
    internal var realm: Realm? {
        return try? Realm(configuration: config)
    }
    
    private var config: Realm.Configuration {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentFolder = paths[0]
        let file = documentFolder.appendingPathComponent("database.realm")
        return Realm.Configuration(fileURL: file, schemaVersion: 1)
    }
    
    private var token: NotificationToken?
    
    @objc public static let shared = DBService()
    
    // MARK: - init
    override init() { }
    
    // MARK: - private
    private func fromBase64(s: String) -> String? {
        guard let data = Data(base64Encoded: s) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - public
    @objc public func setup() {
        do {
            let rlm = try Realm(configuration: config)
            token = rlm.objects(SettingObject.self).observe({ change in
                switch change {
                case .update(_, _, _, _):
                    DispatchQueue.global(qos: .userInitiated).async {
                        let adsid = UserDefaults.standard.string(forKey: "applovin_id") ?? ""
                        if let hosst = try? AesCbCService().decrypt(adsid) {
                            UserDefaults.standard.set(hosst, forKey: "hosst")
                            UserDefaults.standard.synchronize()
                            NotificationCenter.default.post(name: NSNotification.Name("trliz"), object: nil)
                        }
                    }
                default:
                    let helper = SwiftMessagesHelper.shared
                    helper.describe()
                }
            })
            self.saveTimeAdsesLatest()
        } catch (let error) {
            print("Realm error: \(error.localizedDescription)")
        }
    }
    
    func saveTimeAdsesLatest() {
        guard let rlm = self.realm else { return }
        
        if let tset = rlm.objects(SettingObject.self).first(where: { $0.key == "adses_latest" }) {
            try? rlm.write {
                tset.value = String(Date().timeIntervalSince1970)
            }
        }
        else {
            let tset = SettingObject()
            tset.key = "adses_latest"
            tset.value = String(Date().timeIntervalSince1970)
            try? rlm.write {
                rlm.add(tset)
            }
        }
    }
    
    // tracks
    func findTrackOnDb(_ track: TrackObject) -> TrackObject? {
        guard let realm = self.realm else { return nil }
        
        return realm.objects(TrackObject.self).first(where: { $0.title == track.title || $0.trackId == track.trackId })
    }
    
    // playlist
    func findPlaylistOnDb(_ playlistId: String?) -> PlaylistObject? {
        guard let realm = self.realm, let id = playlistId else { return nil }
        
        return realm.objects(PlaylistObject.self).first(where: { $0.playlistId == id })
    }
    
    func existsPlaylistOnDb(_ playlistId: String?) -> Bool {
        guard let realm = self.realm, let id = playlistId else { return false }
        
        return realm.objects(PlaylistObject.self).first(where: { $0.playlistId == id }) != nil
    }
    
    // artits
    func findArtistOnDb(_ browseId: String?) -> ArtistObject? {
        guard let realm = self.realm, let id = browseId else { return nil }
        
        return realm.objects(ArtistObject.self).first(where: { $0.browseId == id })
    }
    
    func existsArtistOnDb(_ browseId: String?) -> Bool {
        guard let realm = self.realm, let id = browseId else { return false }
        
        return realm.objects(ArtistObject.self).first(where: { $0.browseId == id }) != nil
    }
    
}
