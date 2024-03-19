//
//  MuJSCore.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UIKit
import JavaScriptCore

class MuJSCore: NSObject {
    // MARK: - properties
    
    // MARK: - initial
    static let shared = MuJSCore()
    override init() {
        super.init()
    }
    
    // MARK: -
    func sendRequest(_ params: [AnyHashable : Any],
                     completion: @escaping (_ html: String?, _ function: String?) -> Void)
    {
        guard let data = params["data"] as? [AnyHashable : Any],
              let link = data["url"] as? String,
              let url = URL(string: link),
              let method = data["method"] as? String
        else {
            completion(nil, nil)
            return
        }
        
        let function = params["function"] as? String
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let headers = data["headers"] as? [String : String] {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if method.lowercased() == "post", let body = data["data"] as? String {
            request.httpBody = body.data(using: .utf8)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            let content = String(data: data, encoding: .utf8)
            completion(content, function)
        }.resume()
    }
    
    func execFuncWithRequest(_ context: JSContext?,
                             funcName: String?,
                             arguments: [Any]?,
                             completion: @escaping (_ value: JSValue?) -> Void)
    {
        guard let jsFuncInit = context?.objectForKeyedSubscript(funcName),
              let jsValue = jsFuncInit.call(withArguments: arguments)
        else {
            completion(nil)
            return
        }
        
        if jsValue.isObject, let params = jsValue.toDictionary() {
            self.sendRequest(params) { [weak self] html, function in
                let value = self?.execFunc(context, funcName: function, argument: html)
                
                DispatchQueue.main.async {
                    completion(value)
                }
            }
        }
        else {
            completion(jsValue)
        }
    }
    
    private func execFunc(_ context: JSContext?, funcName: String?, argument: String?) -> JSValue? {
        guard let context = context, let arg = argument, let function = funcName else {
            return nil
        }
        
        guard let jsFunc = context.objectForKeyedSubscript(function),
              let jsValue = jsFunc.call(withArguments: [arg]) else { return nil }
        
        return jsValue
    }
}
