//
//  StringExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UIKit
import Foundation

extension String {
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    var pathExtension: String {
        return fileURL.pathExtension
    }
    
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
    
//    var fileName: String {
//        return fileURL.deletingPathExtension().lastPathComponent
//    }
    
    var toJson: MuDictionary? {
        let data = Data(self.utf8)
        
        do {
            // make sure this JSON is in the format we expect
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? MuDictionary
            return json
        } catch let error as NSError {
            print("Convert to JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    var toArrayJson: [MuDictionary]? {
        if let data = self.data(using: .utf8) {
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [MuDictionary]
                return result
            } catch { }
        }
        return nil
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: self)
    }
}

extension Collection where Iterator.Element == [String:Any] {
    func toJSONString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let arr = self as? [[String:Any]],
           let dat = try? JSONSerialization.data(withJSONObject: arr, options: options),
           let str = String(data: dat, encoding: String.Encoding.utf8) {
            return str
        }
        return "[]"
    }
}

extension Dictionary {
    func toString() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            var percentEscapedValue: String = "\(value)"
            if value is String {
                percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            }
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
    
}

extension String {
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}
