//
//  URLExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import Foundation

extension URL {
    static func cache() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func document() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func data() -> URL {
        let folder = self.document().appendingPathComponent("data")
        self.ensureFolderExists(url: folder)
        return folder
    }
    
    static func ensureFolderExists(url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
