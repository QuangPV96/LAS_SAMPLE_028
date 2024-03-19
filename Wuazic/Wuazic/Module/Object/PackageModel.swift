//
//  PackageModel.swift
//  TaunporPlayer
//
//  Created by Minh Tuan on 15/08/2023.
//

import UIKit
import WebKit
import AdSupport
import KeychainSwift

class PackageModel: NSObject {
    var device_id: String
    var user_agent: String
    var idfa: String
    var idfv: String
    var notify: String
    var screen_size: String
    var language: String
    var locale: String
    var os_version: String
    var os_type: String
    var model: String
    var package: String
    var network: String
    var timezone: String
    var time: TimeInterval
    var network_name: String
    var name: String
    var ip: String
    var country: String
    var org: String
    var ass: String
    var isp: String
    var event: [String: Any] = [:]
    var extra: [String: Any] = [:]
    
    override init() {
        let key = "device_id"
        let keychain = KeychainSwift()
        if keychain.get(key) == nil {
            device_id = UUID().uuidString
            keychain.set(device_id, forKey: key)
        } else {
            device_id = keychain.get(key) ?? ""
        }
        user_agent = ""
        idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        idfv = UIDevice.current.identifierForVendor?.uuidString ?? ""
        notify = UserDefaults.standard.string(forKey: "notify_monitor") ?? ""
        
        screen_size = "\(UIScreen.main.bounds.size.width)x\(UIScreen.main.bounds.size.height)"
        
        if #available(iOS 16, *) {
            language = Locale.current.language.languageCode?.identifier ?? ""
        } else {
            language = Locale.current.languageCode ?? ""
        }
        
        locale = Locale.current.identifier
        os_version = UIDevice.current.systemVersion
        os_type = UIDevice.current.systemName
        model = UIDevice.current.modelName
        package = Bundle.main.bundleIdentifier ?? ""
        network = UserDefaults.standard.string(forKey: "network_monitor") ?? ""
        timezone = TimeZone.current.abbreviation() ?? ""
        time = Date().timeIntervalSince1970
        network_name = "" // deprecated
        
        name = UIDevice.current.name
        ip = ""
        country = ""
        org = ""
        ass = ""
        isp = ""
    }
    
    override var description: String {
            var des: String = "\(type(of: self)) :"
            for child in Mirror(reflecting: self).children {
                if let propName = child.label {
                    des += "\(propName): \(child.value) \n"
                }
            }
            
            return des
        }
        
        func toDictionary() -> [String: Any] {
            var json: [String: Any] = [:]
            for child in Mirror(reflecting: self).children {
                if let propName = child.label {
                    json[propName] = child.value
                }
            }
            return json
        }
}
