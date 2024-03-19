import Foundation

@propertyWrapper
struct LocalStorage {
    
    let key: String
    let value: String
    
    public var wrappedValue: String {
        get {
            return UserDefaults.standard.string(forKey: key) ?? value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
}
